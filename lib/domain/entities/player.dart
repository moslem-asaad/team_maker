// player.dart
class Player {
  String? fullName;
  int? attackRate;
  int? midRate;
  int? defRate;
  double? overall;

  Player(this.fullName, this.attackRate, this.midRate, this.defRate) {
    calculateOverall();
  }

  void calculateOverall() {
    overall = (attackRate! + defRate! + midRate!) / 3;
  }

  // Convert a Player object into a Map for JSON encoding
  Map<String, dynamic> toJson() => {
        'fullName': fullName,
        'attackRate': attackRate,
        'midRate': midRate,
        'defRate': defRate,
        'overall': overall,
      };

  // Convert a Map into a Player object
  static Player fromJson(Map<String, dynamic> json) => Player(
        json['fullName'] as String?,
        json['attackRate'] as int?,
        json['midRate'] as int?,
        json['defRate'] as int?,
      )..overall = json['overall'] as double?;
}
