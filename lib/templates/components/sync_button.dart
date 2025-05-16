import 'package:flutter/material.dart';
import 'package:trackmoney/services/sync_service.dart';
import 'package:trackmoney/templates/components/auth_required_modal.dart';
import 'package:trackmoney/utils/user_utils.dart';

/// Bouton de synchronisation qui vérifie si l'utilisateur est connecté
/// et affiche un modal si nécessaire.
class SyncButton extends StatefulWidget {
  final VoidCallback? onSyncComplete;
  final Color? color;
  final bool showText;
  final bool mini;
  
  const SyncButton({
    Key? key,
    this.onSyncComplete,
    this.color,
    this.showText = true,
    this.mini = false,
  }) : super(key: key);

  @override
  State<SyncButton> createState() => _SyncButtonState();
}

class _SyncButtonState extends State<SyncButton> {
  bool _isSyncing = false;
  
  /// Synchroniser les données
  Future<void> _syncData() async {
    // Vérifier si l'utilisateur est un visiteur
    final isGuest = await UserUtils.isGuestUser();
    
    if (isGuest) {
      // Afficher le modal d'authentification
      final result = await AuthRequiredModal.show(
        context,
        title: 'Synchronisation non disponible',
        message: 'Vous êtes actuellement connecté en tant que visiteur. Connectez-vous ou créez un compte pour synchroniser vos données.',
      );
      
      // Si l'utilisateur a cliqué sur "Se connecter", le modal le redirigera vers la page d'authentification
      return;
    }
    
    // Vérifier si l'utilisateur peut synchroniser
    final canSync = await SyncService.canSync();
    
    if (!canSync) {
      // Afficher un message d'erreur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vous devez être connecté pour synchroniser vos données.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // Synchroniser les données
    if (mounted) {
      setState(() {
        _isSyncing = true;
      });
    }
    
    try {
      final success = await SyncService.syncAll();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success 
                ? 'Synchronisation réussie !' 
                : 'Échec de la synchronisation. Veuillez réessayer plus tard.'
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
        
        if (success && widget.onSyncComplete != null) {
          widget.onSyncComplete!();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la synchronisation: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSyncing = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = widget.color ?? theme.colorScheme.primary;
    
    if (widget.mini) {
      return IconButton(
        onPressed: _isSyncing ? null : _syncData,
        icon: _isSyncing 
          ? SizedBox(
              width: 20, 
              height: 20, 
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: color,
              ),
            )
          : Icon(Icons.sync, color: color),
        tooltip: 'Synchroniser',
      );
    }
    
    return ElevatedButton.icon(
      onPressed: _isSyncing ? null : _syncData,
      icon: _isSyncing 
        ? SizedBox(
            width: 20, 
            height: 20, 
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
        : Icon(Icons.sync),
      label: widget.showText 
        ? Text('Synchroniser') 
        : SizedBox.shrink(),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(
          horizontal: widget.showText ? 16 : 12,
          vertical: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
