import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../../../core/providers/garage_provider.dart';
import '../../../../core/providers/finance_provider.dart';
import '../../domain/models/vehicle.dart';
import '../../domain/models/maintenance.dart';
import '../../../finance/domain/models/transaction.dart';
import '../../../finance/domain/models/category.dart';
import 'vehicle_detail_screen.dart';

class GarageScreen extends StatefulWidget {
  const GarageScreen({super.key});

  @override
  State<GarageScreen> createState() => _GarageScreenState();
}

class _GarageScreenState extends State<GarageScreen> {
  int _selectedVehicleIndex = 0;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToIndex(int index) {
    if (!_scrollController.hasClients) return;

    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.85;
    final itemWidth = cardWidth + 16;
    final padding = 16.0;

    final offset =
        (padding + index * itemWidth) - (screenWidth - cardWidth) / 2;

    _scrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _showAddVehicleModal(BuildContext context, {Vehicle? vehicleToEdit}) {
    final nameController = TextEditingController(text: vehicleToEdit?.name);
    final brandController = TextEditingController(text: vehicleToEdit?.brand);
    final modelController = TextEditingController(text: vehicleToEdit?.model);
    final yearController = TextEditingController(
      text: vehicleToEdit?.year.toString(),
    );
    final mileageController = TextEditingController(
      text: vehicleToEdit?.currentMileage.toStringAsFixed(0),
    );
    final plateController = TextEditingController(text: vehicleToEdit?.plate);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
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
                vehicleToEdit != null ? 'Editar Vehículo' : 'Nuevo Vehículo',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Apodo (ej: La Bestia)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.directions_car),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: brandController,
                      decoration: const InputDecoration(
                        labelText: 'Marca',
                        border: OutlineInputBorder(),
                      ),
                      textCapitalization: TextCapitalization.words,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: modelController,
                      decoration: const InputDecoration(
                        labelText: 'Modelo',
                        border: OutlineInputBorder(),
                      ),
                      textCapitalization: TextCapitalization.words,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: yearController,
                      decoration: const InputDecoration(
                        labelText: 'Año',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: plateController,
                      decoration: const InputDecoration(
                        labelText: 'Placa',
                        border: OutlineInputBorder(),
                      ),
                      textCapitalization: TextCapitalization.characters,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: mileageController,
                decoration: const InputDecoration(
                  labelText: 'Kilometraje Actual',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.speed),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (nameController.text.isNotEmpty &&
                      brandController.text.isNotEmpty) {
                    final vehicle = Vehicle(
                      id: vehicleToEdit?.id ?? DateTime.now().toString(),
                      name: nameController.text.trim(),
                      brand: brandController.text.trim(),
                      model: modelController.text.trim(),
                      year: int.tryParse(yearController.text.trim()) ?? 2020,
                      currentMileage:
                          double.tryParse(mileageController.text.trim()) ?? 0,
                      plate: plateController.text.trim(),
                      imagePath: vehicleToEdit?.imagePath,
                    );

                    if (vehicleToEdit != null) {
                      Provider.of<GarageProvider>(
                        context,
                        listen: false,
                      ).updateVehicle(vehicle);
                    } else {
                      Provider.of<GarageProvider>(
                        context,
                        listen: false,
                      ).addVehicle(vehicle);
                    }
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  vehicleToEdit != null
                      ? 'Guardar Cambios'
                      : 'Guardar Vehículo',
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showAddMaintenanceModal(BuildContext context, Vehicle vehicle) {
    final typeController = TextEditingController();
    final costController = TextEditingController();
    final notesController = TextEditingController();
    final mileageController = TextEditingController(
      text: vehicle.currentMileage.toStringAsFixed(0),
    );
    DateTime selectedDate = DateTime.now();
    bool addToFinance = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
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
                    'Nuevo Mantenimiento',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: typeController,
                    decoration: const InputDecoration(
                      labelText: 'Tipo (ej: Cambio de Aceite)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.build),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: costController,
                          decoration: const InputDecoration(
                            labelText: 'Costo',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.attach_money),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
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
                  const SizedBox(height: 16),
                  TextField(
                    controller: mileageController,
                    decoration: const InputDecoration(
                      labelText: 'Kilometraje',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.speed),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notas (Opcional)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.note),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Registrar como Gasto'),
                    subtitle: const Text('Agregar a Finanzas'),
                    value: addToFinance,
                    onChanged: (value) {
                      setModalState(() {
                        addToFinance = value;
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      if (typeController.text.isNotEmpty) {
                        final cost =
                            double.tryParse(costController.text.trim()) ?? 0;
                        final mileage =
                            double.tryParse(mileageController.text.trim()) ?? 0;

                        final maintenance = Maintenance(
                          id: DateTime.now().toString(),
                          vehicleId: vehicle.id,
                          type: typeController.text.trim(),
                          date: selectedDate,
                          mileage: mileage,
                          cost: cost,
                          notes: notesController.text.trim(),
                        );

                        final garageProvider = Provider.of<GarageProvider>(
                          context,
                          listen: false,
                        );
                        garageProvider.addMaintenance(maintenance);

                        if (mileage > vehicle.currentMileage) {
                          garageProvider.updateVehicle(
                            vehicle.copyWith(currentMileage: mileage),
                          );
                        }

                        if (addToFinance && cost > 0) {
                          final financeProvider = Provider.of<FinanceProvider>(
                            context,
                            listen: false,
                          );

                          CategoryModel? transportCategory;
                          try {
                            transportCategory = financeProvider.categories
                                .firstWhere(
                                  (c) =>
                                      c.name.toLowerCase().contains(
                                        'transporte',
                                      ) ||
                                      c.name.toLowerCase().contains('auto'),
                                );
                          } catch (e) {
                            if (financeProvider.categories.isNotEmpty) {
                              transportCategory =
                                  financeProvider.categories.first;
                            }
                          }

                          if (transportCategory != null) {
                            financeProvider.addTransaction(
                              Transaction(
                                id: DateTime.now().toString(),
                                title:
                                    '${typeController.text} (${vehicle.name})',
                                amount: cost,
                                date: selectedDate,
                                isExpense: true,
                                category: transportCategory,
                              ),
                            );
                          }
                        }

                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Guardar Mantenimiento'),
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

  Future<void> _pickVehiclePhoto(BuildContext context, Vehicle vehicle) async {
    showModalBottomSheet(
      context: context,
      builder: (modalContext) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Cámara'),
              onTap: () async {
                Navigator.pop(modalContext);
                print('📸 Iniciando selección de foto de vehículo (Cámara)...');

                String? imagePath;

                if (Platform.isAndroid || Platform.isIOS) {
                  // Mobile: Use ImagePicker with Camera
                  print('📱 Plataforma móvil: usando ImagePicker.camera');
                  final ImagePicker picker = ImagePicker();
                  final XFile? image = await picker.pickImage(
                    source: ImageSource.camera,
                    maxWidth: 1024,
                    maxHeight: 1024,
                    imageQuality: 85,
                  );
                  imagePath = image?.path;
                } else {
                  // Desktop: Use FilePicker (camera not supported)
                  print('🖥️ Plataforma desktop: usando FilePicker');
                  final result = await FilePicker.platform.pickFiles(
                    type: FileType.any,
                  );
                  print('🖥️ FilePicker Result: ${result?.files.single.path}');
                  imagePath = result?.files.single.path;
                }

                if (imagePath != null && mounted) {
                  print('📸 Imagen seleccionada: $imagePath');
                  Provider.of<GarageProvider>(
                    context,
                    listen: false,
                  ).updateVehiclePhoto(vehicle.id, imagePath);
                } else {
                  print(
                    '❌ No se seleccionó ninguna imagen o widget desmontado',
                  );
                  print('   imagePath: $imagePath, mounted: $mounted');
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galería'),
              onTap: () async {
                Navigator.pop(modalContext);
                print(
                  '📸 Iniciando selección de foto de vehículo (Galería)...',
                );

                String? imagePath;

                if (Platform.isAndroid || Platform.isIOS) {
                  // Mobile: Use ImagePicker with Gallery
                  print('📱 Plataforma móvil: usando ImagePicker.gallery');
                  final ImagePicker picker = ImagePicker();
                  final XFile? image = await picker.pickImage(
                    source: ImageSource.gallery,
                    maxWidth: 1024,
                    maxHeight: 1024,
                    imageQuality: 85,
                  );
                  imagePath = image?.path;
                } else {
                  // Desktop: Use FilePicker
                  print('🖥️ Plataforma desktop: usando FilePicker');
                  final result = await FilePicker.platform.pickFiles(
                    type: FileType.any,
                  );
                  print('🖥️ FilePicker Result: ${result?.files.single.path}');
                  imagePath = result?.files.single.path;
                }

                if (imagePath != null && mounted) {
                  print('📸 Imagen seleccionada: $imagePath');
                  Provider.of<GarageProvider>(
                    context,
                    listen: false,
                  ).updateVehiclePhoto(vehicle.id, imagePath);
                } else {
                  print(
                    '❌ No se seleccionó ninguna imagen o widget desmontado',
                  );
                  print('   imagePath: $imagePath, mounted: $mounted');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Garaje Digital')),
      body: Consumer<GarageProvider>(
        builder: (context, provider, child) {
          if (provider.vehicles.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.directions_car,
                    size: 80,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Tu garaje está vacío',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: () => _showAddVehicleModal(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar Vehículo'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          final vehicle = provider.vehicles[_selectedVehicleIndex];
          final maintenances = provider.getMaintenanceForVehicle(vehicle.id);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 260,
                child: ListView.builder(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  itemCount: provider.vehicles.length,
                  itemBuilder: (context, index) {
                    final v = provider.vehicles[index];
                    final isSelected = index == _selectedVehicleIndex;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedVehicleIndex = index;
                        });
                        _scrollToIndex(index);
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.85,
                        margin: const EdgeInsets.only(right: 16),
                        child: Card(
                          elevation: isSelected ? 8 : 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: isSelected
                                ? const BorderSide(
                                    color: Colors.indigo,
                                    width: 2,
                                  )
                                : BorderSide.none,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isSelected
                                    ? [
                                        Colors.blueGrey[800]!,
                                        Colors.blueGrey[900]!,
                                      ]
                                    : [Colors.grey[800]!, Colors.grey[900]!],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    v.imagePath != null &&
                                            File(v.imagePath!).existsSync()
                                        ? Container(
                                            width: 60,
                                            height: 60,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: Colors.white24,
                                                width: 1,
                                              ),
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(11),
                                              child: Image.file(
                                                File(v.imagePath!),
                                                width: 60,
                                                height: 60,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          )
                                        : Container(
                                            width: 60,
                                            height: 60,
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(
                                                0.2,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Icon(
                                              Icons.directions_car,
                                              color: Colors.white.withOpacity(
                                                0.8,
                                              ),
                                              size: 32,
                                            ),
                                          ),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                            Icons.folder_shared,
                                            color: Colors.white,
                                          ),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    VehicleDetailScreen(
                                                      vehicle: v,
                                                    ),
                                              ),
                                            );
                                          },
                                          tooltip: 'Documentos',
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.camera_alt,
                                            color: Colors.white,
                                          ),
                                          onPressed: () =>
                                              _pickVehiclePhoto(context, v),
                                          tooltip: 'Cambiar foto',
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withOpacity(
                                              0.5,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: Colors.white.withOpacity(
                                                0.3,
                                              ),
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(
                                                  0.2,
                                                ),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Text(
                                            v.plate.toUpperCase(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 2.0,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.edit,
                                            color: Colors.white,
                                          ),
                                          onPressed: () => _showAddVehicleModal(
                                            context,
                                            vehicleToEdit: v,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                Text(
                                  v.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${v.brand} ${v.model} (${v.year})',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.speed,
                                      color: Colors.orange,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${NumberFormat('#,###').format(v.currentMileage)} km',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
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

              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Historial de Mantenimiento',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle, color: Colors.indigo),
                      onPressed: () =>
                          _showAddMaintenanceModal(context, vehicle),
                      tooltip: 'Registrar Mantenimiento',
                    ),
                  ],
                ),
              ),

              Expanded(
                child: maintenances.isEmpty
                    ? Center(
                        child: Text(
                          'No hay registros de mantenimiento',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: maintenances.length,
                        itemBuilder: (context, index) {
                          final m = maintenances[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.orange.withOpacity(0.1),
                                child: const Icon(
                                  Icons.build,
                                  color: Colors.orange,
                                ),
                              ),
                              title: Text(
                                m.type,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                '${DateFormat('dd/MM/yyyy').format(m.date)} • ${NumberFormat('#,###').format(m.mileage)} km',
                              ),
                              trailing: Text(
                                '\$${NumberFormat('#,###').format(m.cost)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: Consumer<GarageProvider>(
        builder: (context, provider, child) {
          return provider.vehicles.isNotEmpty
              ? FloatingActionButton(
                  onPressed: () => _showAddVehicleModal(context),
                  backgroundColor: Colors.indigo,
                  child: const Icon(Icons.add, color: Colors.white),
                )
              : const SizedBox.shrink();
        },
      ),
    );
  }
}
