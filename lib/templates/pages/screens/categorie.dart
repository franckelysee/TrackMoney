import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:trackmoney/DataBase/database.dart';
import 'package:trackmoney/models/category_model.dart';
import 'package:trackmoney/routes/init_routes.dart';
import 'package:trackmoney/templates/components/button.dart';
import 'package:trackmoney/templates/components/category/category_card.dart';
import 'package:trackmoney/templates/components/customFormFields.dart';
import 'package:trackmoney/templates/components/notificated_card.dart';
import 'package:trackmoney/templates/components/category/category_modal.dart';
import 'package:trackmoney/templates/header.dart';
import 'package:trackmoney/utils/snackBarNotifyer.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final _formsearchkey = GlobalKey<FormState>();
  final TextEditingController searchCategoryController =
      TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController spendingNameController = TextEditingController();
  List<CategoryModel> categories = [];
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  void loadCategories() async {
    categories = await Database.getAllCategories();
    await Future.delayed(
        const Duration(milliseconds: 300)); // Simulate network delay
    setState(() {
      isLoading = false;
    });
  }

  void _submitForm() {
    if (_formsearchkey.currentState!.validate()) {
      // Rechercher les catégories correspondantes
      List<CategoryModel> searchCategories = [];
      setState(() {
        searchCategories = categories
            .where((category) => category.name
                .toLowerCase()
                .contains(searchCategoryController.text.toLowerCase()))
            .toList();

        // Affichage des résultats
        if (searchCategories.isEmpty) {
          // Afficher un message si aucune catégorie n'est trouvée
          SnackbarNotifier.show(
            context: context,
            message: "Aucune catégorie ne correspond à votre recherche",
            type: 'info',
          );
        } else {
          // Afficher les résultats dans un modal bottom sheet
          final theme = Theme.of(context);
          final isDarkMode = theme.brightness == Brightness.dark;

          showModalBottomSheet(
            context: context,
            backgroundColor: isDarkMode
                ? theme.colorScheme.surfaceContainerHighest
                : Colors.white,
            isScrollControlled: true,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            builder: (context) => Container(
              height: MediaQuery.of(context).size.height * 0.7,
              padding: const EdgeInsets.only(top: 8),
              child: buildSearchCategoriesList(searchCategories),
            ),
          );
        }
      });
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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: const AppHeader(title: 'Catégories'),
      ),
      body: isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: theme.colorScheme.primary,
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Chargement des catégories...",
                    style: TextStyle(
                      fontSize: 16,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // En-tête de la page
                  Container(
                    margin: EdgeInsets.only(bottom: 20),
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
                              "Vos catégories",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? Colors.white : Colors.black87,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Organisez vos transactions",
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

                  // Barre de recherche et bouton d'ajout
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                    child: Form(
                      key: _formsearchkey,
                      child: Row(
                        children: [
                          Expanded(
                            child: CustomTextFormField(
                              controller: searchCategoryController,
                              labelText: 'Rechercher une catégorie',
                              hintText: 'Ex: Alimentation, Transport...',
                              prefixIcon: Icons.search,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Veuillez entrer la catégorie que vous cherchez';
                                }
                                return null;
                              },
                              onFieldSubmitted: (_) {
                                _submitForm();
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          CircularButton(
                            color: theme.colorScheme.primary,
                            iconColor: Colors.white,
                            icon: Icons.add,
                            radius: 12,
                            onpressed: () {
                              Navigator.push(
                                context,
                                createRoute(
                                  CustomCategoryModal(
                                    categoryController: categoryController,
                                    onCategoryAdded: (newCategory) {
                                      setState(() {
                                        loadCategories();
                                      });
                                    },
                                  )
                                )
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Liste des catégories
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? theme.colorScheme.surfaceContainerLow
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: isDarkMode
                                ? Colors.black12
                                : Colors.grey.withAlpha(20),
                            blurRadius: 8,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: SingleChildScrollView(child: CategoryList()),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget buildSearchCategoriesList(List<CategoryModel> categories) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Column(
      children: [
        // Barre d'indication en haut
        Container(
          width: 40,
          height: 4,
          margin: EdgeInsets.only(top: 8, bottom: 16),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[600] : Colors.grey[300],
            borderRadius: BorderRadius.circular(2),
          ),
        ),

        // En-tête avec icône
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.only(left: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withAlpha(isDarkMode ? 50 : 30),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.search,
                color: theme.colorScheme.primary,
                size: 20,
              ),
            ),
            SizedBox(width: 16),
            Text(
              'Résultats de recherche',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),

        SizedBox(height: 20),

        // Nombre de résultats
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withAlpha(isDarkMode ? 40 : 30),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  '${categories.length} résultat${categories.length > 1 ? 's' : ''}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 16),

        // Liste des résultats
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length,
            itemBuilder: (context, index) => Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: NotificatedCard(
                icon: categories[index].icon,
                iconBackgroundColor: categories[index].colorValue,
                title: categories[index].name,
                titleSize: 16,
                backgroundColor: isDarkMode
                    ? theme.colorScheme.surfaceContainerLow
                    : Colors.white,
                textColor: isDarkMode ? Colors.white : null,
                onTap: () {
                  // Implementez la logique de navigation ici
                  Navigator.pop(context);
                  searchCategoryController.text = categories[index].name;
                },
                trailing: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDarkMode
                        ? theme.colorScheme.surfaceContainerHigh
                        : Colors.grey[100],
                  ),
                  child: Icon(
                    Icons.chevron_right,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class CategoryList extends StatefulWidget {
  const CategoryList({super.key});

  @override
  State<CategoryList> createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return ValueListenableBuilder(
      valueListenable: Hive.box<CategoryModel>('categories').listenable(),
      builder: (context, Box<CategoryModel> box, _) {
        if (box.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.category_outlined,
                  size: 60,
                  color: isDarkMode ? Colors.grey[500] : Colors.grey[400],
                ),
                SizedBox(height: 16),
                Text(
                  'Aucune catégorie trouvée',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.grey[300] : Colors.grey[600],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Ajoutez une catégorie en cliquant sur le bouton +',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final categories = box.values.toList();
        categories.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

        var month = DateTime.now().month;
        var categoriesMonth = categories.where((category) {
          return category.date.month == month;
        }).toList();

        return SizedBox(
          height: MediaQuery.of(context).size.height - 100,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Catégories du mois
              if (categoriesMonth.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 20,
                            color: theme.colorScheme.primary,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Catégories du mois',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                    SizedBox(
                      height: 180,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: categoriesMonth.length,
                        padding: EdgeInsets.symmetric(horizontal: 4),
                        itemBuilder: (context, index) {
                          return CategoryCard(
                            backgroundColor: categoriesMonth[index].colorValue,
                            icon: categoriesMonth[index].icon,
                            category: categoriesMonth[index].name,
                            onTap: () {
                              // Implementez la logique de navigation ici
                            },
                          );
                        }
                      ),
                    ),
                    SizedBox(height: 24),
                  ],
                ),

              // Toutes les catégories
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.category,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Toutes les catégories',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    SizedBox(width: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withAlpha(isDarkMode ? 40 : 30),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        '${categories.length}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),

              // Liste de toutes les catégories
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.only(top: 4),
                  itemCount: categories.length,
                  itemBuilder: (context, index) => Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: NotificatedCard(
                      icon: categories[index].icon,
                      iconBackgroundColor: categories[index].colorValue,
                      title: categories[index].name,
                      titleSize: 16,
                      backgroundColor: isDarkMode
                          ? theme.colorScheme.surfaceContainerLow
                          : Colors.white,
                      textColor: isDarkMode ? Colors.white : null,
                      onTap: () {
                        // Implementez la logique de navigation ici
                      },
                      trailing: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDarkMode
                              ? theme.colorScheme.surfaceContainerHigh
                              : Colors.grey[100],
                        ),
                        child: Icon(
                          Icons.chevron_right,
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
