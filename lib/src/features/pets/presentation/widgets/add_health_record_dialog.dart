import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/pet_provider.dart';
import '../../domain/models/pet_model.dart';
import '../../../../core/providers/finance_provider.dart';

class AddHealthRecordDialog extends StatefulWidget {
  final String petId;
  final HealthRecordModel? recordToEdit; // [NUEVO]

  const AddHealthRecordDialog({
    super.key,
    required this.petId,
    this.recordToEdit,
  });

  @override
  State<AddHealthRecordDialog> createState() => _AddHealthRecordDialogState();
}

class _AddHealthRecordDialogState extends State<AddHealthRecordDialog> {
  final _descController = TextEditingController();
  final _costController = TextEditingController();
  String _type = 'Control';
  DateTime _date = DateTime.now();
  bool _createExpense = true;
  String? _selectedPaymentMethod;
  bool _isLoading = false;

  List<String> _types = [
    'Vacuna',
    'Control',
    'Cirugía',
    'Medicamento',
    'Alimento',
    'Otro',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.petId == 'general_supplies') {
      _types = [
        'Alimento',
        'Arena',
        'Juguetes',
        'Accesorios',
        'Medicamento',
        'Otro',
      ];
      _type = 'Alimento';
    }

    if (widget.recordToEdit != null) {
      _type = widget.recordToEdit!.type;
      _descController.text = widget.recordToEdit!.description;
      _costController.text = widget.recordToEdit!.cost > 0
          ? widget.recordToEdit!.cost.toStringAsFixed(0)
          : '';
      _date = widget.recordToEdit!.date;
      _createExpense = widget.recordToEdit!.transactionId != null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final financeProvider = Provider.of<FinanceProvider>(context);
    final paymentMethods = financeProvider.getAvailablePaymentMethods();

    // Set default payment method if not set
    if (_selectedPaymentMethod == null && paymentMethods.isNotEmpty) {
      _selectedPaymentMethod = paymentMethods.first;
    }

    return AlertDialog(
      title: Text(
        widget.recordToEdit != null
            ? 'Editar Registro'
            : 'Registro Médico / Gasto',
        style: GoogleFonts.spaceMono(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: _type,
              decoration: const InputDecoration(labelText: 'Tipo'),
              items: _types.map((t) {
                return DropdownMenuItem(value: t, child: Text(t));
              }).toList(),
              onChanged: (v) => setState(() => _type = v!),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(labelText: 'Descripción'),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _costController,
              decoration: const InputDecoration(
                labelText: 'Costo',
                prefixText: '\$ ',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Fecha'),
              subtitle: Text('${_date.day}/${_date.month}/${_date.year}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (picked != null) setState(() => _date = picked);
              },
            ),
            const Divider(),
            SwitchListTile(
              title: const Text('Registrar en Finanzas'),
              subtitle: const Text('Descontar de billetera'),
              value: _createExpense,
              onChanged: (v) => setState(() => _createExpense = v),
            ),
            if (_createExpense)
              DropdownButtonFormField<String>(
                value: _selectedPaymentMethod,
                decoration: const InputDecoration(labelText: 'Método de Pago'),
                items: paymentMethods.map((m) {
                  return DropdownMenuItem(value: m, child: Text(m));
                }).toList(),
                onChanged: (v) => setState(() => _selectedPaymentMethod = v),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCELAR'),
        ),
        ElevatedButton(
          onPressed: _isLoading
              ? null
              : () async {
                  if (_descController.text.isNotEmpty) {
                    setState(() => _isLoading = true);
                    try {
                      final cost = double.tryParse(_costController.text) ?? 0.0;
                      final record = HealthRecordModel(
                        id:
                            widget.recordToEdit?.id ??
                            DateTime.now().millisecondsSinceEpoch.toString(),
                        date: _date,
                        description: _descController.text,
                        cost: cost,
                        type: _type,
                        transactionId: widget.recordToEdit?.transactionId,
                      );

                      if (widget.recordToEdit != null) {
                        await Provider.of<PetProvider>(
                          context,
                          listen: false,
                        ).updateHealthRecord(
                          petId: widget.petId,
                          record: record,
                          financeProvider: financeProvider,
                        );
                      } else {
                        await Provider.of<PetProvider>(
                          context,
                          listen: false,
                        ).addHealthRecord(
                          petId: widget.petId,
                          record: record,
                          financeProvider: _createExpense
                              ? financeProvider
                              : null,
                          paymentMethod: _selectedPaymentMethod,
                        );
                      }

                      if (mounted) Navigator.pop(context);
                    } finally {
                      if (mounted) setState(() => _isLoading = false);
                    }
                  }
                },
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.recordToEdit != null ? 'GUARDAR' : 'AGREGAR'),
        ),
      ],
    );
  }
}
