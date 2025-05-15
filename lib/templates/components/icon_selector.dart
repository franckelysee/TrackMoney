import 'package:flutter/material.dart';

class IconSelector {
  // ici c'est la liste des icon selectionnable par l'utilisateur pour distinguer la category de ses transaction
  final List<IconData> availableIcons = [
    Icons.attach_money_sharp,
    Icons.local_atm,
    Icons.account_balance_outlined,
    Icons.analytics_outlined,
    Icons.add_outlined,
    Icons.home,
    Icons.home_repair_service,
    Icons.accessibility_new,
    Icons.fastfood,
    Icons.directions_car,
    Icons.travel_explore,
    Icons.local_mall,
    Icons.restaurant,
    Icons.hotel,
    Icons.shopping_bag,
    Icons.airport_shuttle,
    Icons.cake,
    Icons.shopping_cart,
    Icons.sports_soccer,
    Icons.movie,
    Icons.pets,
    Icons.school,
    Icons.health_and_safety,
    Icons.local_hospital,
    Icons.local_pharmacy,
    Icons.local_dining,
    Icons.tv,
    Icons.theaters,
    Icons.girl,
    Icons.gamepad,
  ];
  Future<IconData?> showIconSelector(BuildContext context) async {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return showModalBottomSheet<IconData>(
      context: context,
      backgroundColor: isDarkMode
          ? theme.colorScheme.surfaceContainerHighest
          : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Column(
          children: [
            // Barre d'indication en haut
            Container(
              width: 40,
              height: 4,
              margin: EdgeInsets.only(top: 12, bottom: 16),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[600] : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Titre
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withAlpha(isDarkMode ? 50 : 30),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.emoji_objects,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 16),
                  Text(
                    "Choisir une icône",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16),

            // Grille d'icônes
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: availableIcons.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        Navigator.of(context).pop(availableIcons[index]);
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: isDarkMode
                              ? theme.colorScheme.surfaceContainerLow
                              : Colors.grey[100],
                        ),
                        child: Icon(
                          availableIcons[index],
                          size: 32,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    );
                  }
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
