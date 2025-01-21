import 'package:flutter/material.dart';
import 'package:trackmoney/DataBase/database.dart';
import 'package:trackmoney/models/account_model.dart';
import 'package:trackmoney/templates/components/account/card.dart';
import 'package:trackmoney/templates/components/customFormFields.dart';
import 'package:trackmoney/templates/pages/screens/compte.dart';
import 'package:uuid/uuid.dart';

class AccountPage extends StatefulWidget {
  final String type;
  const AccountPage({super.key, required this.type});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  bool activeIndicator = false;
  double amount = 0;
  String name = '';
  final String id = Uuid().v4();
  @override
  void initState() {
    super.initState();
    priceController.addListener(() {
      setState(() {
        amount = double.tryParse(priceController.text) ?? 0;
      });
    });
    nameController.addListener(() {
      setState(() {
        name = nameController.text;
      });
    });
  }

  @override
  void dispose() {
    priceController.dispose();
    nameController.dispose();
    super.dispose();
  }

  void _addAccount() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur de validation')),
      );
      return;
    }

    setState(() {
      activeIndicator = true;
    });

    final newAccount = AccountModel(
      id: id,
      name: name,
      type: widget.type,
      balance: amount,
    );

    try {
      await Database.addAccount(newAccount);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Compte ajouté avec succès')),
      );
      Navigator.pop(context,true); // Retour à la page précédente
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'ajout : $e')),
      );
    } finally {
      setState(() {
        activeIndicator = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Ajouter un Portefeuille",
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: activeIndicator
            ? Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary,
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  children: [
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          CustomTextFormField(
                            controller: nameController,
                            labelText: "Nom du portefeuille",
                            hintText: "Nom du portefeuille",
                            validator: (value) =>
                                value!.isEmpty ? "Veuillez renseigner ce champ" : null,
                          ),
                          const SizedBox(height: 20),
                          CustomTextFormField(
                            controller: priceController,
                            labelText: "Montant disponible",
                            hintText: "0.00",
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Ce champ est obligatoire';
                              }
                              if (!RegExp(r'^[0-9]*\.?[0-9]+$').hasMatch(value)) {
                                return 'Veuillez saisir un montant valide';
                              }
                              if (double.tryParse(value)! <= 0) {
                                return 'Veuillez saisir un montant positif';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.primary,
                              ),
                              child: Text(
                                'Ajouter',
                                style: TextStyle(
                                    color: Theme.of(context).colorScheme.surface),
                              ),
                              onPressed: _addAccount,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    CardComponent(
                      accountType: widget.type,
                      amount: amount,
                      accountName: name,
                      isCreating: true,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
