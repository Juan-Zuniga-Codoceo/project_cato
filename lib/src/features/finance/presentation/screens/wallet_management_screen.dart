import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/providers/finance_provider.dart';
import '../../domain/models/wallet_card.dart';
import 'card_detail_screen.dart';

class WalletManagementScreen extends StatefulWidget {
  const WalletManagementScreen({super.key});

  @override
  State<WalletManagementScreen> createState() => _WalletManagementScreenState();
}

class _WalletManagementScreenState extends State<WalletManagementScreen> {
  void _showAddCardDialog(BuildContext context, {WalletCard? cardToEdit}) {
    final provider = Provider.of<FinanceProvider>(context, listen: false);
    final isEditing = cardToEdit != null;

    // Controladores pre-llenados si es edición
    final nameController = TextEditingController(text: cardToEdit?.name ?? '');
    String selectedBank = cardToEdit?.bankName ?? 'Banco Falabella';
    String selectedType = cardToEdit?.type ?? 'credit';
    int paymentDay = cardToEdit?.paymentDay ?? 5;
    double initialBalance = cardToEdit?.initialBalance ?? 0.0;
    double limit = cardToEdit?.limit ?? 0.0;
    int selectedColor = cardToEdit?.colorValue ?? Colors.blue.value;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  isEditing ? 'EDITAR TARJETA' : 'NUEVA TARJETA',
                  style: GoogleFonts.spaceMono(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // Banco
                DropdownButtonFormField<String>(
                  value: selectedBank,
                  items: provider.chileanBanks
                      .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                      .toList(),
                  onChanged: (v) => setState(() => selectedBank = v!),
                  decoration: const InputDecoration(
                    labelText: 'Banco',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),

                // Nombre (Apodo)
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Apodo (Ej: CMR Black)',
                    hintText: 'Nombre único para identificarla',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),

                // Tipo (solo mostrar en creación)
                if (!isEditing)
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Text('Crédito'),
                          selected: selectedType == 'credit',
                          onSelected: (s) =>
                              setState(() => selectedType = 'credit'),
                          selectedColor: Colors.cyanAccent,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ChoiceChip(
                          label: const Text('Débito/Vista'),
                          selected: selectedType == 'debit',
                          onSelected: (s) =>
                              setState(() => selectedType = 'debit'),
                          selectedColor: Colors.greenAccent,
                        ),
                      ),
                    ],
                  ),

                // Día de Pago (Solo Crédito)
                if (selectedType == 'credit') ...[
                  const SizedBox(height: 12),
                  Text(
                    'Día de Pago Mensual: $paymentDay',
                    style: GoogleFonts.spaceMono(),
                  ),
                  Slider(
                    value: paymentDay.toDouble(),
                    min: 1,
                    max: 31,
                    divisions: 30,
                    activeColor: Colors.cyanAccent,
                    onChanged: (v) => setState(() => paymentDay = v.toInt()),
                  ),

                  // [NUEVO] Cupo/Límite para Crédito
                  const SizedBox(height: 12),
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Cupo Total (Límite)',
                      hintText: 'Ej: 500000',
                      prefixText: '\$',
                      prefixIcon: Icon(Icons.speed),
                      border: OutlineInputBorder(),
                    ),
                    controller: TextEditingController(
                      text: limit > 0 ? limit.toStringAsFixed(0) : '',
                    ),
                    onChanged: (v) => limit = double.tryParse(v) ?? 0.0,
                  ),
                ],

                // Saldo Inicial (Solo Débito/Vista)
                if (selectedType == 'debit') ...[
                  const SizedBox(height: 12),
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Saldo Inicial',
                      hintText: 'Ej: 50000',
                      prefixText: '\$',
                      border: OutlineInputBorder(),
                    ),
                    controller: TextEditingController(
                      text: initialBalance > 0
                          ? initialBalance.toStringAsFixed(0)
                          : '',
                    ),
                    onChanged: (v) =>
                        initialBalance = double.tryParse(v) ?? 0.0,
                  ),
                ],

                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.isNotEmpty) {
                      if (isEditing) {
                        // Editar tarjeta existente
                        provider.editCard(
                          cardToEdit!.id,
                          nameController.text,
                          selectedBank,
                          limit,
                          selectedColor,
                          initialBalance,
                          paymentDay,
                        );
                      } else {
                        // Crear nueva tarjeta
                        final newCard = WalletCard(
                          id: DateTime.now().toString(),
                          name: nameController.text,
                          bankName: selectedBank,
                          type: selectedType,
                          paymentDay: selectedType == 'credit' ? paymentDay : 0,
                          limit: selectedType == 'credit' ? limit : 0,
                          colorValue: selectedType == 'credit'
                              ? Colors.cyan.value
                              : Colors.green.value,
                          initialBalance: initialBalance,
                        );
                        provider.addCard(newCard);
                      }
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    isEditing ? 'GUARDAR CAMBIOS' : 'AGREGAR AL SISTEMA',
                    style: GoogleFonts.spaceMono(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FinanceProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('BILLETERA TÁCTICA')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.myCards.length,
        itemBuilder: (context, index) {
          final card = provider.myCards[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Icon(
                card.isCredit
                    ? Icons.credit_card
                    : Icons.account_balance_wallet,
                color: card.isCredit ? Colors.cyan : Colors.green,
                size: 32,
              ),
              title: Text(
                card.name,
                style: GoogleFonts.spaceMono(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '${card.bankName} • ${card.isCredit ? "Crédito (Paga el ${card.paymentDay})" : "Débito/Vista"}',
              ),
              // [CAMBIO] Navegación al detalle de tarjeta
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CardDetailScreen(card: card),
                  ),
                );
              },
              // [NUEVO] Botones: Editar, Estrella, Eliminar
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () =>
                        _showAddCardDialog(context, cardToEdit: card),
                  ),
                  IconButton(
                    icon: Icon(
                      card.isFavorite ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                    ),
                    onPressed: () => provider.toggleCardFavorite(card.id),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => provider.deleteCard(card.id),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddCardDialog(context),
        label: const Text('NUEVA TARJETA'),
        icon: const Icon(Icons.add_card),
        backgroundColor: Colors.cyanAccent,
      ),
    );
  }
}
