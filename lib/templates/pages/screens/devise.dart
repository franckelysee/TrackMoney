import 'package:flutter/material.dart';
import 'package:trackmoney/models/divise_model.dart';
import 'package:trackmoney/routes/init_routes.dart';
import 'package:trackmoney/templates/components/button.dart';
import 'package:trackmoney/templates/components/devise_component.dart';
import 'package:trackmoney/templates/home.dart';
import 'package:trackmoney/utils/app_config.dart';

class DeviseSelector extends StatefulWidget {
  const DeviseSelector({super.key, required this.devises});
  final List<Devise> devises;
  @override
  State<DeviseSelector> createState() => _DeviseSelectorState();
}

class _DeviseSelectorState extends State<DeviseSelector> {
  int selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    widget.devises.sort((a, b) => a.name.compareTo(b.name));
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            height: 250,
            width: double.infinity,
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text(
                "Choisir Sa Devise Initial",
                style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                  border: Border.all(
                    color: AppConfig.primaryColor,
                    width: 1.0,
                  ),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Rechercher...",
                      suffixIcon:
                          Icon(Icons.search, color: AppConfig.primaryColor)),
                ),
              ),
            ]),
          ),
          Expanded(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(widget.devises.length, (index) {
              final devise = widget.devises[index];
              return DeviseComponent(
                  label: devise.name,
                  devise: devise.devise,
                  isSelected: selectedIndex == index,
                  color: selectedIndex == index ? AppConfig.primaryColor : null,
                  onTap: () {
                    setState(() {
                      selectedIndex = index;
                    });
                  });
            }),
          )),
          const SizedBox(
            height: 20,
          ),
          MyButton(
              label: "Suivant",
              color: AppConfig.primaryColor,
              textColor: Colors.white,
              onPressed: () {
                Navigator.pushAndRemoveUntil(context, createRoute(HomePage()),
                    (Route<dynamic> route) => false);
              }),
          const SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }
}
