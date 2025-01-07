import 'package:flutter/material.dart';
import 'package:trackmoney/templates/components/button.dart';
import 'package:trackmoney/templates/components/category_card.dart';
import 'package:trackmoney/templates/components/customFormFields.dart';
import 'package:trackmoney/templates/components/notificated_card.dart';
import 'package:trackmoney/templates/components/spendingModal.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: const AppHeader(title: 'Categories')),
      body: Padding(
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
                            child: CustomSpendingBottomModal(
                              spendingNameController: spendingNameController,
                              categoryController: categoryController,
                              onCategoryAdded: (newCategory) {
                                // Implémentez la logique d'ajout ici
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
                child: Column(
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
                          itemCount: 5,
                          itemBuilder: (context, index) {
                            return CategoryCard(
                                icon: Icons.home,
                                category: 'Loyer',
                                onTap: () {
                                  print('object');
                                },
                                price: 658.00);
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
                        itemCount: 10, // Nombre d'éléments dans la liste
                        itemBuilder: (context, index) =>NotificatedCard(
                            icon: Icons.home,
                            title: 'Loyer',
                            titleSize: 25,
                            subtitle: 'Location',

                            onTap: () {
                              print('Item $index tapé');
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
