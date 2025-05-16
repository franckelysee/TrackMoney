// category_service.dart
import 'package:hive_flutter/hive_flutter.dart';
import 'package:trackmoney/models/category_model.dart';

class CategoryService {
  static const String _boxName = 'categories';

  // Ouvrir la boîte de catégories
  static Future<Box<CategoryModel>> _openBox() async {
    return await Hive.openBox<CategoryModel>(_boxName);
  }

  // Ajouter une catégorie
  static Future<void> addCategory(CategoryModel category) async {
    final box = await _openBox();
    await box.put(category.id, category);
  }

  // Récupérer toutes les catégories
  static Future<List<CategoryModel>> getAllCategories() async {
    final box = await _openBox();
    return box.values.toList();
  }

  // Récupérer une catégorie par son ID
  static Future<CategoryModel?> getCategoryById(String id) async {
    final box = await _openBox();
    return box.get(id);
  }

  // Mettre à jour une catégorie
  static Future<void> updateCategory(CategoryModel category) async {
    final box = await _openBox();
    await box.put(category.id, category);
  }

  // Supprimer une catégorie
  static Future<void> deleteCategory(String id) async {
    final box = await _openBox();
    await box.delete(id);
  }

  // Récupérer les catégories par nom
  static Future<List<CategoryModel>> getCategoriesByName(String name) async {
    final box = await _openBox();
    return box.values.where((category) =>
      category.name.toLowerCase().contains(name.toLowerCase())
    ).toList();
  }

  // Vérifier si une catégorie existe
  static Future<bool> categoryExists(String name) async {
    final box = await _openBox();
    return box.values.any((category) =>
      category.name.toLowerCase() == name.toLowerCase()
    );
  }

  // Supprimer toutes les catégories
  static Future<void> deleteAllCategories() async {
    final box = await _openBox();
    await box.clear();
  }
}
