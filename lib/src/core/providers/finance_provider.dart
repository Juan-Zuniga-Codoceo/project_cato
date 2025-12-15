import 'package:flutter/material.dart';
import '../../features/finance/domain/models/transaction.dart';
import '../../features/finance/domain/models/category.dart';
import '../../features/finance/domain/models/category.dart';
import '../services/storage_service.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';

class FinanceProvider extends ChangeNotifier {
  final StorageService _storageService;

  // In-memory lists for features not yet migrated to Hive
  final List<dynamic> _savings = [];
  final List<dynamic> _budgets = [];
  final List<dynamic> _subscriptions = [];

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

  // --- Getters ---
  List<Transaction> get transactions =>
      _storageService.transactionBox.values.toList();
  List<CategoryModel> get categories =>
      _storageService.categoryBox.values.toList();
  List<dynamic> get savings => _savings;
  List<dynamic> get budgets => _budgets;
  List<dynamic> get subscriptions => _subscriptions;

  double get totalBalance {
    final transactionBalance = transactions.fold(0.0, (sum, item) {
      return sum + (item.isExpense ? -item.amount : item.amount);
    });
    // Subtract subscriptions if they are considered monthly expenses in balance
    // For now, keeping simple transaction balance
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

  // --- Savings (In-Memory) ---
  void addSavingGoal(dynamic goal) {
    _savings.add(goal);
    notifyListeners();
  }

  void updateSavingGoal(dynamic goal) {
    // Assuming goal has id, find and replace
    // For dynamic, we might need to rely on index or object identity if id not accessible easily
    // But typically we pass the updated object.
    // Since we don't have the model imported, we'll just replace if found
    // This is a placeholder implementation
    final index = _savings.indexWhere((s) => s.id == goal.id);
    if (index != -1) {
      _savings[index] = goal;
      notifyListeners();
    }
  }

  void updateSavingGoalAmount(String id, double amount) {
    // Placeholder
    notifyListeners();
  }

  void deleteSavingGoal(String id) {
    _savings.removeWhere((s) => s.id == id);
    notifyListeners();
  }

  // --- Budgets (In-Memory) ---
  void addBudget(dynamic budget) {
    _budgets.add(budget);
    notifyListeners();
  }

  void updateBudget(dynamic budget) {
    final index = _budgets.indexWhere((b) => b.id == budget.id);
    if (index != -1) {
      _budgets[index] = budget;
      notifyListeners();
    }
  }

  void deleteBudget(String id) {
    _budgets.removeWhere((b) => b.id == id);
    notifyListeners();
  }

  // --- Subscriptions (In-Memory) ---
  void addSubscription(dynamic subscription) {
    _subscriptions.add(subscription);
    notifyListeners();
  }

  void updateSubscription(dynamic subscription) {
    final index = _subscriptions.indexWhere((s) => s.id == subscription.id);
    if (index != -1) {
      _subscriptions[index] = subscription;
      notifyListeners();
    }
  }

  void deleteSubscription(String id) {
    _subscriptions.removeWhere((s) => s.id == id);
    notifyListeners();
  }

  void removeSubscription(String id) => deleteSubscription(id);

  double get totalMonthlySubscriptions {
    return _subscriptions.fold(0.0, (sum, item) => sum + item.amount);
  }

  Future<void> exportTransactionsToCSV() async {
    List<List<dynamic>> rows = [];
    // Header
    rows.add(["Fecha", "Título", "Categoría", "Tipo", "Monto"]);

    // Data
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

    // Share
    await Share.shareXFiles([
      XFile(file.path),
    ], text: 'Reporte Financiero CATO OS');
  }
}
