import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:trackmoney/DataBase/database.dart';
import 'package:trackmoney/models/account_model.dart';
import 'package:trackmoney/models/category_model.dart';
import 'package:trackmoney/models/notification_model.dart';
import 'package:trackmoney/models/transaction_model.dart';
import 'package:trackmoney/routes/init_routes.dart';
import 'package:trackmoney/templates/components/button.dart';
import 'package:trackmoney/templates/components/customFormFields.dart';
import 'package:trackmoney/templates/components/category/category_modal.dart';
import 'package:trackmoney/templates/header.dart';
import 'package:trackmoney/templates/pages/screens/analyse.dart';
import 'package:trackmoney/utils/notification_type_enum.dart';
import 'package:trackmoney/utils/snackBarNotifyer.dart';
import 'package:trackmoney/utils/transaction_types_enum.dart';
import 'package:uuid/uuid.dart';

class AjouterPage extends StatefulWidget {
  const AjouterPage({super.key});

  @override
  State<AjouterPage> createState() => _AjouterPageState();
}

class _AjouterPageState extends State<AjouterPage> {
  final _formkey = GlobalKey<FormState>();
  List<String> items = [];
  List<AccountModel> accounts = [];
  final List<String> spendingTypeItems = ['Dépense', 'Recette'];

  final TextEditingController priceController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController spendingNameController = TextEditingController();
  String selectedCategory = '';
  String selectedCategoryid = '';
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

    refreshCategory();
    refreshAccounts();
  }

  void refreshCategory() async {
    setState(() {
      final box = Hive.box<CategoryModel>('categories').values.toList();
      items = box.map((category) => category.name).toList();
    });
  }

  void refreshAccounts() async {
    accounts = await Database.getAllAccounts();
    setState(() {});
  }

  void _addTransaction() async {
    if (!_formkey.currentState!.validate()) {
      SnackbarNotifier.show(
        context: context,
        message: "Erreur de validation",
        type: 'error',
      );
      return;
    }
    try {
      var newCats = await Database.getAllCategories();
      accounts = await Database.getAllAccounts();
      setState(() {
        selectedCategoryid = newCats
            .firstWhere((category) => category.name == selectedCategory)
            .id
            .toString();
      });
      var type = spendingTypeController == 'Recette'
          ? TransactionTypesEnum.recette
          : TransactionTypesEnum.depense;
      var paymentName = spendingNameController.text;
      var price = double.parse(priceController.text);
      var accountId = accounts
          .firstWhere((account) => account.type! == accountController)
          .id
          .toString();
      var id = Uuid().v4();
      var transaction = TransactionModel(
          id: id,
          type: type,
          name: paymentName,
          categoryId: selectedCategoryid != '' ? selectedCategoryid : '',
          accountId: accountId,
          amount: price,
          date: DateTime.now());

      var isbalanceUpdated = await updateBalance();
      if (!isbalanceUpdated) {
        return;
      }
      await Database.addTransaction(transaction);
      SnackbarNotifier.show(
          context: context,
          message: "Transaction ajouté avec succès",
          type: 'success',
          actionLabel: 'open',
          onAction: () {
            Navigator.push(context, createRoute(AnalysePage()));
          });

      // notification
      var notification = NotificationModel(
          notificationId: Uuid().v4(),
          title: "Nouvelle transaction",
          content: "Une nouvelle transaction a été ajoutée",
          type: NotificationTypeEnum.INFORMATION,
          isRead: false,
          isArchived: false,
          date: DateTime.now());

      // add notification to database
      await Database.addNotification(notification);
      setState(() {
        _formkey.currentState!.reset();
        priceController.clear();
        categoryController.clear();
        spendingNameController.clear();
        selectedCategory = '';
        accountController = '';
        spendingTypeController = '';
      });
      // Navigator.pushAndRemoveUntil(context, CreateROute(HomePage()),
      //             (Route<dynamic> route) => false);
    } catch (e) {
      SnackbarNotifier.show(
          context: context,
          message: "Erreur lors de l'ajout  de la transaction: $e",
          type: 'error');
    }
  }

  Future<bool> updateBalance() async {
    final box = await Hive.openBox<AccountModel>('accounts');
    final account =
        box.values.firstWhere((account) => account.type == accountController);
    double newBalance;
    if (spendingTypeController == 'Dépense') {
      newBalance = account.balance! - double.parse(priceController.text);
    } else {
      newBalance = account.balance! + double.parse(priceController.text);
    }
    if (newBalance < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                "Impossible, ce compte ne peut pas débiter cette somme, car son solde est inférieur.")),
      );
      return false;
    }
    account.balance = newBalance;
    await Database.updateAccount(account);
    return true;
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
                        setState(() {});
                      },
                      items: spendingTypeItems,
                      errorText: 'Selectionner le type ',
                      hint: 'Selectionner le type de transaction',
                      isRequired: true,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    // Afficher le champ seulement si nécessaire
                    Column(
                      children: [
                        CustomTextFormField(
                          controller: spendingNameController,
                          labelText:
                              'Entrer le nom de la $spendingTypeController',
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
                                child: ValueListenableBuilder(
                              valueListenable:
                                  Hive.box<CategoryModel>('categories')
                                      .listenable(),
                              builder: (context, Box<CategoryModel> box, _) {
                                final categories = box.values.toList();
                                // Tri des catégories par ordre alphabétique
                                categories
                                    .sort((a, b) => a.name.compareTo(b.name));
                                // cree une liste des noms de catégories
                                final categoryNames = categories
                                    .map((category) => category.name)
                                    .toList();
                                items = categoryNames;
                                return CustomDropdownButtonFormField(
                                  initialValue: selectedCategory.isNotEmpty
                                      ? selectedCategory
                                      : null,
                                  items: items,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedCategory = value!;
                                      selectedCategoryid = categories
                                          .firstWhere((category) =>
                                              category.name == selectedCategory)
                                          .id
                                          .toString();
                                    });
                                  },
                                  errorText:
                                      'Veiller Selectionner une Categorie de dépense',
                                  hint: 'Selectionner la Categorie de dépense',
                                  isRequired: true,
                                );
                              },
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
                                          child: CustomCategoryModal(
                                              categoryController:
                                                  categoryController,
                                              onCategoryAdded: (newCategory) {
                                                setState(() {
                                                  selectedCategory =
                                                      newCategory;
                                                  refreshCategory();
                                                });
                                              }));
                                    });
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
                      items: accounts.map((account) => account.type!).toList(),
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
                        onPressed: _addTransaction,
                        child: Text(
                          'Ajouter',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.surface),
                        ),
                      ),
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
