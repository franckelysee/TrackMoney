
class Devise {
  final String name;
  final String devise;

  Devise({required this.name, required this.devise});
  Map<String, dynamic> toMap() {
    return {'name': name, 'devise': devise};
  }

  factory Devise.fromMap(Map<String, dynamic> map) {
    return Devise(name: map['name'] ?? '', devise: map['devise'] ?? '');
  }
}
