import 'package:hive/hive.dart';

part 'person_model.g.dart';

@HiveType(typeId: 9)
class PersonModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String relationship; // e.g., 'Pareja', 'Madre', 'Amigo'

  @HiveField(3)
  DateTime? birthday;

  @HiveField(4)
  DateTime? anniversary;

  @HiveField(5)
  String? photoPath;

  @HiveField(6)
  List<String> giftIdeas;

  @HiveField(7)
  int contactFrequency; // Days between desired contact

  @HiveField(8)
  DateTime? lastContactDate;

  @HiveField(9)
  bool isFavorite;

  @HiveField(10)
  String? phoneNumber;

  PersonModel({
    required this.id,
    required this.name,
    required this.relationship,
    this.birthday,
    this.anniversary,
    this.photoPath,
    this.giftIdeas = const [],
    this.contactFrequency = 7,
    this.lastContactDate,
    this.isFavorite = false,
    this.phoneNumber,
  });

  PersonModel copyWith({
    String? name,
    String? relationship,
    DateTime? birthday,
    DateTime? anniversary,
    String? photoPath,
    List<String>? giftIdeas,
    int? contactFrequency,
    DateTime? lastContactDate,
    bool? isFavorite,
    String? phoneNumber,
  }) {
    return PersonModel(
      id: id,
      name: name ?? this.name,
      relationship: relationship ?? this.relationship,
      birthday: birthday ?? this.birthday,
      anniversary: anniversary ?? this.anniversary,
      photoPath: photoPath ?? this.photoPath,
      giftIdeas: giftIdeas ?? this.giftIdeas,
      contactFrequency: contactFrequency ?? this.contactFrequency,
      lastContactDate: lastContactDate ?? this.lastContactDate,
      isFavorite: isFavorite ?? this.isFavorite,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }
}
