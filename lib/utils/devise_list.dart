import 'package:trackmoney/models/divise_model.dart';

List<Devise> devises = [
  Devise(name: 'Euro', devise: 'EUR'),
  Devise(name: 'Franc CFA', devise: 'XAF'),
  Devise(name: 'Dollar Américain', devise: 'USD'),
  Devise(name: 'Livre Sterling', devise: 'GBP'),
];

deviseList() {
  return devises.sort((a, b) => a.name.compareTo(b.name));
}
