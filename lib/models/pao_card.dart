class PaoCard {
  final int id;
  final String suit;
  final String rank;
  String? person;
  String? action;
  String? object;

  PaoCard({
    required this.id,
    required this.suit,
    required this.rank,
    this.person,
    this.action,
    this.object,
  });

  factory PaoCard.fromJson(Map<String, dynamic> json) {
    return PaoCard(
      id: json['id'],
      suit: json['suit'],
      rank: json['rank'],
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

  String get displayName {
    String r = rank.substring(0, 1).toUpperCase() + rank.substring(1);
    String s = suit.substring(0, 1).toUpperCase() + suit.substring(1);
    
    // Shorten generic ranks/suits
    if (rank == 'ace') r = 'A';
    if (rank == 'king') r = 'K';
    if (rank == 'queen') r = 'Q';
    if (rank == 'jack') r = 'J';
    if (rank == 'ten') r = '10';
    if (rank == 'nine') r = '9';
    if (rank == 'eight') r = '8';
    if (rank == 'seven') r = '7';
    if (rank == 'six') r = '6';
    if (rank == 'five') r = '5';
    if (rank == 'four') r = '4';
    if (rank == 'three') r = '3';
    if (rank == 'two') r = '2';

    String icon = '';
    if (suit == 'spades') icon = '♠️';
    if (suit == 'hearts') icon = '♥️';
    if (suit == 'diamonds') icon = '♦️';
    if (suit == 'clubs') icon = '♣️';

    return '$r$icon';
  }

  bool get isRed => suit == 'hearts' || suit == 'diamonds';
}
