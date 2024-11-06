// player.dart
class Player {
  String? fullName;
  int? attackRate;
  int? midRate;
  int? defRate;
  double? overall = 75;
  String? id;

  Player(this.fullName, this.attackRate, this.midRate, this.defRate,this.id) {
    calculateOverall();
  }

  void calculateOverall() {
    attackRate! + defRate! + midRate! >0 ?
    overall = (attackRate! + defRate! + midRate!) / 3 : 75;
  }

  // Convert a Player object into a Map for JSON encoding
  Map<String, dynamic> toJson() => {
        'fullName': fullName,
        'attackRate': attackRate,
        'midRate': midRate,
        'defRate': defRate,
        'overall': overall,
        'id':id,
      };

  // Convert a Map into a Player object
  static Player fromJson(Map<String, dynamic> json) => Player(
        json['fullName'] as String?,
        json['attackRate'] as int?,
        json['midRate'] as int?,
        json['defRate'] as int?,
        json['id'] as String?
      )..overall = json['overall'] as double?;
}
