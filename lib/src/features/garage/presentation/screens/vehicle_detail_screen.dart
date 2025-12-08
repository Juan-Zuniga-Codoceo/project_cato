import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_filex/open_filex.dart';
import '../../domain/models/vehicle.dart';
import '../../domain/models/vehicle_document.dart';
import '../../../../core/providers/garage_provider.dart';

class VehicleDetailScreen extends StatefulWidget {
  final Vehicle vehicle;

  const VehicleDetailScreen({super.key, required this.vehicle});

  @override
  State<VehicleDetailScreen> createState() => _VehicleDetailScreenState();
}

class _VehicleDetailScreenState extends State<VehicleDetailScreen> {
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
          bottom: const TabBar(
            tabs: [
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
          onPressed: () => _showAddDocumentModal(context, vehicle.id),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildMaintenanceTab() {
    return const Center(child: Text('Mantenimiento (Placeholder)'));
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
