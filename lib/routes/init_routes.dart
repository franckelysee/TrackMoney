import 'package:flutter/material.dart';
import 'package:trackmoney/utils/devise_list.dart';
import 'package:trackmoney/templates/home.dart';
import 'package:trackmoney/templates/pages/auth/auth.dart';
import 'package:trackmoney/templates/pages/screens/devise.dart';




Route onGenerateRoute(RouteSettings settings) {
  switch (settings.name) {
    case '/auth':
      return MaterialPageRoute(builder: (context) => const AuthPage());
    case '/Devise':
      return MaterialPageRoute(builder: (context) => DeviseSelector(devises: devises,));
    case '/home':
      return MaterialPageRoute(builder: (context) => const HomePage());
    default:
      return MaterialPageRoute(builder: (context) => const AuthPage());
  }
}

Route CreateROute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0); // Départ de droite
      const end = Offset.zero;
      const curve = Curves.easeInOut;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);

      return SlideTransition(
        position: offsetAnimation,
        child: child,
      );
    },
  );
}
