import 'package:flutter/material.dart';

import '../../../core/services/storage_service.dart';
import '../../../core/services/notification_service.dart';

class LifestyleProvider extends ChangeNotifier {
  final StorageService _storageService;
  final NotificationService _notificationService;

  LifestyleProvider(this._storageService, this._notificationService);

  // Checkup Types
  static const String checkupGeneral = 'general';
  static const String checkupDental = 'dental';
  static const String checkupVision = 'vision';

  DateTime? getLastCheckup(String type) {
    final dateString = _storageService.lifestyleBox.get('checkup_$type');
    if (dateString != null) {
      return DateTime.parse(dateString);
    }
    return null;
  }

  Future<void> updateCheckup(String type, DateTime date) async {
    await _storageService.lifestyleBox.put(
      'checkup_$type',
      date.toIso8601String(),
    );
    notifyListeners();

    // Schedule next checkup notification
    DateTime nextCheckupDate;
    String bodyText;

    switch (type) {
      case checkupDental:
        nextCheckupDate = date.add(const Duration(days: 180)); // 6 months
        bodyText = 'Ya pasaron 6 meses desde tu último dentista. ¡Agenda hora!';
        break;
      case checkupGeneral:
        nextCheckupDate = date.add(const Duration(days: 365)); // 1 year
        bodyText =
            'Ya pasó un año desde tu último chequeo general. ¡Agenda hora!';
        break;
      case checkupVision:
        nextCheckupDate = date.add(const Duration(days: 365)); // 1 year
        bodyText =
            'Ya pasó un año desde tu último chequeo de vista. ¡Agenda hora!';
        break;
      default:
        return;
    }

    // Set time to 9:00 AM
    final scheduledDate = DateTime(
      nextCheckupDate.year,
      nextCheckupDate.month,
      nextCheckupDate.day,
      9,
      0,
    );

    await _notificationService.scheduleDateNotification(
      id: type.hashCode,
      title: '🏥 Mantenimiento de Salud',
      body: bodyText,
      scheduledDate: scheduledDate,
    );
  }

  Color getHealthStatus(String type) {
    final lastCheckup = getLastCheckup(type);
    if (lastCheckup == null) return Colors.grey;

    final now = DateTime.now();
    final difference = now.difference(lastCheckup).inDays;

    int warningDays;
    int dangerDays;

    switch (type) {
      case checkupDental:
        warningDays = 150; // ~5 months
        dangerDays = 180; // 6 months
        break;
      case checkupGeneral:
      case checkupVision:
      default:
        warningDays = 330; // ~11 months
        dangerDays = 365; // 1 year
        break;
    }

    if (difference >= dangerDays) {
      return Colors.red;
    } else if (difference >= warningDays) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  // BMI Calculator
  Map<String, dynamic> calculateBMI(double heightCm, double weightKg) {
    if (heightCm <= 0 || weightKg <= 0) {
      return {'bmi': 0.0, 'category': 'N/A'};
    }

    final heightM = heightCm / 100;
    final bmi = weightKg / (heightM * heightM);
    String category;

    if (bmi < 18.5) {
      category = 'Bajo peso';
    } else if (bmi < 25) {
      category = 'Peso normal';
    } else if (bmi < 30) {
      category = 'Sobrepeso';
    } else {
      category = 'Obesidad';
    }

    return {'bmi': bmi, 'category': category};
  }
}
