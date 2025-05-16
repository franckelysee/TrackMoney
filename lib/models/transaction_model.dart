import 'package:hive/hive.dart';

part 'transaction_model.g.dart'; // Généré par build_runner pour Hive

@HiveType(typeId: 1) // Spécifiez un type ID unique pour Hive
class TransactionModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String type; // Dépense ou revenu

  @HiveField(2)
  String? name; // Nom de la transaction

  @HiveField(3)
  String? categoryId; // ID de la catégorie liée

  @HiveField(4)
  String accountId; // ID du compte lié

  @HiveField(5)
  double amount; // Montant de la transaction

  @HiveField(6)
  DateTime date; // Date de la transaction

  @HiveField(7)
  String? userId; // ID de l'utilisateur propriétaire

  @HiveField(8)
  String? currencyCode; // Code de la devise

  @HiveField(9)
  DateTime? createdAt; // Date de création

  @HiveField(10)
  DateTime? updatedAt; // Date de mise à jour

  TransactionModel({
    required this.id,
    required this.type,
    this.name,
    this.categoryId,
    required this.accountId,
    required this.amount,
    required this.date,
    this.userId,
    this.currencyCode = 'FCFA',
    DateTime? createdAt,
    DateTime? updatedAt,
  }) :
    this.createdAt = createdAt ?? DateTime.now(),
    this.updatedAt = updatedAt ?? DateTime.now();

  // Méthode pour mettre à jour la transaction
  TransactionModel copyWith({
    String? type,
    String? name,
    String? categoryId,
    String? accountId,
    double? amount,
    DateTime? date,
    String? userId,
    String? currencyCode,
  }) {
    return TransactionModel(
      id: this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      accountId: accountId ?? this.accountId,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      userId: userId ?? this.userId,
      currencyCode: currencyCode ?? this.currencyCode,
      createdAt: this.createdAt,
      updatedAt: DateTime.now(),
    );
  }

  // Méthode pour convertir un objet en JSON
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "type": type,
      "name": name,
      "categoryId": categoryId,
      "accountId": accountId,
      "amount": amount,
      "date": date.toIso8601String(),
      "userId": userId,
      "currencyCode": currencyCode,
      "createdAt": createdAt?.toIso8601String(),
      "updatedAt": updatedAt?.toIso8601String(),
    };
  }

  // Méthode pour créer un objet à partir d'un JSON
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      type: json['type'],
      name: json['name'],
      categoryId: json['categoryId'],
      accountId: json['accountId'],
      amount: json['amount'],
      date: DateTime.parse(json['date']),
      userId: json['userId'],
      currencyCode: json['currencyCode'] ?? 'FCFA',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }
}
