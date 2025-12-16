import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/finance_provider.dart';
import '../../domain/models/transaction.dart';
import '../../domain/models/category.dart';
import 'manage_categories_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showTransactionModal(
    BuildContext context, {
    Transaction? transactionToEdit,
  }) {
    final provider = Provider.of<FinanceProvider>(context, listen: false);
    final isExpenseTab = _tabController.index == 0;
    final titleController = TextEditingController(
      text: transactionToEdit?.title,
    );
    final amountController = TextEditingController(
      text: transactionToEdit?.amount.toStringAsFixed(0),
    );

    CategoryModel? selectedCategory;
    if (transactionToEdit != null) {
      selectedCategory = transactionToEdit.category;
    } else {
      if (provider.categories.isNotEmpty) {
        selectedCategory = provider.categories.first;
      }
    }

    DateTime selectedDate = transactionToEdit?.date ?? DateTime.now();
    bool isExpense = transactionToEdit?.isExpense ?? isExpenseTab;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        transactionToEdit == null
                            ? (isExpense ? 'Nuevo Gasto' : 'Nuevo Ingreso')
                            : 'Editar Transacción',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // Botón de configuración de categorías
                      IconButton(
                        icon: const Icon(Icons.settings),
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const ManageCategoriesScreen(),
                            ),
                          );
                          setModalState(() {
                            if (provider.categories.isNotEmpty &&
                                selectedCategory == null) {
                              selectedCategory = provider.categories.first;
                            }
                          });
                        },
                        tooltip: 'Gestionar Categorías',
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Título',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.title),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: amountController,
                    decoration: const InputDecoration(
                      labelText: 'Monto',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<CategoryModel>(
                          value:
                              selectedCategory, // Usamos value en lugar de initialValue para reactividad
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
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) {
                              setModalState(() {
                                selectedDate = picked;
                              });
                            }
                          },
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Fecha',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.calendar_today),
                            ),
                            child: Text(
                              DateFormat('dd/MM/yyyy').format(selectedDate),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      final title = titleController.text.trim();
                      final amount = double.tryParse(
                        amountController.text.trim(),
                      );

                      if (title.isNotEmpty &&
                          amount != null &&
                          selectedCategory != null) {
                        final newTransaction = Transaction(
                          id:
                              transactionToEdit?.id ??
                              DateTime.now().toString(),
                          title: title,
                          amount: amount,
                          date: selectedDate,
                          isExpense: isExpense,
                          category: selectedCategory!,
                        );

                        if (transactionToEdit != null) {
                          provider.updateTransaction(newTransaction);
                        } else {
                          provider.addTransaction(newTransaction);
                        }
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: isExpense ? Colors.red : Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      transactionToEdit == null ? 'Guardar' : 'Guardar Cambios',
                    ),
                  ),
                  // [NUEVO] Botón de Eliminar solo si estamos editando
                  if (transactionToEdit != null) ...[
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: () {
                        // Confirmación opcional
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('¿Eliminar?'),
                            content: const Text(
                              'Esta acción no se puede deshacer.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('CANCELAR'),
                              ),
                              TextButton(
                                onPressed: () {
                                  provider.deleteTransaction(
                                    transactionToEdit.id,
                                  );
                                  Navigator.pop(ctx); // Cerrar alerta
                                  Navigator.pop(context); // Cerrar modal
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                                child: const Text('ELIMINAR'),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      label: const Text(
                        'ELIMINAR TRANSACCIÓN',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
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
    final provider = Provider.of<FinanceProvider>(context);
    final expenses = provider.transactions.where((tx) => tx.isExpense).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    final income = provider.transactions.where((tx) => !tx.isExpense).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro Diario'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Gastos'),
            Tab(text: 'Ingresos'),
          ],
          indicatorColor: _tabController.index == 0 ? Colors.red : Colors.green,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTransactionList(expenses, true),
          _buildTransactionList(income, false),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTransactionModal(context),
        backgroundColor: _tabController.index == 0 ? Colors.red : Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildTransactionList(List<Transaction> transactions, bool isExpense) {
    if (transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isExpense ? Icons.money_off : Icons.attach_money,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              isExpense
                  ? 'No hay gastos registrados'
                  : 'No hay ingresos registrados',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final tx = transactions[index];
        return Dismissible(
          key: Key(tx.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (_) {
            Provider.of<FinanceProvider>(
              context,
              listen: false,
            ).deleteTransaction(tx.id);
          },
          child: Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              onTap: () =>
                  _showTransactionModal(context, transactionToEdit: tx),
              borderRadius: BorderRadius.circular(12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: tx.category.color,
                  child: Icon(tx.category.icon, color: Colors.white),
                ),
                title: Text(
                  tx.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${tx.category.name} • ${DateFormat('dd/MM/yyyy').format(tx.date)}',
                ),
                trailing: Text(
                  '\$${tx.amount.toStringAsFixed(0)}',
                  style: TextStyle(
                    color: isExpense ? Colors.red : Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
