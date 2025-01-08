

import 'package:hive_flutter/hive_flutter.dart';


part 'account_model.g.dart';

@HiveType(typeId: 2)
class AccountModel extends HiveObject{
  @HiveField(0)
  int? id;
  @HiveField(1)
  String? name;
  @HiveField(2)
  String? type;
  @HiveField(3)
  int? balance;

  AccountModel({required this.id, required this.name, required this.type, required this.balance});
}