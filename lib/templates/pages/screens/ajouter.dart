import 'package:flutter/material.dart';
import 'package:trackmoney/templates/components/button.dart';
import 'package:trackmoney/templates/components/customFormFields.dart';
import 'package:trackmoney/templates/components/spendingModal.dart';
import 'package:trackmoney/templates/header.dart';

class AjouterPage extends StatefulWidget {
  const AjouterPage({super.key});

  @override
  State<AjouterPage> createState() => _AjouterPageState();
}

class _AjouterPageState extends State<AjouterPage> {
  final _formkey = GlobalKey<FormState>();
  List<String> items = [
    'Immobilier',
    'Nourriture',
    'Transport',
    'Loisir',
    'Voyage',
    'Autre'
  ];
  final List<String> accountItems = [
    'Compte Espece',
    'Compte Bancaire',
    'Compte Mobile'
  ];
  final List<String> spendingTypeItems = ['Dépense', 'Recette'];

  final TextEditingController priceController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController spendingNameController = TextEditingController();
  String selectedCategory = '';
  String accountController = '';
  String spendingTypeController = '';
  final timestamp = DateTime.timestamp();
  bool showCategoryField = true;
  @override
  void initState() {
    super.initState();
    priceController.addListener(() {
      if (priceController.text.isEmpty ||
          double.tryParse(priceController.text) == null ||
          double.parse(priceController.text) < 0) {
        priceController.text = '';
      }
    });
    categoryController.addListener(() {
      if (categoryController.text.isEmpty) {
        categoryController.text = selectedCategory;
      }
    });
  }

  void refreshCategory() {
    setState(() {
      selectedCategory = items[items.length -1];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: AppHeader(title: 'Ajouter une Depense'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: SizedBox(
          width: MediaQuery.of(context).size.width - 40,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "USD",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Form(
                key: _formkey,
                child: Column(
                  children: [
                    CustomDropdownButtonFormField(
                      onChanged: (value) {
                        spendingTypeController = value!;
                        // mettre a jour la visibilité du champ categorie
                        setState(() {
                          showCategoryField =
                              spendingTypeController == 'Dépense';
                        });
                      },
                      items: spendingTypeItems,
                      errorText: 'Selectionner le type ',
                      hint: 'Selectionner le type ',
                      isRequired: true,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    if (showCategoryField) // Afficher le champ seulement si nécessaire
                      Column(
                        children: [
                          CustomTextFormField(
                            controller: spendingNameController,
                            labelText: 'Entrer le nom de la dépense',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Ce champ est obligatoire';
                              }
                              return null;
                            },
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                  child: CustomDropdownButtonFormField(
                                initialValue: selectedCategory.isNotEmpty
                                    ? selectedCategory
                                    : null,
                                items: items,
                                onChanged: (value) {
                                  setState(() {
                                    selectedCategory = value!;
                                  });
                                },
                                errorText:
                                    'Veiller Selectionner une Categorie de dépense',
                                hint: 'Selectionner la Categorie de dépense',
                                isRequired: true,
                              )),
                              SizedBox(
                                width: 8,
                              ),
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
                                          spendingNameController:
                                              spendingNameController,
                                          categoryController:
                                              categoryController,
                                          onCategoryAdded: (newCategory) {
                                            setState(() {
                                              // Ajout de la nouvelle catégorie uniquement si elle n'existe pas déjà
                                              if (!items.contains(
                                                  newCategory)) {
                                                items = List.from(items)
                                                  ..add(newCategory);
                                              }
                                              // Assurez-vous de mettre à jour la catégorie sélectionnée avec la nouvelle valeur
                                              selectedCategory =
                                                  newCategory;
                                              // Rafraîchissez la catégorie sélectionnée
                                              refreshCategory();
                                            });
                                          }
                                        )
                                      );
                                    }
                                  );
                                },
                              )
                            ],
                          ),
                        ],
                      ),
                    SizedBox(
                      height: 16,
                    ),
                    CustomDropdownButtonFormField(
                      onChanged: (value) {
                        accountController = value!;
                      },
                      items: accountItems,
                      errorText: 'Veiller Selectionner un Compte',
                      hint: 'Selectionner un Compte',
                      isRequired: true,
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    CustomTextFormField(
                      controller: priceController,
                      keyboardType: TextInputType.numberWithOptions(),
                      labelText: 'Entrer le montant',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ce champ est obligatoire';
                        }
                        if (!RegExp(r'^[0-9]*\.?[0-9]+$').hasMatch(value)) {
                          return 'Veiller saisir un montant valide';
                        }
                        if (double.tryParse(value) == null ||
                            double.parse(value) <= 0) {
                          return 'Veiller saisir un montant positif';
                        }
                        return null;
                      },
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary),
                          child: Text(
                            'Ajouter',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.surface),
                          ),
                          onPressed: () {
                            if (_formkey.currentState!.validate()) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Processing Data')),
                              );
                              // afficher les données du formulaire dans un SnackBar
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                        title: Text('Success'),
                                        content: Text(
                                            'price: ${priceController.text}'), // afficher ce qui a été saisi par l'utilisateur
                                        actions: [
                                          TextButton(
                                            child: Text('OK'),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          TextButton(
                                            child: Text('Cancel'),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ]);
                                  });
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Error')),
                              );
                            }
                          }),
                    ),
                    SizedBox(
                      height: 16,
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
