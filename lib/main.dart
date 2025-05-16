import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trackmoney/services/app_settings_service.dart';
import 'package:trackmoney/services/database_service.dart';
import 'package:trackmoney/services/firebase_service.dart';
import 'package:trackmoney/services/user_service.dart';
import 'package:trackmoney/templates/components/auth_check_wrapper.dart';
import 'package:trackmoney/templates/home.dart';
import 'package:trackmoney/templates/pages/auth/auth.dart';
import 'package:trackmoney/routes/init_routes.dart';
import 'package:trackmoney/utils/app_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Nécessaire pour initialiser Flutter

  // Initialiser Hive d'abord (stockage local)
  await DatabaseService.initHive();

  // Tenter d'initialiser Firebase, mais continuer même en cas d'échec
  try {
    await FirebaseService.initializeFirebase();
  } catch (e) {
    debugPrint("Erreur lors de l'initialisation de Firebase: $e");
    // Continuer sans Firebase
  }

  // Vérification de l'état de l'utilisateur
  bool isFirstLauch = await AppSettingsService.isFirstLaunch();

  // Vérifier s'il y a un utilisateur connecté localement
  final localUser = await UserService.getCurrentUser();

  // Vérifier s'il y a un utilisateur connecté dans Firebase
  bool isFirebaseUserLoggedIn = false;
  try {
    isFirebaseUserLoggedIn = FirebaseService.isUserLoggedIn();
  } catch (e) {
    debugPrint("Erreur lors de la vérification de l'utilisateur Firebase: $e");
  }

  // Si aucun utilisateur n'est connecté (ni Firebase ni local),
  // créer et connecter un utilisateur visiteur, sauf si c'est la première ouverture
  if (!isFirebaseUserLoggedIn && localUser == null) {
    if (!isFirstLauch) {
      // Créer et connecter un utilisateur visiteur
      await UserService.createGuestUser();
    }
  }

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
      title: 'TrackMoney',
      debugShowCheckedModeBanner: false,
      theme: Provider.of<ThemeProvider>(context).themeData,
      onGenerateRoute: onGenerateRoute,
      home: isFirstLaunch
          ? const AuthPage()
          : const AuthCheckWrapper(
              allowGuest: true,
              child: HomePage(),
            ),
    );
  }
}

