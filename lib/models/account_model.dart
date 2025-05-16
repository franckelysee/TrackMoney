
import 'package:hive_flutter/hive_flutter.dart';

part 'account_model.g.dart';

@HiveType(typeId: 2)
class AccountModel extends HiveObject {
  @HiveField(0)
  String? id;

  @HiveField(1)
  String? name;

  @HiveField(2)
  String? type;

  @HiveField(3)
  double? balance;

  @HiveField(4)
  String? userId;

  @HiveField(5)
  String? currencyCode;

  @HiveField(6)
  DateTime? createdAt;

  @HiveField(7)
  DateTime? updatedAt;

  AccountModel({
    required this.id,
    required this.name,
    required this.type,
    required this.balance,
    this.userId,
    this.currencyCode = 'FCFA',
    DateTime? createdAt,
    DateTime? updatedAt,
  }) :
    createdAt = createdAt ?? DateTime.now(),
    updatedAt = updatedAt ?? DateTime.now();

  // Méthode pour mettre à jour le compte
  AccountModel copyWith({
    String? name,
    String? type,
    double? balance,
    String? userId,
    String? currencyCode,
  }) {
    return AccountModel(
      id: id,
      name: name ?? this.name,
      type: type ?? this.type,
      balance: balance ?? this.balance,
      userId: userId ?? this.userId,
      currencyCode: currencyCode ?? this.currencyCode,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  // Convertir en Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'balance': balance,
      'userId': userId,
      'currencyCode': currencyCode,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Créer à partir d'un Map
  factory AccountModel.fromMap(Map<String, dynamic> map) {
    return AccountModel(
      id: map['id'],
      name: map['name'],
      type: map['type'],
      balance: map['balance'],
      userId: map['userId'],
      currencyCode: map['currencyCode'] ?? 'FCFA',
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : null,
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
    );
  }
}