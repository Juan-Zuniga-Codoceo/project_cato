import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/services/storage_service.dart';
import '../domain/models/person_model.dart';

import 'dart:io';
import '../../../core/services/file_manager_service.dart';
import '../../../core/services/notification_service.dart';

enum ContactStatus {
  good, // Green
  warning, // Yellow
  critical, // Red
}

class SocialProvider extends ChangeNotifier {
  final StorageService _storageService;
  final NotificationService _notificationService;

  SocialProvider(this._storageService, this._notificationService);

  Box<PersonModel> get _box => _storageService.socialBox;

  List<PersonModel> get people {
    final allPeople = _box.values.toList();
    allPeople.sort((a, b) {
      // 1. Favorites first
      if (a.isFavorite && !b.isFavorite) return -1;
      if (!a.isFavorite && b.isFavorite) return 1;

      // 2. Contact Status (Critical -> Warning -> Good)
      final statusA = getContactStatus(a);
      final statusB = getContactStatus(b);
      if (statusA != statusB) {
        return statusB.index.compareTo(statusA.index);
      }

      // 3. Alphabetical
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    return allPeople;
  }

  Future<void> addPerson({
    required String name,
    required String relationship,
    DateTime? birthday,
    DateTime? anniversary,
    String? photoPath,
    int contactFrequency = 7,
    bool isFavorite = false,
    String? phoneNumber,
  }) async {
    String? permanentPhotoPath;
    if (photoPath != null) {
      permanentPhotoPath = await FileManagerService.saveFilePermanently(
        File(photoPath),
        'social_images',
      );
    }

    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final newPerson = PersonModel(
      id: id,
      name: name,
      relationship: relationship,
      birthday: birthday,
      anniversary: anniversary,
      photoPath: permanentPhotoPath,
      contactFrequency: contactFrequency,
      lastContactDate: DateTime.now(), // Assume contact on creation
      isFavorite: isFavorite,
      phoneNumber: phoneNumber,
    );
    await _box.put(id, newPerson);
    await _scheduleReminders(newPerson);
    notifyListeners();
  }

  Future<void> updatePerson(PersonModel updatedPerson) async {
    // Check if photo path has changed or needs saving
    // For simplicity, if it's not in app_docs, we save it
    // But since we can't easily check "in app_docs" without path logic,
    // we can rely on the fact that the UI sends a temp path from ImagePicker.
    // However, to avoid re-saving already permanent files, we can check if it contains 'app_docs'
    // or just try to save it if it exists.

    PersonModel personToSave = updatedPerson;

    if (updatedPerson.photoPath != null) {
      final file = File(updatedPerson.photoPath!);
      if (await file.exists() &&
          !updatedPerson.photoPath!.contains('app_docs')) {
        final permanentPath = await FileManagerService.saveFilePermanently(
          file,
          'social_images',
        );
        personToSave = updatedPerson.copyWith(photoPath: permanentPath);
      }
    }

    await _box.put(personToSave.id, personToSave);
    await _scheduleReminders(personToSave);
    notifyListeners();
  }

  Future<void> deletePerson(String id) async {
    final person = _box.get(id);
    if (person != null) {
      await _cancelReminders(person);
      await _box.delete(id);
      notifyListeners();
    }
  }

  Future<void> registerContact(String id) async {
    final person = _box.get(id);
    if (person != null) {
      final updatedPerson = person.copyWith(lastContactDate: DateTime.now());
      await _box.put(id, updatedPerson);
      notifyListeners();
    }
  }

  Future<void> addGiftIdea(String personId, String idea) async {
    final person = _box.get(personId);
    if (person != null) {
      final updatedIdeas = List<String>.from(person.giftIdeas)..add(idea);
      final updatedPerson = person.copyWith(giftIdeas: updatedIdeas);
      await _box.put(personId, updatedPerson);
      notifyListeners();
    }
  }

  Future<void> removeGiftIdea(String personId, String idea) async {
    final person = _box.get(personId);
    if (person != null) {
      final updatedIdeas = List<String>.from(person.giftIdeas)..remove(idea);
      final updatedPerson = person.copyWith(giftIdeas: updatedIdeas);
      await _box.put(personId, updatedPerson);
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(String id) async {
    final person = _box.get(id);
    if (person != null) {
      final updatedPerson = person.copyWith(isFavorite: !person.isFavorite);
      await _box.put(id, updatedPerson);
      notifyListeners();
    }
  }

  ContactStatus getContactStatus(PersonModel person) {
    if (person.lastContactDate == null) return ContactStatus.critical;

    final daysSinceContact = DateTime.now()
        .difference(person.lastContactDate!)
        .inDays;
    final frequency = person.contactFrequency;

    if (daysSinceContact <= frequency * 0.7) {
      return ContactStatus.good;
    } else if (daysSinceContact <= frequency) {
      return ContactStatus.warning;
    } else {
      return ContactStatus.critical;
    }
  }

  Color getStatusColor(ContactStatus status) {
    switch (status) {
      case ContactStatus.good:
        return Colors.green;
      case ContactStatus.warning:
        return Colors.amber;
      case ContactStatus.critical:
        return Colors.red;
    }
  }

  Future<void> _scheduleReminders(PersonModel person) async {
    // Cancel existing reminders first to avoid duplicates/stale data
    await _cancelReminders(person);

    final now = DateTime.now();

    // Schedule Birthday
    if (person.birthday != null) {
      var nextBirthday = DateTime(
        now.year,
        person.birthday!.month,
        person.birthday!.day,
        9, // 9:00 AM
        0,
      );
      if (nextBirthday.isBefore(now)) {
        nextBirthday = DateTime(
          now.year + 1,
          person.birthday!.month,
          person.birthday!.day,
          9,
          0,
        );
      }

      await _notificationService.scheduleDateNotification(
        id: person.id.hashCode + 1,
        title: '🎂 ¡Hoy es el cumpleaños de ${person.name}!',
        body: 'No olvides felicitar a tu ${person.relationship}.',
        scheduledDate: nextBirthday,
      );
    }

    // Schedule Anniversary
    if (person.anniversary != null) {
      var nextAnniversary = DateTime(
        now.year,
        person.anniversary!.month,
        person.anniversary!.day,
        9, // 9:00 AM
        0,
      );
      if (nextAnniversary.isBefore(now)) {
        nextAnniversary = DateTime(
          now.year + 1,
          person.anniversary!.month,
          person.anniversary!.day,
          9,
          0,
        );
      }

      await _notificationService.scheduleDateNotification(
        id: person.id.hashCode + 2,
        title: '💍 Aniversario con ${person.name}',
        body: 'Un día especial para celebrar juntos.',
        scheduledDate: nextAnniversary,
      );
    }
  }

  Future<void> _cancelReminders(PersonModel person) async {
    await _notificationService.cancelNotification(person.id.hashCode + 1);
    await _notificationService.cancelNotification(person.id.hashCode + 2);
  }
}
