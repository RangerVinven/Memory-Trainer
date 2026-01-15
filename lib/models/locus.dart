class Locus {
  final int id;
  String name;
  String? description;
  String? information;
  int position;

  Locus({
    required this.id,
    required this.name,
    this.description,
    this.information,
    required this.position,
  });

  factory Locus.fromJson(Map<String, dynamic> json) {
    return Locus(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      information: json['information'],
      position: json['position'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'information': information,
    };
  }
}
