
import 'package:hive_flutter/hive_flutter.dart';

part 'divise_model.g.dart';

@HiveType(typeId: 6)
class Devise extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String devise;

  @HiveField(2)
  final String symbol;

  @HiveField(3)
  final DateTime? createdAt;

  @HiveField(4)
  final DateTime? updatedAt;

  Devise({
    required this.name,
    required this.devise,
    this.symbol = '',
    DateTime? createdAt,
    DateTime? updatedAt,
  }) :
    this.createdAt = createdAt ?? DateTime.now(),
    this.updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'devise': devise,
      'symbol': symbol,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory Devise.fromMap(Map<String, dynamic> map) {
    return Devise(
      name: map['name'] ?? '',
      devise: map['devise'] ?? '',
      symbol: map['symbol'] ?? '',
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : null,
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
    );
  }
}
