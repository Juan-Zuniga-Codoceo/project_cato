import 'package:flutter/material.dart';
import '../domain/models/task_model.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/finance_provider.dart';
import '../../finance/domain/models/transaction.dart';
import '../../finance/domain/models/category.dart';
import '../../../core/services/storage_service.dart';

class TaskProvider extends ChangeNotifier {
  final StorageService _storageService;
  final List<TaskModel> _tasks = [];
  bool _isSaving = false;

  TaskProvider(this._storageService) {
    _loadTasks();
  }

  void _loadTasks() {
    _tasks.clear();
    _tasks.addAll(_storageService.taskBox.values);
    notifyListeners();
  }

  List<TaskModel> get tasks => _tasks;

  List<TaskModel> get pendingTasks =>
      _tasks.where((t) => !t.isCompleted).toList();

  List<TaskModel> get completedTasks =>
      _tasks.where((t) => t.isCompleted).toList();

  List<TaskModel> get tasksForToday {
    final now = DateTime.now();
    return _tasks.where((t) {
      return !t.isCompleted &&
          t.dueDate.year == now.year &&
          t.dueDate.month == now.month &&
          t.dueDate.day == now.day;
    }).toList();
  }

  Future<void> addTask(TaskModel task, BuildContext context) async {
    // Concurrency Lock: Prevent duplicate execution
    if (_isSaving) return;

    try {
      _isSaving = true;
      notifyListeners();

      // INVERTED CONTROL FLOW: Create transaction FIRST (if needed)
      String? relatedTxId;

      if (task.isCompleted &&
          task.associatedCost != null &&
          task.associatedCost! > 0) {
        // Hard Link Check: Task shouldn't have ID yet (we're creating it)
        if (task.relatedTransactionId != null) {
          return;
        }

        // Get FinanceProvider
        final financeProvider = Provider.of<FinanceProvider>(
          context,
          listen: false,
        );

        // Find or fallback to category
        CategoryModel? category;
        if (task.categoryId != null) {
          category = financeProvider.getCategoryById(task.categoryId!);
        }

        if (category == null) {
          try {
            if (task.isIncome) {
              category = financeProvider.categories.firstWhere(
                (c) =>
                    c.name.toLowerCase().contains('sueldo') ||
                    c.name.toLowerCase().contains('ingreso'),
                orElse: () => financeProvider.categories.first,
              );
            } else {
              category = financeProvider.categories.firstWhere(
                (c) => c.name.toLowerCase().contains('otros'),
                orElse: () => financeProvider.categories.first,
              );
            }
          } catch (e) {
            // Category fallback error
          }
        }

        if (category != null) {
          // Safety Net: Check for duplicate transactions
          if (!financeProvider.existsSimilarTransaction(
            task.title,
            task.associatedCost!,
            DateTime.now(),
          )) {
            // Create transaction
            final transaction = Transaction(
              id: DateTime.now().toString(),
              title: task.title,
              amount: task.associatedCost!,
              isExpense: !task.isIncome,
              date: DateTime.now(),
              category: category,
            );

            // Add transaction and GET ID
            relatedTxId = await financeProvider.addTransaction(transaction);
          }
        }
      }

      // ATOMIC SAVE: Build task with relatedTransactionId ALREADY SET
      final finalTask = relatedTxId != null
          ? task.copyWith(relatedTransactionId: relatedTxId)
          : task;

      // Save to memory and Hive ONCE
      _tasks.add(finalTask);
      _storageService.taskBox.put(finalTask.id, finalTask);
      notifyListeners();

      // Show snackbar if transaction was created
      if (relatedTxId != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              task.isIncome
                  ? 'Ingreso registrado: \$${task.associatedCost}'
                  : 'Gasto registrado: \$${task.associatedCost}',
            ),
            backgroundColor: task.isIncome ? Colors.green : Colors.red,
          ),
        );
      }
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  void updateTask(TaskModel updatedTask, BuildContext context) {
    final index = _tasks.indexWhere((t) => t.id == updatedTask.id);
    if (index != -1) {
      final oldTask = _tasks[index];
      _tasks[index] = updatedTask;
      _storageService.taskBox.put(updatedTask.id, updatedTask);
      notifyListeners();

      // Transition Check: Only trigger if transitioning from Incomplete -> Completed
      if (!oldTask.isCompleted && updatedTask.isCompleted) {
        _processFinancialImpact(updatedTask, context);
      }
    }
  }

  void deleteTask(String id) {
    _tasks.removeWhere((t) => t.id == id);
    _storageService.taskBox.delete(id);
    notifyListeners();
  }

  Future<void> toggleTaskCompletion(String id, BuildContext context) async {
    // Concurrency Lock: Prevent duplicate execution
    if (_isSaving) return;

    try {
      _isSaving = true;
      notifyListeners();

      final index = _tasks.indexWhere((t) => t.id == id);
      if (index == -1) return;

      final task = _tasks[index];
      final newStatus = !task.isCompleted;

      // INVERTED CONTROL FLOW: Handle financial impact BEFORE saving
      String? relatedTxId = task.relatedTransactionId;

      if (newStatus) {
        // Transitioning to COMPLETED
        if (task.associatedCost != null && task.associatedCost! > 0) {
          // Hard Link Check: DO NOT create transaction if already has ID
          if (task.relatedTransactionId == null) {
            // Get FinanceProvider
            final financeProvider = Provider.of<FinanceProvider>(
              context,
              listen: false,
            );

            // Find or fallback to category
            CategoryModel? category;
            if (task.categoryId != null) {
              category = financeProvider.getCategoryById(task.categoryId!);
            }

            if (category == null) {
              try {
                if (task.isIncome) {
                  category = financeProvider.categories.firstWhere(
                    (c) =>
                        c.name.toLowerCase().contains('sueldo') ||
                        c.name.toLowerCase().contains('ingreso'),
                    orElse: () => financeProvider.categories.first,
                  );
                } else {
                  category = financeProvider.categories.firstWhere(
                    (c) => c.name.toLowerCase().contains('otros'),
                    orElse: () => financeProvider.categories.first,
                  );
                }
              } catch (e) {
                // Category fallback error
              }
            }

            if (category != null) {
              // Safety Net: Check for duplicate transactions
              if (!financeProvider.existsSimilarTransaction(
                task.title,
                task.associatedCost!,
                DateTime.now(),
              )) {
                // Create transaction
                final transaction = Transaction(
                  id: DateTime.now().toString(),
                  title: task.title,
                  amount: task.associatedCost!,
                  isExpense: !task.isIncome,
                  date: DateTime.now(),
                  category: category,
                );

                // Add transaction and GET ID
                relatedTxId = await financeProvider.addTransaction(transaction);

                // Show snackbar
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        task.isIncome
                            ? 'Ingreso registrado: \$${task.associatedCost}'
                            : 'Gasto registrado: \$${task.associatedCost}',
                      ),
                      backgroundColor: task.isIncome
                          ? Colors.green
                          : Colors.red,
                    ),
                  );
                }
              }
            }
          }
        }
      } else {
        // Transitioning to INCOMPLETE - clear relatedTransactionId
        if (relatedTxId != null) {
          relatedTxId = null;
        }
      }

      // ATOMIC SAVE: Build task with updated status and relatedTransactionId
      final updatedTask = task.copyWith(
        isCompleted: newStatus,
        relatedTransactionId: relatedTxId,
      );

      // Update in memory and Hive ONCE
      _tasks[index] = updatedTask;
      _storageService.taskBox.put(updatedTask.id, updatedTask);
      notifyListeners();
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<void> _processFinancialImpact(
    TaskModel task,
    BuildContext context,
  ) async {
    if (task.associatedCost != null && task.associatedCost! > 0) {
      // Hard Link Check: If already linked, STOP.
      if (task.relatedTransactionId != null) {
        return;
      }

      final financeProvider = Provider.of<FinanceProvider>(
        context,
        listen: false,
      );

      CategoryModel? category;
      if (task.categoryId != null) {
        category = financeProvider.getCategoryById(task.categoryId!);
      }

      // Fallback category if not found or not set
      if (category == null) {
        try {
          if (task.isIncome) {
            category = financeProvider.categories.firstWhere(
              (c) =>
                  c.name.toLowerCase().contains('sueldo') ||
                  c.name.toLowerCase().contains('ingreso'),
              orElse: () => financeProvider.categories.first,
            );
          } else {
            category = financeProvider.categories.firstWhere(
              (c) => c.name.toLowerCase().contains('otros'),
              orElse: () => financeProvider.categories.first,
            );
          }
        } catch (e) {
          // Should not happen if categories are initialized
        }
      }

      if (category != null) {
        // Safety Net: Check for duplicates (Secondary check)
        if (!financeProvider.existsSimilarTransaction(
          task.title,
          task.associatedCost!,
          DateTime.now(),
        )) {
          final transaction = Transaction(
            id: DateTime.now().toString(),
            title: task.title,
            amount: task.associatedCost!,
            isExpense: !task.isIncome, // Use isIncome flag
            date: DateTime.now(),
            category: category,
          );

          // Add transaction and get ID
          final newTxId = await financeProvider.addTransaction(transaction);

          // Update Task with Hard Link
          final updatedTask = task.copyWith(relatedTransactionId: newTxId);
          updateTask(updatedTask, context);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                task.isIncome
                    ? 'Ingreso registrado: \$${task.associatedCost}'
                    : 'Gasto registrado: \$${task.associatedCost}',
              ),
              backgroundColor: task.isIncome ? Colors.green : Colors.red,
            ),
          );
        }
      }
    }
  }
}
