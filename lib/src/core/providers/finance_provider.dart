import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:hive/hive.dart';
import 'dart:io';

// Models
import '../../features/finance/domain/models/transaction.dart';
import '../../features/finance/domain/models/category.dart';
import '../../features/finance/domain/models/budget.dart';
import '../../features/finance/domain/models/saving_goal.dart';
import '../../features/finance/domain/models/subscription.dart';

// Service
import '../services/storage_service.dart';
import '../../features/finance/domain/models/wallet_card.dart';

class FinanceProvider extends ChangeNotifier {
  final StorageService _storageService;

  FinanceProvider(this._storageService) {
    _initializeCategories();
  }

  void _initializeCategories() {
    if (_storageService.categoryBox.isEmpty) {
      final defaultCategories = CategoryModel.getDefaultCategories();
      for (var category in defaultCategories) {
        _storageService.categoryBox.put(category.id, category);
      }
    }
  }

  // --- Getters (Hive Powered) ---
  List<Transaction> get transactions =>
      _storageService.transactionBox.values.toList();

  List<CategoryModel> get categories =>
      _storageService.categoryBox.values.toList();

  List<SavingGoal> get savings => _storageService.savingBox.values.toList();

  List<Budget> get budgets => _storageService.budgetBox.values.toList();

  List<Subscription> get subscriptions =>
      _storageService.subscriptionBox.values.toList();

  // [MODIFICADO] Balance de Liquidez (Dinero Real Disponible)

