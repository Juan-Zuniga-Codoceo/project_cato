import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:google_fonts/google_fonts.dart';
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
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
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
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
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

  void _confirmDeleteVehicle(BuildContext context, Vehicle vehicle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Vender/Eliminar Vehículo?'),
        content: Text(
          'Se borrará "${vehicle.name}" y todo su historial de mantenimiento.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<GarageProvider>(
                context,
                listen: false,
              ).deleteVehicle(vehicle.id);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text(
              'ELIMINAR',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('GARAJE DIGITAL')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddVehicleModal(context),
        backgroundColor: theme.colorScheme.primary,
        child: const Icon(Icons.add),
      ),
      body: Consumer<GarageProvider>(
        builder: (context, provider, child) {
          if (provider.vehicles.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Placeholder Image (Gato Mecánico)
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.colorScheme.primary.withOpacity(0.5),
                        width: 2,
                      ),
                      image: const DecorationImage(
                        image: AssetImage(
                          'assets/avatars/hero_3.jpg',
                        ), // Using existing asset as placeholder
                        fit: BoxFit.cover,
                        opacity: 0.8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Tu garaje está vacío',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '¡Trae las máquinas!',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () => _showAddVehicleModal(context),
                    icon: const Icon(Icons.add),
                    label: const Text('AGREGAR VEHÍCULO'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
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
              Container(
                height: 140,
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  image: const DecorationImage(
                    image: AssetImage('assets/images/module_garage.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Theme.of(context).scaffoldBackgroundColor,
                        Colors.transparent,
                      ],
                    ),
                  ),
                  alignment: Alignment.bottomLeft,
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    "TALLER MECÁNICO",
                    style: GoogleFonts.spaceMono(
                      color: Colors.orangeAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      letterSpacing: 2.0,
                    ),
                  ),
                ),
              ),
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
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: isSelected
                                ? BorderSide(
                                    color: theme.colorScheme.primary,
                                    width: 2,
                                  )
                                : BorderSide(
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.1),
                                  ),
                          ),
                          child: Stack(
                            children: [
                              // CONTENIDO PRINCIPAL
                              Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Fila Superior: Foto + Botones Funcionales
                                    Row(
                                      children: [
                                        // Foto del Vehículo
                                        Container(
                                          width: 60,
                                          height: 60,
                                          decoration: BoxDecoration(
                                            color: theme.colorScheme.surface,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color: theme.colorScheme.onSurface
                                                  .withOpacity(0.2),
                                            ),
                                          ),
                                          child:
                                              v.imagePath != null &&
                                                  File(
                                                    v.imagePath!,
                                                  ).existsSync()
                                              ? ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(11),
                                                  child: Image.file(
                                                    File(v.imagePath!),
                                                    fit: BoxFit.cover,
                                                  ),
                                                )
                                              : Icon(
                                                  Icons.directions_car,
                                                  color: theme
                                                      .colorScheme
                                                      .onSurface
                                                      .withOpacity(0.5),
                                                ),
                                        ),
                                        const SizedBox(width: 12),
                                        // Botones de Acción (Docs, Camara, Editar)
                                        Expanded(
                                          child: Wrap(
                                            // Usamos Wrap para evitar overflow si la pantalla es chica
                                            spacing: 0,
                                            children: [
                                              IconButton(
                                                icon: Icon(
                                                  Icons.folder_shared,
                                                  color:
                                                      theme.colorScheme.primary,
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
                                              ),
                                              IconButton(
                                                icon: Icon(
                                                  Icons.camera_alt,
                                                  color:
                                                      theme.colorScheme.primary,
                                                ),
                                                onPressed: () =>
                                                    _pickVehiclePhoto(
                                                      context,
                                                      v,
                                                    ),
                                              ),
                                              IconButton(
                                                icon: Icon(
                                                  Icons.edit,
                                                  color: theme
                                                      .colorScheme
                                                      .onSurface
                                                      .withOpacity(0.5),
                                                ),
                                                onPressed: () =>
                                                    _showAddVehicleModal(
                                                      context,
                                                      vehicleToEdit: v,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Spacer(),
                                    const SizedBox(height: 12),
                                    // Placa y Nombre
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.black,
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                            border: Border.all(
                                              color: Colors.amber,
                                              width: 1,
                                            ),
                                          ),
                                          child: Text(
                                            v.plate.toUpperCase(),
                                            style: GoogleFonts.spaceMono(
                                              color: Colors.amber,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1.5,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      v.name,
                                      style: theme.textTheme.headlineMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      '${v.brand} ${v.model} (${v.year})',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(color: Colors.grey),
                                    ),
                                    const SizedBox(height: 8),
                                    // Kilometraje
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.speed,
                                          color: theme.colorScheme.secondary,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          '${NumberFormat('#,###').format(v.currentMileage)} km',
                                          style: GoogleFonts.spaceMono(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // BOTÓN ELIMINAR (POSICIONADO ABSOLUTO ARRIBA DERECHA)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(20),
                                    onTap: () =>
                                        _confirmDeleteVehicle(context, v),
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      child: Icon(
                                        Icons.delete_outline,
                                        color: Colors.red.withOpacity(0.7),
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
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
                    Text(
                      'HISTORIAL DE MANTENIMIENTO',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () =>
                          _showAddMaintenanceModal(context, vehicle),
                      icon: const Icon(Icons.add),
                      label: const Text('REGISTRAR'),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: maintenances.isEmpty
                    ? Center(
                        child: Text(
                          'Sin registros de mantenimiento',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: maintenances.length,
                        itemBuilder: (context, index) {
                          final m = maintenances[index];
                          return Card(
                            // Inherits theme
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: theme.colorScheme.primary
                                    .withOpacity(0.2),
                                child: Icon(
                                  Icons.build,
                                  color: theme.colorScheme.primary,
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                m.type,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                '${DateFormat('dd/MM/yyyy').format(m.date)} • ${NumberFormat('#,###').format(m.mileage)} km',
                                style: theme.textTheme.bodySmall,
                              ),
                              trailing: Text(
                                '\$${NumberFormat('#,###').format(m.cost)}',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme
                                      .colorScheme
                                      .error, // Cost is usually negative/expense
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
    );
  }
}
