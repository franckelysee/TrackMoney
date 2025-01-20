import 'package:flutter/material.dart';
import 'package:trackmoney/DataBase/database.dart';
import 'package:trackmoney/models/account_model.dart';
import 'package:trackmoney/templates/components/account/card.dart';
import 'package:trackmoney/templates/components/customFormFields.dart';
import 'package:trackmoney/templates/pages/screens/compte.dart';

class AccountPage extends StatefulWidget {
  final String type;
  const AccountPage({super.key, required this.type});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController priceController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  bool activeIndicator = false;
  double amount = 0;
  String name = '';
  @override
  void initState() {
    // TODO: implement initState
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ajouter un Portefeuille",
            style: Theme.of(context).textTheme.headlineSmall),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Column(children: [
                Form(
                  key: _formKey,
                  child: Column(children: [
                    CustomTextFormField(
                      controller: nameController,
                      labelText: "Nom du portefeuille",
                      hintText: "Nom du portefeuille",
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Veuillez renseigner ce champ";
                        }
                        return null;
                      },
                    ),
                    SizedBox(
                      height: 20,
                    ),
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
                          return 'Veiller saisir un montant valide';
                        }
                        if (double.tryParse(value) == null ||
                            double.parse(value) <= 0) {
                          return 'Veiller saisir un montant positif';
                        }
                        setState(() {
                          amount = double.parse(value);
                        });
                        return null;
                      },
                    ),
                    SizedBox(
                      height: 20,
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
                            if (_formKey.currentState!.validate()) {
                              setState(() {
                                activeIndicator = true;
                                amount = double.parse(priceController.text);
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Processing Data')),
                              );
                              // ajouter dans la base de donnée local
                              var newAccount = AccountModel(
                                id: DateTime.now().millisecondsSinceEpoch,
                                name: name,
                                type: widget.type,
                                balance: amount);  
                              Database.addAccount(newAccount);
                                
                              
                              // Simulate API call
                              Future.delayed(const Duration(seconds: 3), () {
                                setState(() {
                                  activeIndicator = false;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Data added')),
                                );
                                // Navigate to account list page
                                Navigator.pop(context);
                              });
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Error')),
                              );
                            }
                          }),
                    ),
                  ]),
                ),
                SizedBox(
                  height: 30,
                ),
                CardComponent(
                  accountType: widget.type,
                  amount: amount,
                  accountName: name,
                  isCreating: true,
                )
              ]),
              SizedBox(
                height: 20,
              ),
              if (activeIndicator)
                CircularProgressIndicator(
                  color: Color(0xFF22C22D),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
