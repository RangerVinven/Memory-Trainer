import 'locus.dart';

class MemoryPalace {
  final int id;
  String name;
  String? description;
  List<Locus> loci;

  MemoryPalace({
    required this.id,
    required this.name,
    this.description,
    this.loci = const [],
  });

  factory MemoryPalace.fromJson(Map<String, dynamic> json) {
    var lociList = <Locus>[];
    if (json['loci'] != null) {
      lociList = (json['loci'] as List).map((l) => Locus.fromJson(l)).toList();
    }

    return MemoryPalace(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      loci: lociList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
    };
  }
}
