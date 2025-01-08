import 'package:hive/hive.dart';

part 'transaction_model.g.dart'; // Généré par build_runner pour Hive

@HiveType(typeId: 1) // Spécifiez un type ID unique pour Hive
class TransactionModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String type; // Dépense ou Recette

  @HiveField(2)
  String name; // Nom de la transaction

  @HiveField(3)
  String? categoryId; // ID de la catégorie liée

  @HiveField(4)
  String accountId; // ID du compte lié

  @HiveField(5)
  double amount; // Montant de la transaction

  @HiveField(6)
  DateTime date; // Date de la transaction

  TransactionModel({
    required this.id,
    required this.type,
    required this.name,
    this.categoryId,
    required this.accountId,
    required this.amount,
    required this.date,
  });

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
    );
  }
}
