class PaoDigit {
  final int id;
  final int number;
  String? person;
  String? action;
  String? object;

  PaoDigit({
    required this.id,
    required this.number,
    this.person,
    this.action,
    this.object,
  });

  factory PaoDigit.fromJson(Map<String, dynamic> json) {
    return PaoDigit(
      id: json['id'],
      number: json['number'],
      person: json['person'],
      action: json['action'],
      object: json['object'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'person': person,
      'action': action,
      'object': object,
    };
  }

  String get displayName => number.toString();
}
