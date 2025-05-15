import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trackmoney/DataBase/database.dart';
import 'package:trackmoney/templates/home.dart';
import 'package:trackmoney/templates/pages/auth/auth.dart';
import 'package:trackmoney/routes/init_routes.dart';
import 'package:trackmoney/utils/app_config.dart';

void main() async {
  await Database.initHive(); // Initialisation de Hive

  // Vérification de l'état de l'utilisateur
  bool isFirstLauch = await Database.isFirstLaunch();

  runApp(ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: MyApp(
        isFirstLaunch: isFirstLauch,
      )));
}

class MyApp extends StatelessWidget {
  final bool isFirstLaunch;
  const MyApp({super.key, required this.isFirstLaunch});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: Provider.of<ThemeProvider>(context).themeData,
      onGenerateRoute: onGenerateRoute,
      // home: isFirstLaunch ? const AuthPage() : const AuthPage(),
      home: isFirstLaunch ? const AuthPage() : const HomePage(),
    );
  }
}

 