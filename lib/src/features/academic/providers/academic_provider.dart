import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../core/services/storage_service.dart';
import '../domain/models/subject_model.dart';
import '../domain/models/evaluation_model.dart';
import '../domain/models/academic_event_model.dart';
import '../../../core/services/notification_service.dart';

class AcademicProvider extends ChangeNotifier {
  final StorageService _storageService;
  final Uuid _uuid = const Uuid();
  final NotificationService _notificationService = NotificationService();

  AcademicProvider(this._storageService);

  Box<SubjectModel> get _academicBox => _storageService.academicBox;
  Box<AcademicEventModel> get _academicEventsBox =>
      _storageService.academicEventsBox;
  // Removed: Box get _settingsBox => _storageService.settingsBox;

  List<SubjectModel> get subjects => _academicBox.values.toList();
  List<AcademicEventModel> get events => _academicEventsBox.values.toList();

  // --- Grading Scale Logic ---

  /// 0 = Chile (1.0 - 7.0)
  /// 1 = Latam (0.0 - 10.0)
  /// 2 = Percentage (0 - 100)

  // Default grading scale (0 = Chile)
  static const int defaultGradingScale = 0;

  double getMaxGrade(SubjectModel subject) {
    switch (subject.gradingScale) {
      case 1:
        return 10.0;
      case 2:
        return 100.0;
      default:
        return 7.0;
    }
  }

  double getMinGrade(SubjectModel subject) {
    switch (subject.gradingScale) {
      case 1:
        return 0.0;
      case 2:
        return 0.0;
      default:
        return 1.0;
    }
  }

  // --- CRUD Subjects ---

  Future<void> addSubject(
    String name, {
    double? passingGrade,
    double? targetGrade,
    int? gradingScale,
  }) async {
    final newSubject = SubjectModel(
      id: _uuid.v4(),
      name: name,
      evaluations: [],
      passingGrade: passingGrade ?? 4.0,
      targetGrade: targetGrade ?? 7.0,
      gradingScale: gradingScale ?? defaultGradingScale,
    );
    await _academicBox.put(newSubject.id, newSubject);
    notifyListeners();
  }

  Future<void> updateSubject(SubjectModel subject) async {
    await _academicBox.put(subject.id, subject);
    notifyListeners();
  }

  Future<void> deleteSubject(String id) async {
    await _academicBox.delete(id);
    notifyListeners();
  }

  // --- CRUD Evaluations ---

  Future<void> addEvaluation(
    String subjectId,
    String name,
    double grade,
    double weight,
  ) async {
    final subject = _academicBox.get(subjectId);
    if (subject != null) {
      final newEvaluation = EvaluationModel(
        id: _uuid.v4(),
        name: name,
        grade: grade,
        weight: weight,
      );
      subject.evaluations.add(newEvaluation);
      await _academicBox.put(subject.id, subject);
      notifyListeners();
    }
  }

  Future<void> updateEvaluation(
    String subjectId,
    EvaluationModel updatedEvaluation,
  ) async {
    final subject = _academicBox.get(subjectId);
    if (subject != null) {
      final index = subject.evaluations.indexWhere(
        (e) => e.id == updatedEvaluation.id,
      );
      if (index != -1) {
        subject.evaluations[index] = updatedEvaluation;
        await _academicBox.put(subject.id, subject);
        notifyListeners();
      }
    }
  }

  Future<void> deleteEvaluation(String subjectId, String evaluationId) async {
    final subject = _academicBox.get(subjectId);
    if (subject != null) {
      subject.evaluations.removeWhere((e) => e.id == evaluationId);
      await _academicBox.put(subject.id, subject);
      notifyListeners();
    }
  }

  // --- Calculation Logic ---

  double calculateCurrentAverage(SubjectModel subject) {
    if (subject.evaluations.isEmpty) return 0.0;

    double totalWeightedGrade = 0.0;
    double totalWeight = 0.0;

    for (final evaluation in subject.evaluations) {
      totalWeightedGrade += evaluation.grade * evaluation.weight;
      totalWeight += evaluation.weight;
    }

    if (totalWeight == 0) return 0.0;

    return (totalWeightedGrade / totalWeight);
  }

  double calculateTotalWeight(SubjectModel subject) {
    if (subject.evaluations.isEmpty) return 0.0;
    return subject.evaluations.fold(0.0, (sum, item) => sum + item.weight);
  }

