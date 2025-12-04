import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/finance_provider.dart';
import '../../domain/models/subscription.dart';

class SubscriptionsScreen extends StatelessWidget {
  const SubscriptionsScreen({super.key});

  void _showAddEditModal(BuildContext context, {int? index}) {
    final provider = Provider.of<FinanceProvider>(context, listen: false);
    final isEditing = index != null;

    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final dayController = TextEditingController();

    if (isEditing) {
      final sub = provider.subscriptions[index];
      nameController.text = sub.name;
      priceController.text = sub.price.toStringAsFixed(0);
      dayController.text = sub.paymentDay.toString();
    }

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
              isEditing ? 'Editar Suscripción' : 'Nueva Suscripción',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre (Ej: Netflix)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Precio Mensual',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: dayController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Día de Pago (1-31)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (nameController.text.isNotEmpty &&
                      priceController.text.isNotEmpty &&
                      dayController.text.isNotEmpty) {
                    final name = nameController.text;
                    final price = double.tryParse(priceController.text) ?? 0;
                    final day = int.tryParse(dayController.text) ?? 1;

                    final newSub = Subscription(
                      id: isEditing
                          ? provider.subscriptions[index].id
                          : DateTime.now().toString(),
                      name: name,
                      price: price,
                      paymentDay: day,
                      icon: Icons.credit_card,
                      color: Colors.blue,
                    );

                    if (isEditing) {
                      provider.updateSubscription(newSub);
                    } else {
                      provider.addSubscription(newSub);
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

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FinanceProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Suscripciones')),
      body: Column(
        children: [
          // Header - Total Monthly Expense
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple.shade700, Colors.purple.shade500],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Gasto Mensual Total',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  '\$${provider.totalMonthlySubscriptions.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // List of Subscriptions
          Expanded(
            child: provider.subscriptions.isEmpty
                ? const Center(child: Text('No tienes suscripciones aún'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.subscriptions.length,
                    itemBuilder: (context, index) {
                      final sub = provider.subscriptions[index];
                      return Dismissible(
                        key: Key('${sub.name}_$index'),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (direction) {
                          provider.removeSubscription(sub.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${sub.name} eliminado')),
                          );
                        },
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            onTap: () =>
                                _showAddEditModal(context, index: index),
                            leading: CircleAvatar(
                              backgroundColor:
                                  sub.color?.withOpacity(0.1) ??
                                  Colors.grey[200],
                              child: Icon(
                                sub.icon ?? Icons.credit_card,
                                color: sub.color ?? Colors.grey,
                              ),
                            ),
                            title: Text(
                              sub.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text('Día de pago: ${sub.paymentDay}'),
                            trailing: Text(
                              '\$${sub.price.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditModal(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
