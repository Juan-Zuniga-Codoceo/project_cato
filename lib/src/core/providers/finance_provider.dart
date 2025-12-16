import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';

// Models
import '../../features/finance/domain/models/transaction.dart';
import '../../features/finance/domain/models/category.dart';
import '../../features/finance/domain/models/budget.dart';
import '../../features/finance/domain/models/saving_goal.dart';
import '../../features/finance/domain/models/subscription.dart';

// Service
import '../services/storage_service.dart';

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

  double get totalBalance {
    final transactionBalance = transactions.fold(0.0, (sum, item) {
      return sum + (item.isExpense ? -item.amount : item.amount);
    });
    // Podríamos restar suscripciones aquí si se desea proyección a futuro
    return transactionBalance;
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
  void addCategory(CategoryModel category) {
    _storageService.categoryBox.put(category.id, category);
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
  }
}