  // [NUEVO] Deuda Total Acumulada (Solo TC)
  // Suma todos los gastos hechos con TC que aún no se han "pagado" explícitamente
  // (En este modelo simple, asumimos que todo gasto TC es deuda hasta que se pague la tarjeta)
  double get totalCreditDebt {
    return transactions
        .where(
          (tx) =>
              tx.isExpense &&
              tx.paymentMethod != null &&
              tx.paymentMethod!.startsWith('TC'),
        )
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  // --- WALLET MANAGEMENT ---
  Box<WalletCard> get _walletBox => _storageService.walletBox;
  List<WalletCard> get myCards => _walletBox.values.toList();

  void addCard(WalletCard card) {
    _walletBox.put(card.id, card);
    notifyListeners();
  }

  void deleteCard(String id) {
    _walletBox.delete(id);
    notifyListeners();
  }

  // --- FAVORITOS PARA DASHBOARD ---

  /// Obtener las 2 tarjetas principales para el Dashboard
  List<WalletCard> getDashboardCards() {
    // Prioridad: Favoritas primero
    final favorites = myCards.where((c) => c.isFavorite).toList();

    if (favorites.length >= 2) {
      return favorites.take(2).toList();
    } else {
      // Si hay menos de 2 favoritas, rellenar con las normales
      final others = myCards.where((c) => !c.isFavorite).toList();
      return [...favorites, ...others].take(2).toList();
    }
  }

  /// Alternar estado de favorito
  Future<void> toggleCardFavorite(String cardId) async {
    final card = _walletBox.get(cardId);
    if (card != null) {
      // Crear nueva instancia con el valor invertido
      final updatedCard = WalletCard(
        id: card.id,
        name: card.name,
        bankName: card.bankName,
        type: card.type,
        paymentDay: card.paymentDay,
        limit: card.limit,
        colorValue: card.colorValue,
        initialBalance: card.initialBalance,
        isFavorite: !card.isFavorite, // Toggle
      );

      await _walletBox.put(cardId, updatedCard);
      notifyListeners();
    }
  }

  /// Editar tarjeta existente
  Future<void> editCard(
    String cardId,
    String newName,
    String newBankName,
    double newLimit,
    int newColor,
    double newInitialBalance,
    int newPaymentDay,
  ) async {
    final card = _walletBox.get(cardId);
    if (card != null) {
      final oldName = card.name;

      // Si el nombre cambia, actualizar paymentMethod en transacciones
      if (oldName != newName) {
        for (var tx in transactions) {
          if (tx.paymentMethod == oldName) {
            final updatedTx = Transaction(
              id: tx.id,
              title: tx.title,
              amount: tx.amount,
              isExpense: tx.isExpense,
              date: tx.date,
              category: tx.category,
              paymentMethod: newName, // Actualizar al nuevo nombre
            );
            await _storageService.transactionBox.put(tx.id, updatedTx);
          }
        }
      }

      final updatedCard = WalletCard(
        id: card.id,
        name: newName,
        bankName: newBankName,
        type: card.type,
        paymentDay: newPaymentDay,
        limit: newLimit,
        colorValue: newColor,
        initialBalance: newInitialBalance,
        isFavorite: card.isFavorite,
      );

      await _walletBox.put(cardId, updatedCard);
      notifyListeners();
    }
  }

  /// Registrar pago de tarjeta (Libera cupo)
  void payCreditCard(String cardName, double amount) {
    // Un pago a TC se registra como ingreso vinculado a esa tarjeta
    // Esto reduce la deuda calculada
    final paymentCategory = categories.firstWhere(
      (c) => c.name.toLowerCase().contains('financ'),
      orElse: () => categories.first,
    );

    final tx = Transaction(
      id: DateTime.now().toString(),
      title: 'PAGO ESTADO DE CUENTA',
      amount: amount,
      date: DateTime.now(),
      isExpense: false, // Ingreso reduce la deuda
      category: paymentCategory,
      paymentMethod: cardName,
    );
    addTransaction(tx);
  }

  // Lista de Bancos Chilenos para el Dropdown
  final List<String> chileanBanks = [
    'Banco Estado',
    'Banco de Chile',
    'Banco Santander',
    'Banco BCI',
    'Scotiabank',
    'Itaú',
    'Banco Falabella',
    'Banco Ripley',
    'Mercado Pago',
    'Tenpo',
    'Mach',
    'Coopeuch',
    'Banco Security',
    'Banco Consorcio',
    'Otro',
  ];

  // Modificar getActivePaymentMethods para usar las tarjetas reales + Efectivo
  List<String> getAvailablePaymentMethods() {
    List<String> methods = ['Efectivo']; // Siempre disponible
    for (var card in myCards) {
      methods.add(card.name);
    }
    return methods;
  }

  // Verificar si un método de pago es Crédito (Deuda)
  bool isCreditMethod(String methodName) {
    if (methodName == 'Efectivo') return false;
    try {
      final card = myCards.firstWhere((c) => c.name == methodName);
      return card.isCredit;
    } catch (_) {
      // Si no encuentra la tarjeta, revisamos si empieza con TC (legacy)
      return methodName.startsWith('TC');
    }
  }

  // --- ALERTAS DE PAGO ---
  List<String> getPaymentAlerts() {
    final alerts = <String>[];
    final now = DateTime.now();

    for (var card in myCards) {
      if (card.isCredit) {
        // Calcular días para el pago
        var nextPayment = DateTime(now.year, now.month, card.paymentDay);
        if (nextPayment.isBefore(now)) {
          nextPayment = DateTime(now.year, now.month + 1, card.paymentDay);
        }

        final diff = nextPayment.difference(now).inDays;

        // Alerta si faltan 5 días o menos
        if (diff <= 5 && diff >= 0) {
          final debt = getMonthlyPaymentForCard(card.name);
          if (debt > 0) {
            alerts.add(
              'Pagar ${card.name}: \$${debt.toStringAsFixed(0)} en $diff días',
            );
          }
        }
      }
    }
    return alerts;
  }

  double get totalExpenses {
    return transactions
        .where((tx) => tx.isExpense)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  double get totalIncome {
    return transactions
        .where((tx) => !tx.isExpense)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  // --- Transactions ---
  Future<String> addTransaction(Transaction transaction) async {
    await _storageService.transactionBox.put(transaction.id, transaction);
    notifyListeners();
    return transaction.id;
  }

  void updateTransaction(Transaction transaction) {
    _storageService.transactionBox.put(transaction.id, transaction);
    notifyListeners();
  }

  void deleteTransaction(String id) {
    _storageService.transactionBox.delete(id);
    notifyListeners();
  }

  bool existsSimilarTransaction(String title, double amount, DateTime date) {
    return transactions.any((tx) {
      final isSameTitle = tx.title == title;
      final isSameAmount = (tx.amount - amount).abs() < 0.01;
      final isSameDate = tx.date.difference(date).abs().inMinutes < 1;
      return isSameTitle && isSameAmount && isSameDate;
    });
  }

  // --- Categories ---
  Future<void> addCategory(
    String name,
    int colorValue,
    int iconCodePoint,
  ) async {
    final newCat = CategoryModel(
      id: DateTime.now().toString(),
      name: name,
      iconCode: iconCodePoint,
      colorValue: colorValue,
    );
    await _storageService.categoryBox.put(newCat.id, newCat);
    notifyListeners();
  }

  void deleteCategory(String id) {
    _storageService.categoryBox.delete(id);
    notifyListeners();
  }

  CategoryModel? getCategoryById(String id) {
    return _storageService.categoryBox.get(id);
  }

  double getCategorySpending(String categoryId) {
    return transactions
        .where((tx) => tx.isExpense && tx.category.id == categoryId)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  // --- Savings (Hive Persistence) ---
  void addSavingGoal(SavingGoal goal) {
    _storageService.savingBox.put(goal.id, goal);
    notifyListeners();
  }

  void updateSavingGoal(SavingGoal goal) {
    _storageService.savingBox.put(goal.id, goal);
    notifyListeners();
  }

  void updateSavingGoalAmount(String id, double amountToAdd) {
    final goal = _storageService.savingBox.get(id);
    if (goal != null) {
      goal.currentAmount += amountToAdd;
      goal.save(); // HiveObject method
      notifyListeners();
    }
  }

  void deleteSavingGoal(String id) {
    _storageService.savingBox.delete(id);
    notifyListeners();
  }

  // --- Budgets (Hive Persistence) ---
  void addBudget(Budget budget) {
    _storageService.budgetBox.put(budget.id, budget);
    notifyListeners();
  }

  void updateBudget(Budget budget) {
    _storageService.budgetBox.put(budget.id, budget);
    notifyListeners();
  }

  void deleteBudget(String id) {
    _storageService.budgetBox.delete(id);
    notifyListeners();
  }

  // --- Subscriptions (Hive Persistence) ---
  void addSubscription(Subscription subscription) {
    _storageService.subscriptionBox.put(subscription.id, subscription);
    notifyListeners();
  }

  void updateSubscription(Subscription subscription) {
    _storageService.subscriptionBox.put(subscription.id, subscription);
    notifyListeners();
  }

  void removeSubscription(String id) {
    _storageService.subscriptionBox.delete(id);
    notifyListeners();
  }

  double get totalMonthlySubscriptions {
    return subscriptions.fold(0.0, (sum, item) => sum + item.price);
  }

  // --- CSV Export ---
  Future<void> exportTransactionsToCSV() async {
    try {
      List<List<dynamic>> rows = [];
      rows.add(["Fecha", "Título", "Categoría", "Tipo", "Monto"]);

      for (var tx in transactions) {
        rows.add([
          tx.date.toIso8601String().split('T')[0],
          tx.title,
          tx.category.name,
          tx.isExpense ? "Gasto" : "Ingreso",
          tx.amount,
        ]);
      }

      String csv = const ListToCsvConverter().convert(rows);
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/cato_finanzas_export.csv');
      await file.writeAsString(csv);

      await Share.shareXFiles([
        XFile(file.path),
      ], text: 'Reporte Financiero CATO OS');
    } catch (e) {
      // [FIX] Error handling - Log and rethrow for UI feedback
      debugPrint('Error al exportar CSV: $e');
      rethrow;
    }
  }

  // --- Lógica de Crédito y Deuda ---

  /// Obtiene una lista de todos los métodos de pago usados (Tarjetas)
  List<String> getActivePaymentMethods() {
    return transactions
        .where(
          (tx) =>
              tx.isExpense &&
              tx.paymentMethod != null &&
              tx.paymentMethod != 'Efectivo / Débito',
        )
        .map((tx) => tx.paymentMethod!)
        .toSet()
        .toList();
  }

  /// Calcula cuánto hay que pagar este mes actual en una tarjeta específica
  double getMonthlyPaymentForCard(String cardName) {
    final now = DateTime.now();
    return transactions
        .where(
          (tx) =>
              tx.isExpense &&
              tx.paymentMethod == cardName &&
              tx.date.year == now.year &&
              tx.date.month == now.month,
        )
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  /// Calcula la deuda total (Gastos - Pagos) de una tarjeta
  double getRemainingDebtForCard(String cardName) {
    // [FIX] Lógica: Todos los gastos suman, todos los pagos restan
    final txs = transactions.where((t) => t.paymentMethod == cardName);
    double totalDebt = 0;
    for (var tx in txs) {
      if (tx.isExpense) {
        totalDebt += tx.amount; // Gasto aumenta deuda
      } else {
        totalDebt -= tx.amount; // Pago reduce deuda
      }
    }
    // No mostrar deuda negativa
    return totalDebt > 0 ? totalDebt : 0;
  }

  /// Calcula el saldo disponible de una tarjeta de débito/vista
  /// Comienza con el initialBalance y suma ingresos, resta gastos
  double getCardBalance(String cardName) {
    // Buscar la tarjeta
    WalletCard? card;
    try {
      card = myCards.firstWhere((c) => c.name == cardName);
    } catch (_) {
      return 0.0; // Si no existe la tarjeta, retornar 0
    }

    // Comenzar con el saldo inicial
    double balance = card.initialBalance;

    // Filtrar transacciones de esta tarjeta
    final cardTransactions = transactions
        .where((tx) => tx.paymentMethod == cardName)
        .toList();

    // Sumar ingresos, restar gastos
    for (var tx in cardTransactions) {
      if (tx.isExpense) {
        balance -= tx.amount;
      } else {
        balance += tx.amount;
      }
    }

    return balance;
  }

  // [FIX] Liquidez real = Saldo en Débito/Efectivo
  // NO incluye "ingresos" a Tarjetas de Crédito
  double get totalBalance {
    double liquidity = 0.0;

    // 1. Sumar Saldos Iniciales SOLO de Débito/Efectivo
    for (var card in myCards) {
      if (!card.isCredit) {
        liquidity += card.initialBalance;
      }
    }

    // 2. Procesar Transacciones
    for (var tx in transactions) {
      // Verificar si el método de pago es Crédito
      bool isCreditTransaction = false;
      try {
        final card = myCards.firstWhere((c) => c.name == tx.paymentMethod);
        isCreditTransaction = card.isCredit;
      } catch (_) {
        isCreditTransaction =
            false; // Asumimos Efectivo si no encuentra tarjeta
      }

      if (isCreditTransaction) {
        // Si es movimiento de TC (Gasto o Pago de cupo), NO afecta la liquidez inmediata
        continue;
      }

      // Si es movimiento de Débito/Efectivo:
      if (tx.isExpense) {
        liquidity -= tx.amount; // Gasto resta liquidez
      } else {
        liquidity += tx.amount; // Ingreso suma liquidez
      }
    }

    return liquidity;
  }

  /// Agrupa las transacciones de cuotas para mostrar "Cocina (3/6)"
  /// Retorna una lista de objetos agrupados
  List<Map<String, dynamic>> getCreditDetails(String cardName) {
    final now = DateTime.now();
    // Filtramos transacciones de esta tarjeta que sean futuras o del mes actual
    final cardTxs = transactions
        .where(
          (tx) =>
              tx.isExpense &&
              tx.paymentMethod == cardName &&
              (tx.date.isAfter(now) ||
                  (tx.date.year == now.year && tx.date.month == now.month)),
        )
        .toList();

    // Agrupamos por la raíz del ID (asumiendo formato timestamp_index)
    // Si no tiene guión bajo, es compra única.
    final Map<String, List<Transaction>> groups = {};

    for (var tx in cardTxs) {
      String rootId = tx.id.contains('_') ? tx.id.split('_')[0] : tx.id;
      if (!groups.containsKey(rootId)) {
        groups[rootId] = [];
      }
      groups[rootId]!.add(tx);
    }

    List<Map<String, dynamic>> debts = [];

    groups.forEach((key, txList) {
      // Ordenar por fecha
      txList.sort((a, b) => a.date.compareTo(b.date));

      // Intentar extraer nombre limpio (quitar "(1/6)")
      String rawTitle = txList.first.title;
      String cleanTitle = rawTitle
          .replaceAll(RegExp(r'\(\d+/\d+\)'), '')
          .trim();

      double totalRemaining = txList.fold(0.0, (sum, t) => sum + t.amount);
      int installmentsLeft = txList.length;

      // Buscar la cuota de este mes (si existe)
      final thisMonthTx = txList.firstWhere(
        (t) => t.date.year == now.year && t.date.month == now.month,
        orElse: () => txList.first, // Fallback
      );

      debts.add({
        'title': cleanTitle,
        'monthlyAmount': thisMonthTx.amount, // Cuota mensual
        'totalRemaining': totalRemaining,
        'installmentsLeft': installmentsLeft,
        'nextPaymentDate': thisMonthTx.date,
      });
    });

    return debts;
  }

  @override
  void dispose() {
    // Clean up resources if needed in the future
    super.dispose();
  }
}
