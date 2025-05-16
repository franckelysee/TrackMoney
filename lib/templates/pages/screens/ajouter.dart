import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:trackmoney/models/account_model.dart';
import 'package:trackmoney/models/category_model.dart';
import 'package:trackmoney/models/notification_model.dart';
import 'package:trackmoney/models/transaction_model.dart';
import 'package:trackmoney/services/account_service.dart';
import 'package:trackmoney/services/category_service.dart';
import 'package:trackmoney/services/notification_service.dart';
import 'package:trackmoney/services/transaction_service.dart';
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
  final List<String> spendingTypeItems = ['Dépense', 'Revenu'];

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
    accounts = await AccountService.getAllAccounts();
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
      var newCats = await CategoryService.getAllCategories();
      accounts = await AccountService.getAllAccounts();
      setState(() {
        selectedCategoryid = newCats
            .firstWhere((category) => category.name == selectedCategory)
            .id
            .toString();
      });
      var type = spendingTypeController == 'Revenu'
          ? TransactionTypesEnum.revenu
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
      await TransactionService.addTransaction(transaction);

      if (mounted) {
        SnackbarNotifier.show(
            context: context,
            message: "Transaction ajouté avec succès",
            type: 'success',
            actionLabel: 'open',
            onAction: () {
              Navigator.push(context, createRoute(AnalysePage()));
            });
      }

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
      await NotificationService.addNotification(notification);
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
      if (mounted) {
        SnackbarNotifier.show(
            context: context,
            message: "Erreur lors de l'ajout  de la transaction: $e",
            type: 'error');
      }
    }
  }

  Future<bool> updateBalance() async {
    final accounts = await AccountService.getAllAccounts();
    final account =
        accounts.firstWhere((account) => account.type == accountController);
    double newBalance;
    if (spendingTypeController == 'Dépense') {
      newBalance = account.balance! - double.parse(priceController.text);
    } else {
      newBalance = account.balance! + double.parse(priceController.text);
    }
    if (newBalance < 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  "Impossible, ce compte ne peut pas débiter cette somme, car son solde est inférieur.")),
        );
      }
      return false;
    }
    account.balance = newBalance;
    await AccountService.updateAccount(account);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Déterminer la couleur en fonction du type de transaction
    Color transactionColor = spendingTypeController == 'Dépense'
        ? Color(0xFFF44336) // Rouge pour les dépenses
        : Color(0xFF4CAF50); // Vert pour les revenus

    if (spendingTypeController.isEmpty) {
      transactionColor = theme.colorScheme.primary;
    }

    return Scaffold(
      backgroundColor: isDarkMode
          ? theme.colorScheme.surface
          : Color(0xFFF8F9FA),
      resizeToAvoidBottomInset: false,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: AppHeader(
          title: spendingTypeController.isEmpty
              ? 'Ajouter une Transaction'
              : spendingTypeController == 'Dépense'
                  ? 'Ajouter une Dépense'
                  : 'Ajouter un Revenu',
        ),
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
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
                      color: transactionColor.withAlpha(30),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      spendingTypeController == 'Dépense'
                          ? Icons.arrow_upward
                          : spendingTypeController == 'Revenu'
                              ? Icons.arrow_downward
                              : Icons.add_card,
                      color: transactionColor,
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          spendingTypeController.isEmpty
                              ? "Nouvelle transaction"
                              : spendingTypeController == 'Dépense'
                                  ? "Nouvelle dépense"
                                  : "Nouveau revenu",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Enregistrez vos mouvements financiers",
                          style: TextStyle(
                            fontSize: 14,
                            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
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
              child: Form(
                key: _formkey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Type de transaction
                    Text(
                      "Type de transaction",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    SizedBox(height: 12),

                    // Sélection du type de transaction avec des boutons
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                spendingTypeController = 'Dépense';
                              });
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: spendingTypeController == 'Dépense'
                                    ? Color(0xFFF44336).withAlpha(isDarkMode ? 40 : 30)
                                    : isDarkMode
                                        ? theme.colorScheme.surfaceContainerLow
                                        : Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: spendingTypeController == 'Dépense'
                                      ? Color(0xFFF44336)
                                      : Colors.transparent,
                                  width: 1.5,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.arrow_upward,
                                    color: spendingTypeController == 'Dépense'
                                        ? Color(0xFFF44336)
                                        : isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                    size: 24,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    "Dépense",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: spendingTypeController == 'Dépense'
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: spendingTypeController == 'Dépense'
                                          ? Color(0xFFF44336)
                                          : isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                spendingTypeController = 'Revenu';
                              });
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: spendingTypeController == 'Revenu'
                                    ? Color(0xFF4CAF50).withAlpha(isDarkMode ? 40 : 30)
                                    : isDarkMode
                                        ? theme.colorScheme.surfaceContainerLow
                                        : Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: spendingTypeController == 'Revenu'
                                      ? Color(0xFF4CAF50)
                                      : Colors.transparent,
                                  width: 1.5,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.arrow_downward,
                                    color: spendingTypeController == 'Revenu'
                                        ? Color(0xFF4CAF50)
                                        : isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                    size: 24,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    "Revenu",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: spendingTypeController == 'Revenu'
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: spendingTypeController == 'Revenu'
                                          ? Color(0xFF4CAF50)
                                          : isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 24),

                    // Détails de la transaction
                    if (spendingTypeController.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Détails de la transaction",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                          ),
                          SizedBox(height: 16),

                          // Nom de la transaction
                          CustomTextFormField(
                            controller: spendingNameController,
                            labelText: 'Nom de la transaction',
                            hintText: 'Ex: Courses, Salaire...',
                            prefixIcon: Icons.description,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Ce champ est obligatoire';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16),

                          // Catégorie
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: ValueListenableBuilder(
                                  valueListenable: Hive.box<CategoryModel>('categories').listenable(),
                                  builder: (context, Box<CategoryModel> box, _) {
                                    final categories = box.values.toList();
                                    categories.sort((a, b) => a.name.compareTo(b.name));
                                    final categoryNames = categories.map((category) => category.name).toList();
                                    items = categoryNames;

                                    return CustomDropdownButtonFormField(
                                      initialValue: selectedCategory.isNotEmpty ? selectedCategory : null,
                                      items: items,
                                      onChanged: (value) {
                                        setState(() {
                                          selectedCategory = value!;
                                          selectedCategoryid = categories
                                              .firstWhere((category) => category.name == selectedCategory)
                                              .id
                                              .toString();
                                        });
                                      },
                                      errorText: 'Veuillez sélectionner une catégorie',
                                      hint: 'Catégorie',
                                      isRequired: true,
                                    );
                                  },
                                ),
                              ),
                              SizedBox(width: 12),
                              Container(
                                margin: EdgeInsets.only(top: 4),
                                child: CircularButton(
                                  color: transactionColor,
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
                                              selectedCategory = newCategory;
                                              refreshCategory();
                                            });
                                          }
                                        )
                                      )
                                    );
                                  },
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: 16),

                          // Compte
                          CustomDropdownButtonFormField(
                            initialValue: accountController.isNotEmpty ? accountController : null,
                            onChanged: (value) {
                              accountController = value!;
                            },
                            items: accounts.map((account) => account.type!).toList(),
                            errorText: 'Veuillez sélectionner un compte',
                            hint: 'Compte',
                            isRequired: true,
                          ),
                          SizedBox(height: 16),

                          // Montant
                          CustomTextFormField(
                            controller: priceController,
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                            labelText: 'Montant',
                            hintText: '0.00',
                            prefixIcon: Icons.attach_money,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Ce champ est obligatoire';
                              }
                              if (!RegExp(r'^[0-9]*\.?[0-9]+$').hasMatch(value)) {
                                return 'Veuillez saisir un montant valide';
                              }
                              if (double.tryParse(value) == null || double.parse(value) <= 0) {
                                return 'Veuillez saisir un montant positif';
                              }
                              return null;
                            },
                            onFieldSubmitted: (_) {
                              FocusScope.of(context).unfocus();
                              _addTransaction();
                            },
                          ),
                          SizedBox(height: 24),

                          // Bouton d'ajout
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: transactionColor,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: _addTransaction,
                              child: Text(
                                'Enregistrer',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
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
