import 'package:flutter/material.dart';

class IconSelector {
  // ici c'est la liste des icon selectionnable par l'utilisateur pour distinguer la category de ses transaction
  final List<IconData> availableIcons = [
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
  ];
  Future<IconData?> showIconSelector(BuildContext context) async{
    return showModalBottomSheet<IconData>(
      context: context,
      builder: (context) {
        return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: availableIcons.length, 
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  Navigator.of(context).pop(availableIcons[index]);
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  ),
                  child: Icon(availableIcons[index], size: 40, color: Theme.of(context).colorScheme.secondary,),
                ),
              );
            }
          );
      },
    );
  }
}
