import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

part 'user_model.g.dart';

@HiveType(typeId: 5)
class UserModel extends HiveObject {
  @HiveField(0)
  final String? id;

  @HiveField(1)
  String? username;

  @HiveField(2)
  String? email;

  @HiveField(3)
  String? password;

  @HiveField(4)
  DateTime? birthDate;

  @HiveField(5)
  String? country;

  @HiveField(6)
  String? city;

  @HiveField(7)
  String? profileImagePath;

  @HiveField(8)
  String? coverImagePath;

  @HiveField(9)
  String? defaultCurrency;

  @HiveField(10)
  bool isLoggedIn;

  @HiveField(11)
  DateTime? createdAt;

  @HiveField(12)
  DateTime? updatedAt;

  UserModel({
    String? id,
    this.username,
    this.email,
    this.password,
    this.birthDate,
    this.country,
    this.city,
    this.profileImagePath,
    this.coverImagePath,
    this.defaultCurrency = 'FCFA',
    this.isLoggedIn = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : 
    this.id = id ?? Uuid().v4(),
    this.createdAt = createdAt ?? DateTime.now(),
    this.updatedAt = updatedAt ?? DateTime.now();

  // Méthode pour mettre à jour l'utilisateur
  UserModel copyWith({
    String? username,
    String? email,
    String? password,
    DateTime? birthDate,
    String? country,
    String? city,
    String? profileImagePath,
    String? coverImagePath,
    String? defaultCurrency,
    bool? isLoggedIn,
  }) {
    return UserModel(
      id: this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
      birthDate: birthDate ?? this.birthDate,
      country: country ?? this.country,
      city: city ?? this.city,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      coverImagePath: coverImagePath ?? this.coverImagePath,
      defaultCurrency: defaultCurrency ?? this.defaultCurrency,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      createdAt: this.createdAt,
      updatedAt: DateTime.now(),
    );
  }

  // Convertir en Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'password': password,
      'birthDate': birthDate?.toIso8601String(),
      'country': country,
      'city': city,
      'profileImagePath': profileImagePath,
      'coverImagePath': coverImagePath,
      'defaultCurrency': defaultCurrency,
      'isLoggedIn': isLoggedIn,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Créer à partir d'un Map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      username: map['username'],
      email: map['email'],
      password: map['password'],
      birthDate: map['birthDate'] != null ? DateTime.parse(map['birthDate']) : null,
      country: map['country'],
      city: map['city'],
      profileImagePath: map['profileImagePath'],
      coverImagePath: map['coverImagePath'],
      defaultCurrency: map['defaultCurrency'] ?? 'FCFA',
      isLoggedIn: map['isLoggedIn'] ?? false,
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : null,
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
    );
  }
}
