// auth_check_wrapper.dart
import 'package:flutter/material.dart';
import 'package:trackmoney/templates/pages/auth/auth.dart';
import 'package:trackmoney/utils/auth_middleware.dart';

/// Widget qui vérifie si un utilisateur est connecté avant d'afficher son contenu
/// Si aucun utilisateur n'est connecté, redirige vers la page d'authentification
class AuthCheckWrapper extends StatefulWidget {
  final Widget child;
  final bool allowGuest;

  const AuthCheckWrapper({
    Key? key,
    required this.child,
    this.allowGuest = true,
  }) : super(key: key);

  @override
  State<AuthCheckWrapper> createState() => _AuthCheckWrapperState();
}

class _AuthCheckWrapperState extends State<AuthCheckWrapper> {
  bool _isLoading = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    // Vérifier si un utilisateur est connecté
    final isAuthenticated = await AuthMiddleware.checkAuth(context);
    
    // Si l'utilisateur est connecté et que c'est un visiteur, vérifier si les visiteurs sont autorisés
    if (isAuthenticated && !widget.allowGuest) {
      final isGuest = await AuthMiddleware.isGuestUser();
      
      if (isGuest && mounted) {
        // Si c'est un visiteur et que les visiteurs ne sont pas autorisés, rediriger vers la page d'authentification
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const AuthPage()),
          (route) => false,
        );
        return;
      }
    }
    
    if (mounted) {
      setState(() {
        _isLoading = false;
        _isAuthenticated = isAuthenticated;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    if (!_isAuthenticated) {
      return const AuthPage();
    }
    
    return widget.child;
  }
}
