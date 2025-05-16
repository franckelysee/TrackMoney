import 'package:flutter/material.dart';
import 'package:trackmoney/models/divise_model.dart';
import 'package:trackmoney/routes/init_routes.dart';
import 'package:trackmoney/services/user_service.dart';
import 'package:trackmoney/templates/components/devise_component.dart';
import 'package:trackmoney/templates/home.dart';

class DeviseSelector extends StatefulWidget {
  const DeviseSelector({
    super.key,
    required this.devises,
    this.userId,
  });

  final List<Devise> devises;
  final String? userId;

  @override
  State<DeviseSelector> createState() => _DeviseSelectorState();
}

class _DeviseSelectorState extends State<DeviseSelector> {
  int selectedIndex = 0;
  late List<Devise> filteredDevises;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredDevises = List.from(widget.devises);

    // Ajouter un écouteur pour le champ de recherche
    searchController.addListener(_filterDevises);
  }

  @override
  void dispose() {
    searchController.removeListener(_filterDevises);
    searchController.dispose();
    super.dispose();
  }

  // Méthode pour naviguer vers la page d'accueil
  void _navigateToHome() {
    Navigator.pushAndRemoveUntil(
      context,
      createRoute(HomePage()),
      (Route<dynamic> route) => false
    );
  }

  // Filtrer les devises en fonction du texte de recherche
  void _filterDevises() {
    final query = searchController.text.toLowerCase();

    setState(() {
      if (query.isEmpty) {
        // Si la recherche est vide, afficher toutes les devises
        filteredDevises = List.from(widget.devises);
      } else {
        // Sinon, filtrer les devises en fonction du texte de recherche
        filteredDevises = widget.devises.where((devise) {
          return devise.name.toLowerCase().contains(query) ||
                 devise.devise.toLowerCase().contains(query);
        }).toList();
      }

      // Réinitialiser l'index sélectionné si nécessaire
      if (selectedIndex >= filteredDevises.length && filteredDevises.isNotEmpty) {
        selectedIndex = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Trier les devises par nom
    widget.devises.sort((a, b) => a.name.compareTo(b.name));

    return Scaffold(
      backgroundColor: isDarkMode
          ? theme.colorScheme.surface
          : Color(0xFFF8F9FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête de la page
              Container(
                margin: EdgeInsets.only(bottom: 30),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withAlpha(30),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.currency_exchange,
                        color: theme.colorScheme.primary,
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Choisir votre devise",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Sélectionnez la devise principale",
                          style: TextStyle(
                            fontSize: 16,
                            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Barre de recherche
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: isDarkMode
                      ? theme.colorScheme.surfaceContainerHighest
                      : Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: isDarkMode
                          ? Colors.black12
                          : Colors.grey.withAlpha(30),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Rechercher une devise...",
                    hintStyle: TextStyle(
                      color: isDarkMode ? Colors.grey[500] : Colors.grey[400],
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    suffixIcon: searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: Colors.grey, size: 20),
                          onPressed: () {
                            searchController.clear();
                          },
                        )
                      : null,
                  ),
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                  onChanged: (_) => _filterDevises(),
                ),
              ),

              // Titre de la section
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 12),
                child: Row(
                  children: [
                    Icon(
                      Icons.list,
                      size: 18,
                      color: theme.colorScheme.primary,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Devises disponibles',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    SizedBox(width: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withAlpha(isDarkMode ? 40 : 30),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        '${filteredDevises.length}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Liste des devises
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? theme.colorScheme.surfaceContainerLow
                        : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: isDarkMode
                            ? Colors.black12
                            : Colors.grey.withAlpha(20),
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: filteredDevises.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 48,
                                color: theme.colorScheme.primary.withAlpha(150),
                              ),
                              SizedBox(height: 16),
                              Text(
                                "Aucune devise trouvée",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          itemCount: filteredDevises.length,
                          itemBuilder: (context, index) {
                            final devise = filteredDevises[index];
                            return DeviseComponent(
                              label: devise.name,
                              devise: devise.devise,
                              isSelected: selectedIndex == index,
                              color: theme.colorScheme.primary,
                              onTap: () {
                                setState(() {
                                  selectedIndex = index;
                                });
                              },
                            );
                          },
                        ),
                  ),
                ),
              ),

              // Bouton de validation
              Container(
                margin: EdgeInsets.only(top: 24),
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: filteredDevises.isEmpty ? null : () async {
                    // Récupérer la devise sélectionnée
                    final selectedDevise = filteredDevises[selectedIndex];

                    // Si un ID utilisateur est fourni, mettre à jour la devise par défaut
                    if (widget.userId != null) {
                      try {
                        // Récupérer l'utilisateur
                        final user = await UserService.getUserById(widget.userId!);

                        if (user != null) {
                          // Mettre à jour la devise par défaut
                          await UserService.updateUser(
                            user.copyWith(defaultCurrency: selectedDevise.devise)
                          );
                        }
                      } catch (e) {
                        // Utiliser un logger en production au lieu de print
                        debugPrint('Erreur lors de la mise à jour de la devise: $e');
                      }
                    }

                    // Naviguer vers la page d'accueil
                    if (mounted) {
                      _navigateToHome();
                    }
                  },
                  child: Text(
                    "Continuer",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
