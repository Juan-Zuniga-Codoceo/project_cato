import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
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

                    // [FIX] Usamos .codePoint y .value para guardar en Hive
                    final newSub = Subscription(
                      id: isEditing
                          ? provider.subscriptions[index].id
                          : DateTime.now().toString(),
                      name: name,
                      price: price,
                      paymentDay: day,
                      iconCode:
                          Icons.credit_card.codePoint, // Default icon code
                      colorValue: Colors.blue.value, // Default color value
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
          // Header - Hero Image
          Stack(
            children: [
              Container(
                height: 180,
                width: double.infinity,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/module_finance.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                  ),
                ),
              ),
              Positioned(
                bottom: 20,
                left: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'COSTOS FIJOS',
                      style: GoogleFonts.spaceMono(
                        color: Colors.amber,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${provider.totalMonthlySubscriptions.toStringAsFixed(0)}',
                      style: GoogleFonts.spaceMono(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
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

                      // Calculate progress to next payment
                      final now = DateTime.now();
                      final daysInMonth = DateTime(
                        now.year,
                        now.month + 1,
                        0,
                      ).day;
                      final progress = (now.day / daysInMonth).clamp(0.0, 1.0);

                      // Determine next payment date text
                      String nextPaymentText;
                      if (now.day > sub.paymentDay) {
                        nextPaymentText =
                            'Próximo: ${sub.paymentDay}/${now.month + 1}';
                      } else {
                        nextPaymentText =
                            'Próximo: ${sub.paymentDay}/${now.month}';
                      }

                      return Dismissible(
                        key: Key(sub.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.red.withOpacity(0.5),
                            ),
                          ),
                          child: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                        ),
                        onDismissed: (direction) {
                          provider.removeSubscription(sub.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${sub.name} eliminado')),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E1E1E), // Dark Surface
                            borderRadius: BorderRadius.circular(12),
                            border: Border(
                              left: BorderSide(
                                // [FIX] Usamos el getter .color
                                color: sub.color,
                                width: 4,
                              ),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: InkWell(
                            onTap: () =>
                                _showAddEditModal(context, index: index),
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  // Row Superior: Nombre y Precio
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        sub.name.toUpperCase(),
                                        style: GoogleFonts.spaceMono(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        '\$${sub.price.toStringAsFixed(0)}',
                                        style: GoogleFonts.spaceMono(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  // Row Inferior: Info Pago + Progreso
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today,
                                        size: 14,
                                        color: Colors.grey[400],
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        nextPaymentText,
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          color: Colors.grey[400],
                                        ),
                                      ),
                                      const Spacer(),
                                      SizedBox(
                                        width: 60,
                                        child: LinearProgressIndicator(
                                          value: progress,
                                          backgroundColor: Colors.grey[800],
                                          // [FIX] Usamos el getter .color
                                          color: sub.color,
                                          minHeight: 4,
                                          borderRadius: BorderRadius.circular(
                                            2,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
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
