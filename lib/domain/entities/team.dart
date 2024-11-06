// team.dart
import 'player.dart';

class Team {
  String? defaultName;
  double? avgTeamRate;
  List<Player> _players = [];

  Team(this._players, {this.defaultName}) {
    calculateOverall();
  }

  // Calculate the average team rating based on player ratings
  void calculateOverall() {
    if (_players.isEmpty) {
      avgTeamRate = 0;
    } else {
      avgTeamRate = _players.map((player) => player.overall ?? 0).reduce((a, b) => a + b) / _players.length;
    }
  }

  // Add a player to the team and recalculate the overall rating
  void addPlayer(Player player) {
    _players.add(player);
    calculateOverall();
  }

  // Remove a player from the team and recalculate the overall rating
  void removePlayer(Player player) {
    _players.remove(player);
    calculateOverall();
  }

  // Get all players in the team
  List<Player> get players => _players;

  // Convert a Team object into a Map for JSON encoding
  Map<String, dynamic> toJson() => {
        'defaultName': defaultName,
        'avgTeamRate': avgTeamRate,
        'players': _players.map((player) => player.toJson()).toList(),
      };

  // Convert a Map into a Team object
  static Team fromJson(Map<String, dynamic> json) {
    List<Player> players = (json['players'] as List<dynamic>).map((p) => Player.fromJson(p)).toList();
    return Team(players, defaultName: json['defaultName'] as String?)
      ..avgTeamRate = json['avgTeamRate'] as double?;
  }

  void editTeamName(String name) {
    defaultName = name;
  }
}
