import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../providers/social_provider.dart';
import '../../domain/models/person_model.dart';
import '../widgets/person_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

class AllyDetailScreen extends StatelessWidget {
  final PersonModel person;

  const AllyDetailScreen({super.key, required this.person});

  @override
  Widget build(BuildContext context) {
    // Watch provider to get updates (e.g. after registering contact)
    final provider = Provider.of<SocialProvider>(context);
    // Find the updated person object from the list to ensure reactivity
    final updatedPerson = provider.people.firstWhere(
      (p) => p.id == person.id,
      orElse: () => person,
    );

    final status = provider.getContactStatus(updatedPerson);
    final statusColor = provider.getStatusColor(status);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          updatedPerson.name.toUpperCase(),
          style: GoogleFonts.spaceMono(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => showDialog(
              context: context,
              builder: (context) =>
                  PersonDialog(provider: provider, person: updatedPerson),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context, provider, updatedPerson),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                border: Border(
                  bottom: BorderSide(
                    color: statusColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                children: [
                  Builder(
                    builder: (context) {
                      ImageProvider? avatarImage;
                      if (updatedPerson.photoPath != null &&
                          File(updatedPerson.photoPath!).existsSync()) {
                        avatarImage = FileImage(File(updatedPerson.photoPath!));
                      }

                      return CircleAvatar(
                        radius: 50,
                        backgroundColor: statusColor.withOpacity(0.1),
                        backgroundImage: avatarImage,
                        child: avatarImage == null
                            ? Text(
                                updatedPerson.name[0].toUpperCase(),
                                style: GoogleFonts.spaceMono(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: statusColor,
                                ),
                              )
                            : null,
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    updatedPerson.relationship.toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      letterSpacing: 2,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (updatedPerson.phoneNumber != null &&
                      updatedPerson.phoneNumber!.isNotEmpty)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _ActionButton(
                          icon: Icons.phone,
                          color: Colors.green,
                          onTap: () =>
                              _launchUrl('tel:${updatedPerson.phoneNumber}'),
                        ),
                        const SizedBox(width: 16),
                        _ActionButton(
                          icon: Icons
                              .message, // WhatsApp icon usually not available in material icons, using message
                          color: Colors.green.shade700,
                          onTap: () => _launchUrl(
                            'https://wa.me/${updatedPerson.phoneNumber!.replaceAll(RegExp(r'[^0-9]'), '')}',
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      provider.registerContact(updatedPerson.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Vínculo fortalecido (+XP Social)',
                            style: GoogleFonts.spaceMono(),
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('MARCAR CONTACTO REALIZADO'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: statusColor,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      textStyle: GoogleFonts.spaceMono(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Toca este botón cuando hayas llamado, visitado o mensajeado a esta persona. Esto reiniciará el contador de frecuencia y mantendrá el vínculo saludable.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Dates Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'FECHAS IMPORTANTES',
                    style: GoogleFonts.spaceMono(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _DateCard(
                    label: 'CUMPLEAÑOS',
                    date: updatedPerson.birthday,
                    icon: Icons.cake,
                    onTap: () => _selectDate(
                      context,
                      provider,
                      updatedPerson,
                      isBirthday: true,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _DateCard(
                    label: 'ANIVERSARIO',
                    date: updatedPerson.anniversary,
                    icon: Icons.favorite,
                    onTap: () => _selectDate(
                      context,
                      provider,
                      updatedPerson,
                      isBirthday: false,
                    ),
                  ),
                ],
              ),
            ),

            // Gift Bank
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'BANCO DE IDEAS',
                        style: GoogleFonts.spaceMono(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline, size: 20),
                        onPressed: () =>
                            _addGiftIdea(context, provider, updatedPerson),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (updatedPerson.giftIdeas.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Theme.of(context).dividerColor,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Text(
                        'Agrega ideas de regalos o notas...',
                        style: GoogleFonts.inter(
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  else
                    ...updatedPerson.giftIdeas.map(
                      (idea) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: const Icon(
                            Icons.lightbulb_outline,
                            size: 18,
                          ),
                          title: Text(
                            idea,
                            style: GoogleFonts.inter(fontSize: 14),
                          ),
                          dense: true,
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, size: 18),
                            onPressed: () =>
                                provider.removeGiftIdea(updatedPerson.id, idea),
                          ),
                        ),
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

  void _confirmDelete(
    BuildContext context,
    SocialProvider provider,
    PersonModel person,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar aliado?'),
        content: Text('Se perderá toda la información de ${person.name}.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR'),
          ),
          TextButton(
            onPressed: () {
              provider.deletePerson(person.id);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to list
            },
            child: const Text('ELIMINAR', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(
    BuildContext context,
    SocialProvider provider,
    PersonModel person, {
    required bool isBirthday,
  }) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      final updatedPerson = person.copyWith(
        birthday: isBirthday ? picked : person.birthday,
        anniversary: !isBirthday ? picked : person.anniversary,
      );
      provider.updatePerson(updatedPerson);
    }
  }

  void _addGiftIdea(
    BuildContext context,
    SocialProvider provider,
    PersonModel person,
  ) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nueva Idea'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Ej: Libro de cocina'),
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                provider.addGiftIdea(person.id, controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text('AGREGAR'),
          ),
        ],
      ),
    );
  }
}

class _DateCard extends StatelessWidget {
  final String label;
  final DateTime? date;
  final IconData icon;
  final VoidCallback onTap;

  const _DateCard({
    required this.label,
    required this.date,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date != null
                        ? DateFormat('d MMMM', 'es').format(date!)
                        : 'Sin definir',
                    style: GoogleFonts.spaceMono(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: date != null ? null : Colors.grey.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
            if (date != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _calculateDaysLeft(date!),
                  style: GoogleFonts.spaceMono(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _calculateDaysLeft(DateTime date) {
    final now = DateTime.now();
    var nextDate = DateTime(now.year, date.month, date.day);
    if (nextDate.isBefore(now)) {
      nextDate = DateTime(now.year + 1, date.month, date.day);
    }
    final days = nextDate.difference(now).inDays;
    return '$days DÍAS';
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }
}

Future<void> _launchUrl(String urlString) async {
  final Uri url = Uri.parse(urlString);
  if (!await launchUrl(url)) {
    throw Exception('Could not launch $url');
  }
}
