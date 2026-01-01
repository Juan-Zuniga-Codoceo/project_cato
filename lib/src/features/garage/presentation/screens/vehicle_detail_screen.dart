import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_filex/open_filex.dart';
import '../../domain/models/vehicle.dart';
import '../../domain/models/vehicle_document.dart';
import '../../domain/models/maintenance.dart';
import '../../../../core/providers/garage_provider.dart';
import '../../../../core/providers/finance_provider.dart';
import '../../../../shared/widgets/payment_method_dropdown.dart';
import '../../../finance/domain/models/transaction.dart';

class VehicleDetailScreen extends StatefulWidget {
  final Vehicle vehicle;

  const VehicleDetailScreen({super.key, required this.vehicle});

  @override
  State<VehicleDetailScreen> createState() => _VehicleDetailScreenState();
}

class _VehicleDetailScreenState extends State<VehicleDetailScreen> {
  int _currentTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Consume provider to get updates
    final vehicle =
        context.select<GarageProvider, Vehicle?>(
          (provider) => provider.vehicles
              .where((v) => v.id == widget.vehicle.id)
              .firstOrNull,
        ) ??
        widget.vehicle;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(vehicle.name),
          bottom: TabBar(
            onTap: (index) {
              setState(() {
                _currentTabIndex = index;
              });
            },
            tabs: const [
              Tab(text: 'Mantenimiento'),
              Tab(text: 'Documentos'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildMaintenanceTab(),
            _buildDocumentsTab(context, vehicle),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: _currentTabIndex == 0 ? Colors.orange : Colors.blue,
          onPressed: () => _currentTabIndex == 0
              ? _showAddMaintenanceModal(context, vehicle.id)
              : _showAddDocumentModal(context, vehicle.id),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildMaintenanceTab() {
    final provider = context.watch<GarageProvider>();
    final maintenances = provider.getMaintenanceForVehicle(widget.vehicle.id);

    if (maintenances.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.build, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Sin registros de mantenimiento'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: maintenances.length,
      itemBuilder: (context, index) {
        final maintenance = maintenances[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.orange,
              child: Icon(Icons.build, color: Colors.white),
            ),
            title: Text(
              maintenance.type,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${DateFormat('dd/MM/yyyy').format(maintenance.date)} • ${maintenance.mileage.toStringAsFixed(0)} km',
                ),
                Text(
                  'Costo: \$${maintenance.cost.toStringAsFixed(0)} (${maintenance.paymentMethod})',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  Widget _buildDocumentsTab(BuildContext context, Vehicle vehicle) {
    if (vehicle.documents.isEmpty) {
      return const Center(child: Text('No hay documentos guardados.'));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: vehicle.documents.length,
      itemBuilder: (context, index) {
        final doc = vehicle.documents[index];
        return _DocumentCard(
          document: doc,
          onDelete: () => _deleteDocument(context, vehicle.id, doc.id),
        );
      },
    );
  }

  void _deleteDocument(BuildContext context, String vehicleId, String docId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Documento'),
        content: const Text(
          '¿Estás seguro de que quieres eliminar este documento?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<GarageProvider>(
                context,
                listen: false,
              ).deleteDocument(vehicleId, docId);
              Navigator.pop(context);
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAddDocumentModal(BuildContext context, String vehicleId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _AddDocumentModal(vehicleId: vehicleId),
    );
  }

  void _showAddMaintenanceModal(BuildContext context, String vehicleId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _AddMaintenanceModal(vehicleId: vehicleId),
    );
  }
}

class _DocumentCard extends StatelessWidget {
  final VehicleDocument document;
  final VoidCallback onDelete;

  const _DocumentCard({required this.document, required this.onDelete});

  Color _getStatusColor() {
    if (document.expirationDate == null) return Colors.grey;

    final now = DateTime.now();
    final difference = document.expirationDate!.difference(now).inDays;

    if (difference < 0) {
      return Colors.red; // Expired
    } else if (difference < 30) {
      return Colors.orange; // Expiring soon
    } else {
      return Colors.green; // Valid
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final dateFormat = DateFormat('dd/MM/yyyy');
    final isPdf = document.imagePath.toLowerCase().endsWith('.pdf');

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: statusColor, width: 2),
      ),
      child: InkWell(
        onTap: () {
          OpenFilex.open(document.imagePath);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: isPdf
                  ? Container(
                      color: Colors.red.withOpacity(0.1),
                      child: const Center(
                        child: Icon(
                          Icons.picture_as_pdf,
                          size: 50,
                          color: Colors.red,
                        ),
                      ),
                    )
                  : Image.file(
                      File(document.imagePath),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Center(
                            child: Icon(Icons.broken_image, size: 40),
                          ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    document.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (document.expirationDate != null)
                    Text(
                      'Vence: ${dateFormat.format(document.expirationDate!)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: statusColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: const Icon(
                        Icons.delete,
                        size: 20,
                        color: Colors.grey,
                      ),
                      onPressed: onDelete,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddDocumentModal extends StatefulWidget {
  final String vehicleId;

  const _AddDocumentModal({required this.vehicleId});

  @override
  State<_AddDocumentModal> createState() => _AddDocumentModalState();
}

class _AddDocumentModalState extends State<_AddDocumentModal> {
  final _nameController = TextEditingController();
  DateTime? _expirationDate;
  String? _imagePath;
  final _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _imagePath = result.files.single.path;
      });
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() {
        _expirationDate = picked;
      });
    }
  }

  void _save() {
    if (_nameController.text.isEmpty || _imagePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nombre e imagen son obligatorios')),
      );
      return;
    }

    final newDoc = VehicleDocument(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      imagePath: _imagePath!,
      dateAdded: DateTime.now(),
      expirationDate: _expirationDate,
    );

    Provider.of<GarageProvider>(
      context,
      listen: false,
    ).addDocument(widget.vehicleId, newDoc);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isPdf = _imagePath?.toLowerCase().endsWith('.pdf') ?? false;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Agregar Documento',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Nombre del Documento',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  _expirationDate == null
                      ? 'Sin fecha de vencimiento'
                      : 'Vence: ${DateFormat('dd/MM/yyyy').format(_expirationDate!)}',
                ),
              ),
              TextButton.icon(
                onPressed: _selectDate,
                icon: const Icon(Icons.calendar_today),
                label: const Text('Seleccionar'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_imagePath != null)
            SizedBox(
              height: 150,
              child: isPdf
                  ? Container(
                      color: Colors.red.withOpacity(0.1),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.picture_as_pdf,
                            size: 50,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _imagePath!.split('/').last,
                            style: const TextStyle(fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : Image.file(File(_imagePath!)),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.camera),
                icon: const Icon(Icons.camera_alt),
                label: const Text('Cámara'),
              ),
              ElevatedButton.icon(
                onPressed: _pickFile,
                icon: const Icon(Icons.upload_file),
                label: const Text('Subir Archivo'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _save,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Guardar Documento'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// [NUEVO] Modal para agregar mantenimiento
class _AddMaintenanceModal extends StatefulWidget {
  final String vehicleId;

  const _AddMaintenanceModal({required this.vehicleId});

  @override
  State<_AddMaintenanceModal> createState() => _AddMaintenanceModalState();
}

class _AddMaintenanceModalState extends State<_AddMaintenanceModal> {
  final _typeController = TextEditingController();
  final _costController = TextEditingController();
  final _mileageController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _selectedPaymentMethod = 'Efectivo';

  @override
  void dispose() {
    _typeController.dispose();
    _costController.dispose();
    _mileageController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_typeController.text.isEmpty ||
        _costController.text.isEmpty ||
        _mileageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tipo, costo y kilometraje son obligatorios'),
        ),
      );
      return;
    }

    final cost = double.tryParse(_costController.text);
    final mileage = double.tryParse(_mileageController.text);

    if (cost == null || mileage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Costo y kilometraje deben ser números válidos'),
        ),
      );
      return;
    }

    try {
      final newMaintenance = Maintenance(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        vehicleId: widget.vehicleId,
        type: _typeController.text,
        date: _selectedDate,
        mileage: mileage,
        cost: cost,
        notes: _notesController.text,
        paymentMethod: _selectedPaymentMethod,
      );

      // Guardar mantenimiento
      final garageProvider = Provider.of<GarageProvider>(
        context,
        listen: false,
      );
      garageProvider.addMaintenance(newMaintenance);

      // Crear transacción en finanzas si el costo > 0
      if (cost > 0 && context.mounted) {
        final financeProvider = Provider.of<FinanceProvider>(
          context,
          listen: false,
        );

        // Buscar categoría "Mantenimiento" o usar la primera disponible
        final categories = financeProvider.categories;
        var category = categories.firstWhere(
          (c) =>
              c.name.toLowerCase().contains('mantenimiento') ||
              c.name.toLowerCase().contains('vehículo'),
          orElse: () => categories.isNotEmpty
              ? categories.first
              : throw Exception('No hay categorías disponibles'),
        );

        final transaction = Transaction(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: 'Mantenimiento: ${_typeController.text}',
          amount: cost,
          isExpense: true,
          date: _selectedDate,
          category: category,
          paymentMethod: _selectedPaymentMethod,
        );

        await financeProvider.addTransaction(transaction);
      }

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Mantenimiento registrado: \$${cost.toStringAsFixed(0)}',
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Registrar Mantenimiento',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _typeController,
              decoration: const InputDecoration(
                labelText: 'Tipo de Mantenimiento',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.build),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _costController,
              decoration: const InputDecoration(
                labelText: 'Costo',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _mileageController,
              decoration: const InputDecoration(
                labelText: 'Kilometraje',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.speed),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notas (Opcional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Fecha: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                TextButton.icon(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() => _selectedDate = picked);
                    }
                  },
                  icon: const Icon(Icons.calendar_today),
                  label: const Text('Cambiar'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Selector de método de pago
            PaymentMethodDropdown(
              selectedMethod: _selectedPaymentMethod,
              onChanged: (method) {
                setState(() => _selectedPaymentMethod = method);
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.orange,
              ),
              child: const Text('Guardar Mantenimiento'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
