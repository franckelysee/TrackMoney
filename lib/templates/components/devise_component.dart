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
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 70,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? color ?? theme.colorScheme.primary
              : isDarkMode
                  ? theme.colorScheme.surfaceContainerLow
                  : Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: (color ?? theme.colorScheme.primary).withAlpha(50),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            // Icône de la devise ou icône par défaut
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withAlpha(50)
                    : (color ?? theme.colorScheme.primary).withAlpha(30),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon ?? Icons.attach_money,
                color: isSelected
                    ? Colors.white
                    : color ?? theme.colorScheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),

            // Nom de la devise
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: isSelected
                    ? Colors.white
                    : isDarkMode ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const Spacer(),

            // Code de la devise
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withAlpha(50)
                    : isDarkMode
                        ? theme.colorScheme.surfaceContainerHigh
                        : Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                devise,
                style: TextStyle(
                  fontSize: 14,
                  color: isSelected
                      ? Colors.white
                      : isDarkMode ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}