  /// Returns the grade needed in the remaining percentage to pass.
  /// Returns null if already passed.
  /// Returns 999.0 if mathematically impossible (required > maxGrade).
  double? calculateRequiredGrade(SubjectModel subject) {
    final currentWeight = calculateTotalWeight(subject);
    final remainingWeight = 1.0 - currentWeight;

    // If we have evaluated 100% (or more), we can't "require" more.
    if (remainingWeight <= 0.001) return null;

    final currentAverage = calculateCurrentAverage(subject);
    final required = (subject.passingGrade - currentAverage) / remainingWeight;

    if (required > getMaxGrade(subject)) {
      return 999.0; // Impossible
    }

    return required;
  }

  // --- Attendance Logic ---

  Future<void> incrementAttendance(String subjectId) async {
    final subject = _academicBox.get(subjectId);
    if (subject != null) {
      final updatedSubject = SubjectModel(
        id: subject.id,
        name: subject.name,
        evaluations: subject.evaluations,
        passingGrade: subject.passingGrade,
        targetGrade: subject.targetGrade,
        gradingScale: subject.gradingScale,
        totalClasses: subject.totalClasses + 1,
        attendedClasses: subject.attendedClasses + 1,
        minAttendance: subject.minAttendance,
      );
      await _academicBox.put(subject.id, updatedSubject);
      notifyListeners();
    }
  }

  Future<void> registerAbsence(String subjectId) async {
    final subject = _academicBox.get(subjectId);
    if (subject != null) {
      final updatedSubject = SubjectModel(
        id: subject.id,
        name: subject.name,
        evaluations: subject.evaluations,
        passingGrade: subject.passingGrade,
        targetGrade: subject.targetGrade,
        gradingScale: subject.gradingScale,
        totalClasses: subject.totalClasses + 1,
        attendedClasses: subject.attendedClasses, // No increment
        minAttendance: subject.minAttendance,
      );
      await _academicBox.put(subject.id, updatedSubject);
      notifyListeners();
    }
  }

  Future<void> resetAttendance(String subjectId) async {
    final subject = _academicBox.get(subjectId);
    if (subject != null) {
      final updatedSubject = SubjectModel(
        id: subject.id,
        name: subject.name,
        evaluations: subject.evaluations,
        passingGrade: subject.passingGrade,
        targetGrade: subject.targetGrade,
        gradingScale: subject.gradingScale,
        totalClasses: 0,
        attendedClasses: 0,
        minAttendance: subject.minAttendance,
      );
      await _academicBox.put(subject.id, updatedSubject);
      notifyListeners();
    }
  }

  // --- Global GPA ---

  double get globalAverage {
    if (subjects.isEmpty) return 0.0;

    double totalSum = 0.0;
    int count = 0;

    for (final subject in subjects) {
      // Only include subjects that have at least one evaluation or a valid average
      // For now, we just take the current average.
      // Ideally, we should normalize if scales are mixed, but assuming consistent scale for now.
      final avg = calculateCurrentAverage(subject);
      if (avg > 0) {
        totalSum += avg;
        count++;
      }
    }

    if (count == 0) return 0.0;
    return totalSum / count;
  }

  /// Call this when settings change to update UI
  void refresh() {
    notifyListeners();
  }
  // --- Events ---

  List<AcademicEventModel> getEventsForDay(DateTime day) {
    return events.where((event) {
      return isSameDay(event.date, day);
    }).toList();
  }

  Future<void> addEvent(
    String title,
    DateTime date,
    String type, {
    String? subjectId,
  }) async {
    final event = AcademicEventModel(
      id: _uuid.v4(),
      title: title,
      date: date,
      type: type,
      subjectId: subjectId,
    );
    await _academicEventsBox.put(event.id, event);
    notifyListeners();

    _scheduleEventNotifications(event);
  }

  Future<void> deleteEvent(String id) async {
    await _academicEventsBox.delete(id);
    notifyListeners();
  }

  void _scheduleEventNotifications(AcademicEventModel event) {
    final eventIdHash = event.id.hashCode;

    // 1 Day before
    final dayBefore = event.date.subtract(const Duration(days: 1));
    if (dayBefore.isAfter(DateTime.now())) {
      _notificationService.scheduleDateNotification(
        id: eventIdHash,
        title: '📅 Mañana: ${event.title}',
        body: 'Tienes un evento de tipo ${event.type}. ¡Prepárate!',
        scheduledDate: dayBefore,
      );
    }

    // 1 Hour before
    final hourBefore = event.date.subtract(const Duration(hours: 1));
    if (hourBefore.isAfter(DateTime.now())) {
      _notificationService.scheduleDateNotification(
        id: eventIdHash + 1,
        title: '⏰ En 1 hora: ${event.title}',
        body: 'Tu evento ${event.type} está por comenzar.',
        scheduledDate: hourBefore,
      );
    }
  }

  bool isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) {
      return false;
    }
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
