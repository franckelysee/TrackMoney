import 'package:flutter/material.dart';
import 'package:trackmoney/templates/components/button.dart';
import 'package:trackmoney/templates/header.dart';

class AjouterPage extends StatefulWidget {
  const AjouterPage({super.key});

  @override
  State<AjouterPage> createState() => _AjouterPageState();
}

class _AjouterPageState extends State<AjouterPage> {
  String dropdownValue = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: AppHeader(title: 'Ajouter une Depense'),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child:  SizedBox(
          width: MediaQuery.of(context).size.width - 40,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "USD",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButton<String>(
                        hint: Text(
                          "Selectionnez la Categorie de Dépense",
                          style: TextStyle(fontSize: 14),
                        ),
                        value: dropdownValue.isEmpty ? null : dropdownValue,
                        icon: const Icon(Icons.arrow_drop_down),
                        isExpanded: true,
                        dropdownColor: Theme.of(context).cardColor,
                        onChanged: (String? newValue) {
                          setState(() {
                            dropdownValue = newValue!;
                          });
                        },
                        items: [
                          DropdownMenuItem<String>(
                            value: 'Immobilier',
                            child: Text("Immobilier"),
                          ),
                          DropdownMenuItem<String>(
                            value: 'Nourriture',
                            child: Text("Nourriture"),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  CircularButton(
                    icon: Icons.add,
                    radius: 10,
                    onpressed: () {
                      showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            return  Center(
                              child: ElevatedButton(
                                child: Text('Close'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            );
                          });
                    },
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
