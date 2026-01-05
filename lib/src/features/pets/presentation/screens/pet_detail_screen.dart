import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../domain/models/pet_model.dart';
import '../../providers/pet_provider.dart';
import '../widgets/add_health_record_dialog.dart';
import '../widgets/add_pet_dialog.dart'; // [NUEVO]
import '../../../../core/theme/app_theme.dart';

class PetDetailScreen extends StatelessWidget {
  final PetModel pet;

  const PetDetailScreen({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    // Watch provider to get updates
    final provider = Provider.of<PetProvider>(context);
    final updatedPet = provider.getPet(pet.id) ?? pet;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          updatedPet.name.toUpperCase(),
          style: GoogleFonts.spaceMono(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context, provider, updatedPet),
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => showDialog(
              context: context,
              builder: (context) => AddPetDialog(petToEdit: updatedPet),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showDialog(
          context: context,
          builder: (context) => AddHealthRecordDialog(petId: updatedPet.id),
        ),
        label: const Text('REGISTRAR'),
        icon: const Icon(Icons.add),
        backgroundColor: AppTheme.primary,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Profile
            Container(
              padding: const EdgeInsets.all(24),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                border: Border(
                  bottom: BorderSide(color: AppTheme.primary.withOpacity(0.3)),
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[800],
                    backgroundImage:
                        updatedPet.photoPath != null &&
                            File(updatedPet.photoPath!).existsSync()
                        ? FileImage(File(updatedPet.photoPath!))
                        : null,
                    child: updatedPet.photoPath == null
                        ? const Icon(Icons.pets, size: 40, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    updatedPet.name,
                    style: GoogleFonts.spaceMono(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (updatedPet.vetName != null &&
                      updatedPet.vetName!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.medical_services,
                            size: 16,
                            color: Colors.redAccent,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'VET: ${updatedPet.vetName}',
                            style: GoogleFonts.inter(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // Health Widgets
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: _HealthWidget(
                      label: 'ÚLTIMA VACUNA',
                      date: _getLastRecordDate(updatedPet, 'Vacuna'),
                      icon: Icons.vaccines,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _HealthWidget(
                      label: 'ÚLTIMO CONTROL',
                      date: _getLastRecordDate(updatedPet, 'Control'),
                      icon: Icons.monitor_heart,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),

            // History List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'HISTORIAL CLÍNICO & GASTOS',
                    style: GoogleFonts.spaceMono(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (updatedPet.healthHistory.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text('Sin registros.'),
                      ),
                    )
                  else
                    ...updatedPet.healthHistory.reversed.map((record) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => showDialog(
                            context: context,
                            builder: (context) => AddHealthRecordDialog(
                              petId: updatedPet.id,
                              recordToEdit: record,
                            ),
                          ),
                          onLongPress: () => _confirmDeleteRecord(
                            context,
                            provider,
                            updatedPet.id,
                            record,
                          ),
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _getTypeColor(
                                  record.type,
                                ).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                _getTypeIcon(record.type),
                                color: _getTypeColor(record.type),
                                size: 20,
                              ),
                            ),
                            title: Text(
                              record.type,
                              style: GoogleFonts.spaceMono(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(record.description),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  DateFormat('dd/MM/yy').format(record.date),
                                  style: GoogleFonts.inter(fontSize: 12),
                                ),
                                if (record.cost > 0)
                                  Text(
                                    '\$${record.cost.toStringAsFixed(0)}',
                                    style: GoogleFonts.spaceMono(
                                      color: Colors.redAccent,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  DateTime? _getLastRecordDate(PetModel pet, String type) {
    final records = pet.healthHistory.where((r) => r.type == type).toList();
    if (records.isEmpty) return null;
    records.sort((a, b) => b.date.compareTo(a.date));
    return records.first.date;
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'Vacuna':
        return Colors.blue;
      case 'Control':
        return Colors.green;
      case 'Cirugía':
        return Colors.red;
      case 'Medicamento':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'Vacuna':
        return Icons.vaccines;
      case 'Control':
        return Icons.monitor_heart;
      case 'Cirugía':
        return Icons.local_hospital;
      case 'Medicamento':
        return Icons.medication;
      case 'Alimento':
        return Icons.restaurant;
      default:
        return Icons.pets;
    }
  }

  void _confirmDelete(
    BuildContext context,
    PetProvider provider,
    PetModel pet,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar mascota?'),
        content: const Text('Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR'),
          ),
          TextButton(
            onPressed: () async {
              await provider.deletePet(pet.id);
              if (context.mounted) {
                Navigator.pop(context);
                Navigator.pop(context);
              }
            },
            child: const Text('ELIMINAR', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteRecord(
    BuildContext context,
    PetProvider provider,
    String petId,
    HealthRecordModel record,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar registro?'),
        content: const Text(
          'Si tiene un gasto asociado, también se eliminará.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR'),
          ),
          TextButton(
            onPressed: () async {
              await provider.deleteHealthRecord(petId, record.id);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('ELIMINAR', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _HealthWidget extends StatelessWidget {
  final String label;
  final DateTime? date;
  final IconData icon;
  final Color color;

  const _HealthWidget({
    required this.label,
    required this.date,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final daysAgo = date != null
        ? DateTime.now().difference(date!).inDays
        : null;
    final isAlert = daysAgo != null && daysAgo > 365; // Alert if > 1 year

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isAlert ? Colors.red : color.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: isAlert ? Colors.red : color),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.spaceMono(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isAlert ? Colors.red : Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            date != null ? DateFormat('dd MMM yyyy').format(date!) : 'N/A',
            style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          if (daysAgo != null)
            Text(
              'Hace $daysAgo días',
              style: GoogleFonts.inter(fontSize: 10, color: Colors.grey),
            ),
        ],
      ),
    );
  }
}
