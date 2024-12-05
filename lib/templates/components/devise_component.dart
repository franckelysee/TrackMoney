import 'package:flutter/material.dart';


class DeviseComponent extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? color;
  final bool isSelected; // Permet de savoir si l'élément est sélectionné
  final VoidCallback? onTap;
  final String devise;

  const DeviseComponent({
    super.key,
    required this.label,
    this.icon,
    this.color,
    required this.isSelected,
    required this.onTap,
    required this.devise
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        margin: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: color??const Color(0xFFD9D9D9), 
          // borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            if (icon != null) Icon(icon),
            const SizedBox(width: 10),  
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: isSelected? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Text(
              devise,
              style: TextStyle(
                fontSize: 16,
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}