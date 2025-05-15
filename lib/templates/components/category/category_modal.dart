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
          if (mounted) {
            SnackbarNotifier.show(
              context: context,
              message: "Cette catégorie existe déjà. Veuillez créer une nouvelle",
              type: 'warning',
            );
          }
        } else {
          if (iconCode == null) {
            IconData icn = Icons.add;
            setState(() {
              iconCode = icn.codePoint;
            });
          }
          if (colorCode == null) {
            // Utiliser une couleur par défaut
            setState(() {
              colorCode = 0xFF2196F3; // Valeur hexadécimale de Colors.blue
            });
          }
          final newCategory = CategoryModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: categoryName,
            color: colorCode!,
            iconCode: iconCode!,
          );

          // Ajouter la catégorie à Hive
          await Database.addCategory(newCategory);
          widget.onCategoryAdded(categoryName);

          // Créer et ajouter la notification
          var notification = NotificationModel(
              notificationId: Uuid().v4(),
              title: "Nouvelle Catégorie",
              content: "Une nouvelle catégorie a été créée",
              type: NotificationTypeEnum.INFORMATION,
              isRead: false,
              isArchived: false,
              date: DateTime.now());

          // Ajouter la notification à la base de données
          await Database.addNotification(notification);

          // Vérifier si le widget est toujours monté avant d'utiliser le contexte
          if (mounted) {
            SnackbarNotifier.show(
              context: context,
              message: "Catégorie '$categoryName' ajoutée avec succès !",
              type: 'success',
            );

            // Réinitialiser les champs et fermer le modal
            widget.categoryController.clear();
            Navigator.pop(context);
          }
        }
      } else {
        if (mounted) {
          SnackbarNotifier.show(
            context: context,
            message: "Erreur dans le formulaire",
            type: 'error',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        SnackbarNotifier.show(
            context: context,
            message: "Erreur dans le formulaire : $e",
            type: 'error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode
          ? theme.colorScheme.surface
          : Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDarkMode
            ? theme.colorScheme.surface
            : Color(0xFFF8F9FA),
        title: Text(
          'Ajouter une catégorie',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: theme.colorScheme.primary,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: modalFormKey,
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête de la page
              Container(
                margin: EdgeInsets.only(bottom: 24),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withAlpha(30),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.category,
                        color: theme.colorScheme.primary,
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Nouvelle catégorie",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Personnalisez vos catégories",
                          style: TextStyle(
                            fontSize: 14,
                            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Formulaire
              Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? theme.colorScheme.surfaceContainerHighest
                      : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: isDarkMode
                          ? Colors.black12
                          : Colors.grey.withAlpha(30),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Titre de la section
                    Text(
                      "Informations de la catégorie",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    SizedBox(height: 20),

                    // Nom de la catégorie
                    CustomTextFormField(
                      controller: widget.categoryController,
                      labelText: 'Nom de la catégorie',
                      hintText: 'Ex: Alimentation, Transport...',
                      prefixIcon: Icons.label,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ce champ est obligatoire';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 24),

                    // Titre de la section icône
                    Text(
                      "Personnalisation",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    SizedBox(height: 20),

                    // Aperçu de l'icône et de la couleur
                    Center(
                      child: Column(
                        children: [
                          // Aperçu
                          if (selectedIcon != null)
                            Container(
                              width: 80,
                              height: 80,
                              margin: EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: selectedColor ?? theme.colorScheme.primary,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: (selectedColor ?? theme.colorScheme.primary).withAlpha(70),
                                    blurRadius: 8,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Icon(
                                selectedIcon,
                                size: 40,
                                color: Colors.white,
                              ),
                            ),

                          // Boutons de sélection
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Bouton de sélection d'icône
                              Expanded(
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isDarkMode
                                        ? theme.colorScheme.surfaceContainerLow
                                        : Colors.grey[100],
                                    foregroundColor: theme.colorScheme.primary,
                                    elevation: 0,
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
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
                                  icon: Icon(
                                    selectedIcon ?? Icons.add_circle_outline,
                                    size: 20,
                                  ),
                                  label: Text(
                                    selectedIcon == null ? "Choisir une icône" : "Modifier l'icône",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),

                              // Bouton de sélection de couleur
                              Expanded(
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isDarkMode
                                        ? theme.colorScheme.surfaceContainerLow
                                        : Colors.grey[100],
                                    foregroundColor: selectedColor ?? theme.colorScheme.primary,
                                    elevation: 0,
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () async {
                                    final color = await ColorSelector().showColorSelector(context);
                                    if (color != null) {
                                      // Utiliser un Map pour associer les couleurs à leurs valeurs
                                      final Map<Color, int> colorValues = {
                                        Colors.pink: 0xFFE91E63,
                                        Colors.red: 0xFFF44336,
                                        Colors.orange: 0xFFFF9800,
                                        Colors.yellow: 0xFFFFEB3B,
                                        Colors.purple: 0xFF9C27B0,
                                        Color(0xFF242760): 0xFF242760,
                                        Colors.indigo: 0xFF3F51B5,
                                        Color(0xFF6E73C4): 0xFF6E73C4,
                                        Colors.blue: 0xFF2196F3,
                                        Colors.green: 0xFF4CAF50,
                                        Colors.teal: 0xFF009688,
                                        Colors.brown: 0xFF795548,
                                      };

                                      // Obtenir la valeur de la couleur ou utiliser une valeur par défaut
                                      int colorValue = colorValues[color] ?? 0xFF2196F3;

                                      setState(() {
                                        selectedColor = color;
                                        colorCode = colorValue;
                                      });
                                    }
                                  },
                                  icon: Icon(
                                    Icons.color_lens,
                                    size: 20,
                                  ),
                                  label: Text(
                                    selectedColor == null ? "Choisir une couleur" : "Modifier la couleur",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 30),

                    // Bouton d'ajout
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: saveCategory,
                        child: Text(
                          'Créer la catégorie',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
