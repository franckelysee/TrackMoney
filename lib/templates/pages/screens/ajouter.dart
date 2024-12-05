import 'package:flutter/material.dart';
import 'package:trackmoney/templates/header.dart';

class AjouterPage extends StatefulWidget {
  const AjouterPage({super.key});

  @override
  State<AjouterPage> createState() => _AjouterPageState();
}

class _AjouterPageState extends State<AjouterPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: AppHeader(title: 'Ajouter une Depense')),
      body: Center(
        child: Text('Ajouter'),
      ),
    );
  }
}