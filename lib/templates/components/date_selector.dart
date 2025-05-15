import 'package:flutter/material.dart';

class DateSelector extends StatefulWidget {
  final Function(DateTime) onDateSelected;
  const DateSelector({super.key, required this.onDateSelected});

  @override
  State<DateSelector> createState() => _DateSelectorState();
}

class _DateSelectorState extends State<DateSelector> {
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Formater la date pour un affichage plus lisible
    final String formattedDate = "${selectedDate.day.toString().padLeft(2, '0')} ${_getMonthName(selectedDate.month)} ${selectedDate.year}";

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Bouton précédent
        InkWell(
          onTap: () {
            final newDate = selectedDate.subtract(Duration(days: 1));
            setState(() {
              selectedDate = newDate;
            });
            widget.onDateSelected(selectedDate);
          },
          borderRadius: BorderRadius.circular(50),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: isDarkMode
                  ? theme.colorScheme.surfaceContainerLow
                  : Colors.grey[100],
            ),
            child: Icon(
              Icons.chevron_left,
              color: theme.colorScheme.primary,
              size: 20,
            ),
          ),
        ),

        // Sélecteur de date
        InkWell(
          onTap: () async {
            final DateTime? dateTime = await showDatePicker(
              context: context,
              initialDate: selectedDate,
              firstDate: DateTime(2000),
              lastDate: DateTime(3000),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: theme.colorScheme.primary,
                      onPrimary: Colors.white,
                      surface: isDarkMode
                          ? theme.colorScheme.surfaceContainerHighest
                          : Colors.white,
                      onSurface: isDarkMode ? Colors.white : Colors.black,
                    ),
                    dialogTheme: DialogTheme(
                      backgroundColor: isDarkMode
                          ? theme.colorScheme.surfaceContainerHighest
                          : Colors.white,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (dateTime != null) {
              setState(() {
                selectedDate = dateTime;
              });
              widget.onDateSelected(selectedDate);
            }
          },
          borderRadius: BorderRadius.circular(30),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withAlpha(20),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calendar_today,
                  color: theme.colorScheme.primary,
                  size: 18,
                ),
                SizedBox(width: 8),
                Text(
                  formattedDate,
                  key: ValueKey(selectedDate), // Force le rafraîchissement
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                SizedBox(width: 8),
                Icon(
                  Icons.arrow_drop_down,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),

        // Bouton suivant
        InkWell(
          onTap: () {
            final newDate = selectedDate.add(Duration(days: 1));
            setState(() {
              selectedDate = newDate;
            });
            widget.onDateSelected(selectedDate);
          },
          borderRadius: BorderRadius.circular(50),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: isDarkMode
                  ? theme.colorScheme.surfaceContainerLow
                  : Colors.grey[100],
            ),
            child: Icon(
              Icons.chevron_right,
              color: theme.colorScheme.primary,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  // Fonction pour obtenir le nom du mois
  String _getMonthName(int month) {
    const monthNames = [
      'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin',
      'Juil', 'Août', 'Sep', 'Oct', 'Nov', 'Déc'
    ];
    return monthNames[month - 1];
  }
}
