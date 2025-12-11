import 'package:hive/hive.dart';

part 'user_stats_model.g.dart';

@HiveType(typeId: 7)
class UserStatsModel extends HiveObject {
  @HiveField(0)
  int totalXp;

  @HiveField(1)
  int currentLevel;

  @HiveField(2, defaultValue: 0)
  int strengthXp;

  @HiveField(3, defaultValue: 0)
  int intellectXp;

  @HiveField(4, defaultValue: 0)
  int vitalityXp;

  @HiveField(5, defaultValue: 0)
  int disciplineXp;

  @HiveField(6, defaultValue: 'Guerrero')
  String userName;

  @HiveField(7, defaultValue: 'assets/avatars/hero_1.jpg')
  String avatarPath;

  @HiveField(8)
  int? age;

  UserStatsModel({
    required this.totalXp,
    required this.currentLevel,
    this.strengthXp = 0,
    this.intellectXp = 0,
    this.vitalityXp = 0,
    this.disciplineXp = 0,
    this.userName = 'Guerrero',
    this.avatarPath = 'assets/avatars/hero_1.jpg',
    this.age,
  });

  String get rankTitle {
    if (currentLevel < 5) return 'Novato Disciplinado';
    if (currentLevel < 10) return 'Guerrero Constante';
    if (currentLevel < 20) return 'Caballero de Hierro';
    if (currentLevel < 50) return 'Maestro del Hábito';
    return 'Leyenda Viviente';
  }

  int getAttributeLevel(String attribute) {
    switch (attribute) {
      case 'Fuerza':
        return strengthXp ~/ 100;
      case 'Intelecto':
        return intellectXp ~/ 100;
      case 'Vitalidad':
        return vitalityXp ~/ 100;
      case 'Disciplina':
        return disciplineXp ~/ 100;
      default:
        return 0;
    }
  }

  int getAttributeXp(String attribute) {
    switch (attribute) {
      case 'Fuerza':
        return strengthXp;
      case 'Intelecto':
        return intellectXp;
      case 'Vitalidad':
        return vitalityXp;
      case 'Disciplina':
        return disciplineXp;
      default:
        return 0;
    }
  }
}
