// Utilitaires pour la gestion des dates et formats

/// Retourne le nom du mois en français à partir de son numéro (1-12)
String getMonthNameInFrench(int month) {
  const Map<int, String> monthNames = {
    1: 'janvier',
    2: 'février',
    3: 'mars',
    4: 'avril',
    5: 'mai',
    6: 'juin',
    7: 'juillet',
    8: 'août',
    9: 'septembre',
    10: 'octobre',
    11: 'novembre',
    12: 'décembre',
  };
  
  return monthNames[month] ?? '';
}

/// Retourne le nom du mois en français abrégé à partir de son numéro (1-12)
String getShortMonthNameInFrench(int month) {
  const Map<int, String> shortMonthNames = {
    1: 'jan',
    2: 'fév',
    3: 'mar',
    4: 'avr',
    5: 'mai',
    6: 'jun',
    7: 'jul',
    8: 'aoû',
    9: 'sep',
    10: 'oct',
    11: 'nov',
    12: 'déc',
  };
  
  return shortMonthNames[month] ?? '';
}

/// Retourne le nom du jour en français à partir de son numéro (1-7, où 1 est lundi)
String getDayNameInFrench(int day) {
  const Map<int, String> dayNames = {
    1: 'lundi',
    2: 'mardi',
    3: 'mercredi',
    4: 'jeudi',
    5: 'vendredi',
    6: 'samedi',
    7: 'dimanche',
  };
  
  return dayNames[day] ?? '';
}

/// Convertit une date DateTime en chaîne formatée en français
String formatDateInFrench(DateTime date, {bool includeYear = true}) {
  final day = date.day;
  final month = getMonthNameInFrench(date.month);
  
  if (includeYear) {
    return '$day $month ${date.year}';
  } else {
    return '$day $month';
  }
}
