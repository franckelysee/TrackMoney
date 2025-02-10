import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:trackmoney/DataBase/database.dart';
import 'package:trackmoney/models/category_model.dart';
import 'package:trackmoney/templates/components/button.dart';
import 'package:trackmoney/templates/components/category/category_card.dart';
import 'package:trackmoney/templates/components/customFormFields.dart';
import 'package:trackmoney/templates/components/notificated_card.dart';
import 'package:trackmoney/templates/components/category/category_modal.dart';
import 'package:trackmoney/templates/header.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: const AppHeader(title: 'Categories')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: Column(
                children: [
                  Form(
                    key: _formsearchkey,
                    child: Row(
                      children: [
                        Expanded(
                          child: CustomTextFormField(
                            controller: searchCategoryController,
                            labelText: 'Rechercher une catégorie',
                            suffixIcon: Icons.search,
                          ),
                        ),
                        const SizedBox(width: 8),
                        CircularButton(
                          color: Theme.of(context).colorScheme.primary,
                          icon: Icons.add,
                          radius: 10,
                          onpressed: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (BuildContext context) {
                                return SingleChildScrollView(
                                  child: CustomCategoryModal(
                                    categoryController: categoryController,
                                    onCategoryAdded: (newCategory) {
                                      // Implémentez la logique d'ajout ici
                                      setState(() {
                                        loadCategories();
                                      });
                                    },
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      color: Theme.of(context).cardColor,
                      padding: const EdgeInsets.all(8),
                      child: (categories.isEmpty)
                          ? Center(
                              child: Text('Aucune catégorie trouvée'),
                            )
                          : CategoryList(),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class SearchBar extends StatefulWidget {
  const SearchBar({super.key});

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
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
    return ValueListenableBuilder(
      valueListenable: Hive.box<CategoryModel>('categories').listenable(),
      builder: (context, Box<CategoryModel> box, _) {
        if (box.isEmpty) {
          return const Center(
            child: Text('Aucune catégorie trouvée'),
          );
        }
        final categories = box.values.toList();
        return Column(
          children: [
            const Text(
              'Categories du mois',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 200,
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    return CategoryCard(
                      backgroundColor: categories[index].colorValue,
                      icon: categories[index].icon,
                      category: categories[index].name,
                      onTap: () {
                        // Implementez la logique de navigation ici
                      },
                    );
                  }),
            ),
            const SizedBox(height: 10),
            const Text(
              'Toutes les Catégories',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: categories.length, // Nombre d'éléments dans la liste
                itemBuilder: (context, index) => NotificatedCard(
                  icon: categories[index].icon,
                  iconBackgroundColor: categories[index].colorValue,
                  title: categories[index].name,
                  titleSize: 25,
                  onTap: () {
                    // Implementez la logique de navigation ici
                  },
                  trailing: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[300],
                    ),
                    child: Icon(Icons.chevron_right),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
