import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/finance_provider.dart';
import '../../domain/models/budget.dart';
import '../../domain/models/category.dart';
import 'manage_categories_screen.dart';

class BudgetsScreen extends StatelessWidget {
  const BudgetsScreen({super.key});

  void _showAddBudgetModal(BuildContext context) {
    final provider = Provider.of<FinanceProvider>(context, listen: false);
    final amountController = TextEditingController();

    // Default to first category if available
    CategoryModel? selectedCategory = provider.categories.isNotEmpty
        ? provider.categories.first
        : null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            // Refresh categories
            final categories = provider.categories;
            if (selectedCategory == null && categories.isNotEmpty) {
              selectedCategory = categories.first;
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Nuevo Presupuesto',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<CategoryModel>(
                          initialValue: selectedCategory,
                          decoration: const InputDecoration(
                            labelText: 'Categoría',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.category),
                          ),
                          items: categories.map((category) {
                            return DropdownMenuItem(
                              value: category,
                              child: Row(
                                children: [
                                  Icon(category.icon, color: category.color),
                                  const SizedBox(width: 8),
                                  Text(category.name),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setModalState(() {
                                selectedCategory = value;
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(
                          Icons.add_circle_outline,
                          color: Colors.indigo,
                          size: 32,
                        ),
                        onPressed: () async {
                          // Navigate to category management screen
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ManageCategoriesScreen(),
                            ),
                          );
                          // Refresh categories after returning
                          setModalState(() {
                            final updatedCategories = provider.categories;
                            if (updatedCategories.isNotEmpty) {
                              selectedCategory = updatedCategories.last;
                            }
                          });
                        },
                        tooltip: 'Nueva Categoría',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: amountController,
                    decoration: const InputDecoration(
                      labelText: 'Límite Mensual',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      final amount = double.tryParse(
                        amountController.text.trim(),
                      );
                      if (amount != null && selectedCategory != null) {
                        // Check if budget already exists for this category
                        final existingBudgetIndex = provider.budgets.indexWhere(
                          (b) => b.categoryId == selectedCategory!.id,
                        );

                        if (existingBudgetIndex != -1) {
                          // Update existing
                          final existingBudget =
                              provider.budgets[existingBudgetIndex];
                          provider.updateBudget(
                            Budget(
                              id: existingBudget.id,
                              categoryId: selectedCategory!.id,
                              limitAmount: amount,
                            ),
                          );
                        } else {
                          // Create new
                          provider.addBudget(
                            Budget(
                              id: DateTime.now().toString(),
                              categoryId: selectedCategory!.id,
                              limitAmount: amount,
                            ),
                          );
                        }
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Guardar Presupuesto'),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Presupuestos Mensuales')),
      body: Consumer<FinanceProvider>(
        builder: (context, provider, child) {
          if (provider.budgets.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.speed, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No tienes presupuestos definidos'),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _showAddBudgetModal(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Crear Presupuesto'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.budgets.length,
            itemBuilder: (context, index) {
              final budget = provider.budgets[index];
              final category = provider.getCategoryById(budget.categoryId);

              if (category == null) return const SizedBox.shrink();

              final spent = provider.getCategorySpending(category.id);
              final progress = (spent / budget.limitAmount).clamp(0.0, 1.0);

              // Color logic
              Color progressColor = Colors.green;
              if (progress > 0.8) {
                progressColor = Colors.red;
              } else if (progress > 0.5) {
                progressColor = Colors.orange;
              }

              return Dismissible(
                key: Key(budget.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) {
                  provider.deleteBudget(budget.id);
                },
                child: Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: category.color,
                              child: Icon(category.icon, color: Colors.white),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                category.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Text(
                              '${(progress * 100).toStringAsFixed(0)}%',
                              style: TextStyle(
                                color: progressColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.grey[200],
                          color: progressColor,
                          minHeight: 10,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Gastado: \$${spent.toStringAsFixed(0)}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'Límite: \$${budget.limitAmount.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: Consumer<FinanceProvider>(
        builder: (context, provider, child) {
          return provider.budgets.isNotEmpty
              ? FloatingActionButton(
                  onPressed: () => _showAddBudgetModal(context),
                  backgroundColor: Colors.indigo,
                  child: const Icon(Icons.add, color: Colors.white),
                )
              : const SizedBox.shrink();
        },
      ),
    );
  }
}
