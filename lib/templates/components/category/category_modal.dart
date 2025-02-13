import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:trackmoney/DataBase/database.dart';
import 'package:trackmoney/models/category_model.dart';
import 'package:trackmoney/models/notification_model.dart';
import 'package:trackmoney/templates/components/color_selector.dart';
import 'package:trackmoney/templates/components/customFormFields.dart';
import 'package:trackmoney/templates/components/icon_selector.dart';
import 'package:trackmoney/utils/notification_type_enum.dart';
import 'package:trackmoney/utils/snackBarNotifyer.dart';
import 'package:uuid/uuid.dart';

class CustomCategoryModal extends StatefulWidget {
  final TextEditingController categoryController;
  final Function(String) onCategoryAdded; // Callback pour notifier le parent
  const CustomCategoryModal({
    super.key,
    required this.categoryController,
    required this.onCategoryAdded,
  });
  @override
  State<CustomCategoryModal> createState() => _CustomCategoryModalState();
}

class _CustomCategoryModalState extends State<CustomCategoryModal> {
  final modalFormKey = GlobalKey<FormState>();
  IconData? selectedIcon;
  Color? selectedColor;
  int? iconCode;
  int? colorCode;
  String? categoryName;
  List<CategoryModel> categories = [];

  void loadCategories() async {
    categories = await Database.getAllCategories();
    setState(() {});
  }

  void saveCategorys() async {
    try {
      if (modalFormKey.currentState!.validate()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Processing Data')),
        );
        categoryName = widget.categoryController.text;

        // Ajouter la catégorie a la base de données
        var category = CategoryModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: categoryName!,
          color: colorCode!,
          iconCode: iconCode!,
        );
        Database.addCategory(category);
        // notification
        var notification = NotificationModel(
            notificationId: Uuid().v4(),
            title: "Nouvelle Categorie",
            content: "Une nouvelle categorie a été créée",
            type: NotificationTypeEnum.INFORMATION,
            isRead: false,
            isArchived: false,
            date: DateTime.now());

        // add notification to database
        await Database.addNotification(notification);
        widget.onCategoryAdded(categoryName!);
        widget.categoryController.clear();

        Navigator.pop(context); // Fermer le modal après succès
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Catégorie "$categoryName" ajoutée avec succès !'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur dans le formulaire')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur dans le formulaire : $e')),
      );
    }
  }

  void saveCategory() async {
    try {
      if (modalFormKey.currentState!.validate()) {
        final categoryName = widget.categoryController.text.trim();
        bool already = false;
        // Vérifier si une catégorie avec ce nom existe déjà
        final box = Hive.box<CategoryModel>('categories');
        categories = box.values.toList();
        for (var category in categories) {
          if (category.name.toLowerCase() == categoryName.toLowerCase()) {
            already = true;
            break;
          }
        }
        if (already) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cette catégorie existe déjà !')),
          );
        } else {
          if (iconCode == null) {
            IconData icn = Icons.add;
            setState(() {
              iconCode = icn.codePoint;
            });
          }
          if (colorCode == null) {
            Color clr = Colors.blue;
            setState(() {
              colorCode = clr.value;
            });
          }
          final newCategory = CategoryModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: categoryName,
            color: colorCode!,
            iconCode: iconCode!,
          );
          // Ajouter la catégorie à Hive
          Database.addCategory(newCategory);
          widget.onCategoryAdded(categoryName);
          // notification
          var notification = NotificationModel(
              notificationId: Uuid().v4(),
              title: "Nouvelle Categorie",
              content: "Une nouvelle categorie a été créée",
              type: NotificationTypeEnum.INFORMATION,
              isRead: false,
              isArchived: false,
              date: DateTime.now());

          // add notification to database
          await Database.addNotification(notification);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Catégorie "$categoryName" ajoutée avec succès !'),
            ),
          );
        }

        // Réinitialiser les champs et fermer le modal
        widget.categoryController.clear();
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur dans le formulaire')),
        );
      }
    } catch (e) {
      SnackbarNotifier.show(
          context: context,
          message: "Erreur dans le formulaire : $e",
          type: 'error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: modalFormKey,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon with GestureDetector
            SizedBox(
              width: 150,
              height: 150,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
                onPressed: () async {
                  final icon = await IconSelector().showIconSelector(context);
                  if (icon != null) {
                    setState(() {
                      selectedIcon = icon;
                      iconCode = selectedIcon!.codePoint;
                    });
                  }
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 50,
                    ),
                    Text(
                      "Ajouter une Icon",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),

            if (selectedIcon != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    color:
                        selectedColor ?? Theme.of(context).colorScheme.primary,
                    child: Icon(
                      selectedIcon,
                      size: 50,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () async {
                      final color =
                          await ColorSelector().showColorSelector(context);
                      if (color != null) {
                        setState(() {
                          selectedColor = color;
                          colorCode = selectedColor!.value;
                        });
                      }
                    },
                    label: Text('Edit Color'),
                    icon: Icon(
                      Icons.edit,
                    ),
                  )
                ],
              ),
            SizedBox(height: 16),
            // Category TextFormField
            CustomTextFormField(
              controller: widget.categoryController,
              labelText: 'Entrer le nom de la category eg:Food',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ce champ est obligatoire';
                }
                return null;
              },
            ),
            SizedBox(height: 16),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
                onPressed: saveCategory,
                child: Text(
                  'Ajouter',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.surface,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
