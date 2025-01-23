import 'package:flutter/material.dart';

class TransactionSchema {
  IconData? icon;
  String? name;
  Color? iconcolor;
  double? amount;
  DateTime? date;
  String? category;
  String? account_id;
  String? id;
  String? type;
  TransactionSchema({this.icon, this.name, this.iconcolor, this.amount, this.date, this.category, this.account_id, this.id, this.type});
}