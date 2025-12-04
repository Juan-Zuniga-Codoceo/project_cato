import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/finance_provider.dart';
import '../../domain/models/saving_goal.dart';

class SavingsScreen extends StatefulWidget {
  const SavingsScreen({super.key});

  @override
  State<SavingsScreen> createState() => _SavingsScreenState();
}

class _SavingsScreenState extends State<SavingsScreen> {
  void _showGoalModal(BuildContext context, {SavingGoal? existingGoal}) {
    final provider = Provider.of<FinanceProvider>(context, listen: false);
    final nameController = TextEditingController(text: existingGoal?.name);
    final targetController = TextEditingController(
      text: existingGoal?.targetAmount.toStringAsFixed(0),
    );
    final currentController = TextEditingController(
      text: existingGoal?.currentAmount.toStringAsFixed(0) ?? '0',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              existingGoal == null ? 'Nueva Meta' : 'Editar Meta',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre (Ej: Viaje)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: targetController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Monto Meta',
                border: OutlineInputBorder(),
              ),
            ),
            if (existingGoal == null) ...[
              const SizedBox(height: 12),
              TextField(
                controller: currentController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Ahorro Inicial',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (nameController.text.isNotEmpty &&
                      targetController.text.isNotEmpty) {
                    final name = nameController.text;
                    final target = double.tryParse(targetController.text) ?? 0;
                    final current =
                        double.tryParse(currentController.text) ?? 0;

                    if (existingGoal == null) {
                      // Crear Nueva
                      final newGoal = SavingGoal(
                        id: DateTime.now().toString(),
                        name: name,
                        targetAmount: target,
                        currentAmount: current,
                      );
                      provider.addSavingGoal(newGoal);
                    } else {
                      // Editar Existente
                      // Creamos un objeto nuevo manteniendo el ID y el monto actual
                      final updatedGoal = SavingGoal(
                        id: existingGoal.id,
                        name: name,
                        targetAmount: target,
                        currentAmount: existingGoal.currentAmount,
                      );
                      provider.updateSavingGoal(updatedGoal);
                    }
                    Navigator.pop(context);
                  }
                },
                child: const Text('Guardar'),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showAddMoneyModal(BuildContext context, SavingGoal goal) {
    final provider = Provider.of<FinanceProvider>(context, listen: false);
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Abonar a ${goal.name}'),
        content: TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Monto a agregar',
            prefixText: '\$ ',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text);
              if (amount != null && amount > 0) {
                provider.updateSavingGoalAmount(goal.id, amount);
                Navigator.pop(context);
              }
            },
            child: const Text('Abonar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final savings = Provider.of<FinanceProvider>(context).savings;

    return Scaffold(
      appBar: AppBar(title: const Text('Metas de Ahorro')),
      body: savings.isEmpty
          ? const Center(child: Text('No tienes metas de ahorro aún'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: savings.length,
              itemBuilder: (context, index) {
                final goal = savings[index];
                return Dismissible(
                  key: Key(goal.id),
                  background: Container(color: Colors.red),
                  onDismissed: (_) {
                    Provider.of<FinanceProvider>(
                      context,
                      listen: false,
                    ).deleteSavingGoal(goal.id);
                  },
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                goal.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit, size: 20),
                                onPressed: () =>
                                    _showGoalModal(context, existingGoal: goal),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: goal.progress,
                            backgroundColor: Colors.grey[200],
                            color: Colors.indigo,
                            minHeight: 10,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '\$${goal.currentAmount.toStringAsFixed(0)} / \$${goal.targetAmount.toStringAsFixed(0)}',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              Text(
                                '${(goal.progress * 100).toStringAsFixed(1)}%',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () =>
                                  _showAddMoneyModal(context, goal),
                              icon: const Icon(Icons.add),
                              label: const Text('Abonar Dinero'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _showGoalModal(context),
      ),
    );
  }
}
