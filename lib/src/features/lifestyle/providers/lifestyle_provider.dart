import 'package:flutter/material.dart';
import '../../../core/services/storage_service.dart';

class LifestyleProvider extends ChangeNotifier {
  final StorageService _storageService;

  LifestyleProvider(this._storageService);

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
