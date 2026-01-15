class Locus {
  final int id;
  String name;
  String? description;
  int position;

  Locus({
    required this.id,
    required this.name,
    this.description,
    required this.position,
  });

  factory Locus.fromJson(Map<String, dynamic> json) {
    return Locus(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      position: json['position'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
    };
  }
}
