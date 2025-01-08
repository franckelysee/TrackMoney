import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'category_model.g.dart';

@HiveType(typeId: 3)
class CategoryModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final int color; // Stocker la couleur comme un entier (ARGB)

  @HiveField(3)
  int? iconCode;

  @HiveField(4)
  final DateTime date;

  factory CategoryModel({
    required id,
    required name,
    required color,
    iconCode,
    date,
  }){
    return CategoryModel._(
      id: id,
      name: name,
      color: color,
      iconCode: iconCode,
      date: DateTime.now(),
    );
  }
  
  CategoryModel._({
    required this.id,
    required this.name,
    required this.color,
    this.iconCode,
    required this.date,
  });

  // Récupérer la couleur comme Color
  Color get colorValue => Color(color);

  // Récupérer l'icône comme IconData
  IconData? get icon => iconCode != null ? IconData(iconCode!, fontFamily: 'MaterialIcons') : null;

  // Méthode pour définir une nouvelle icône
  void setIcon(IconData icon) {
    iconCode = icon.codePoint;
  }
  

  // Méthode pour convertir une couleur en int
  static int colorToInt(Color? color) => color!.value;

  // Méthode pour convertir un int en Color
  static Color intToColor(int color) => Color(color);


}
