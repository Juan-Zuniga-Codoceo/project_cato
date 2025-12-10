import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/social_provider.dart';
import '../../domain/models/person_model.dart';
import '../../../../core/theme/app_theme.dart';
import 'ally_detail_screen.dart';
import 'dart:io';
import '../widgets/person_dialog.dart';

class SocialScreen extends StatelessWidget {
  const SocialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SocialProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ALIADOS',
          style: GoogleFonts.spaceMono(fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddPersonDialog(context, provider),
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.person_add, color: Colors.black),
      ),
      body: provider.people.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.groups,
                    size: 64,
                    color: Colors.grey.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Sin aliados registrados.\nAgrega personas importantes.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.spaceMono(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Colors.grey.withOpacity(0.7),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Toca una tarjeta para gestionar el vínculo',
                        style: GoogleFonts.inter(
                          color: Colors.grey.withOpacity(0.7),
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.85,
                        ),
                    itemCount: provider.people.length,
                    itemBuilder: (context, index) {
                      final person = provider.people[index];
                      return _AllyCard(person: person);
                    },
                  ),
                ),
              ],
            ),
    );
  }

  void _showAddPersonDialog(BuildContext context, SocialProvider provider) {
    showDialog(
      context: context,
      builder: (context) => PersonDialog(provider: provider),
    );
  }
}

class _AllyCard extends StatelessWidget {
  final PersonModel person;

  const _AllyCard({required this.person});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SocialProvider>(context, listen: false);
    final status = provider.getContactStatus(person);

    // Check for upcoming events
    final upcomingEvent = _getUpcomingEvent(person);
    final isEventNear = upcomingEvent != null;

    // Override status color if event is near
    final statusColor = isEventNear
        ? Colors.amber
        : (status == ContactStatus.good
              ? Colors.cyan.withOpacity(0.5) // Refined Cyan
              : provider.getStatusColor(status));

    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AllyDetailScreen(person: person),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: statusColor.withOpacity(0.5), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: statusColor.withOpacity(0.1),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Stack(
          children: [
            if (person.isFavorite)
              Positioned(
                top: 8,
                left: 8,
                child: Icon(Icons.star, size: 20, color: Colors.amber),
              ),
            Positioned(
              top: 8,
              right: 8,
              child: Icon(
                Icons.open_in_new,
                size: 16,
                color: statusColor.withOpacity(0.5),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Builder(
                    builder: (context) {
                      final hasPhoto =
                          person.photoPath != null &&
                          File(person.photoPath!).existsSync();

                      return CircleAvatar(
                        radius: 32,
                        backgroundImage: hasPhoto
                            ? FileImage(File(person.photoPath!))
                            : null,
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        key: ValueKey(person.photoPath),
                        onBackgroundImageError: hasPhoto ? (_, __) {} : null,
                        child: hasPhoto
                            ? null
                            : Text(
                                person.name.isNotEmpty
                                    ? person.name[0].toUpperCase()
                                    : '?',
                                style: GoogleFonts.spaceMono(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: statusColor,
                                ),
                              ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  if (isEventNear) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.amber, width: 1),
                      ),
                      child: Text(
                        upcomingEvent,
                        style: GoogleFonts.spaceMono(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Text(
                    person.name,
                    style: GoogleFonts.spaceMono(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    person.relationship.toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: Colors.grey,
                      letterSpacing: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.history, size: 12, color: statusColor),
                        const SizedBox(width: 4),
                        Text(
                          _formatLastContact(person.lastContactDate),
                          style: GoogleFonts.spaceMono(
                            fontSize: 10,
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
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

  String _formatLastContact(DateTime? date) {
    if (date == null) return 'NUNCA';
    final diff = DateTime.now().difference(date).inDays;
    if (diff == 0) return 'HOY';
    if (diff == 1) return 'AYER';
    return 'HACE $diff DÍAS';
  }

  String? _getUpcomingEvent(PersonModel person) {
    if (person.birthday != null) {
      final days = _daysUntil(person.birthday!);
      if (days <= 7) return '🎂 $days DÍAS';
    }

    if (person.anniversary != null) {
      final days = _daysUntil(person.anniversary!);
      if (days <= 7) return '💍 $days DÍAS';
    }

    return null;
  }

  int _daysUntil(DateTime date) {
    final now = DateTime.now();
    var nextDate = DateTime(now.year, date.month, date.day);
    if (nextDate.isBefore(DateTime(now.year, now.month, now.day))) {
      nextDate = DateTime(now.year + 1, date.month, date.day);
    }
    return nextDate.difference(DateTime(now.year, now.month, now.day)).inDays;
  }
}
