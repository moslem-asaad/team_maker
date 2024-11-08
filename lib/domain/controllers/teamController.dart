// team_controller.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../entities/player.dart';
import '../entities/team.dart';

class TeamController {
  static const String _teamsKey = 'teams';
  List<Team> _teams = [];

  // Load teams from local storage
  Future<void> loadTeams() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? teamsJson = prefs.getString(_teamsKey);
    if (teamsJson != null) {
      List<dynamic> teamList = json.decode(teamsJson);
      _teams = teamList.map((json) => Team.fromJson(json)).toList();
    }
  }

  // Save teams to local storage
  Future<void> _saveTeams() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String teamsJson =
        json.encode(_teams.map((team) => team.toJson()).toList());
    await prefs.setString(_teamsKey, teamsJson);
  }

  // Get all teams
  List<Team> getAllTeams() {
    return _teams;
  }

  // Add a team with a unique default name and save it locally
  Future<void> addTeam(List<Player> players) async {
    String teamName = 'Team ${_teams.length + 1}';
    Team newTeam = Team(players, defaultName: teamName);
    _teams.add(newTeam);
    await _saveTeams();
  }

  // Edit a team's players and recalculate team rating
  Future<void> editTeam(int index,
      {List<Player>? playersToAdd, List<Player>? playersToRemove}) async {
    if (index >= 0 && index < _teams.length) {
      if (playersToAdd != null) {
        for (Player player in playersToAdd) {
          _teams[index].addPlayer(player);
        }
      }
      if (playersToRemove != null) {
        for (Player player in playersToRemove) {
          _teams[index].removePlayer(player);
        }
      }
      await _saveTeams();
    }
  }

  // Add a player to a specific team
  Future<void> addPlayerToTeam(int teamIndex, Player player) async {
    if (teamIndex >= 0 && teamIndex < _teams.length) {
      _teams[teamIndex].addPlayer(player);
      await _saveTeams();
    }
  }

  // Remove a player from a specific team
  Future<void> removePlayerFromTeam(int teamIndex, Player player) async {
    if (teamIndex >= 0 && teamIndex < _teams.length) {
      _teams[teamIndex].removePlayer(player);
      await _saveTeams();
    }
  }

  // Select a player from a specific team (optional method to return a player)
  Player? selectPlayerInTeam(int teamIndex, int playerIndex) {
    if (teamIndex >= 0 && teamIndex < _teams.length) {
      if (playerIndex >= 0 && playerIndex < _teams[teamIndex].players.length) {
        return _teams[teamIndex].players[playerIndex];
      }
    }
    return null;
  }

  Future<void> editTeamName(int teamIndex, String name) async {
    if (teamIndex >= 0 && teamIndex < _teams.length) {
      _teams[teamIndex].editTeamName(name);
      await _saveTeams();
    }
  }

  Future<void> swapPlayers(Team firstTeam,Team secondTeam, Player p1, Player p2) async {

    /*print('team1  ${team1} - team2  ${team2} - ${_teams.length}');
    // Ensure the teams exist in the list
    if (team1 >= _teams.length || team2 >= _teams.length) {
      throw Exception('Invalid team indices');
    }

    Team firstTeam = _teams[team1];
    Team secondTeam = _teams[team2];*/

    // Find the indices of p1 in team1 and p2 in team2
    int indexP1 = firstTeam.players.indexOf(p1);
    int indexP2 = secondTeam.players.indexOf(p2);

    if (indexP1 == -1 || indexP2 == -1) {
      throw Exception('Players not found in their respective teams');
    }

    // Swap players between teams at their respective indices
    firstTeam.players[indexP1] = p2;
    secondTeam.players[indexP2] = p1;

    // Recalculate the overall ratings for both teams
    firstTeam.calculateOverall();
    secondTeam.calculateOverall();
  }

  Future<void> swapManyPlayers(Team firstTeam, Team secondTeam, List<Player> p1, List<Player> p2) async {
  if (p1.length != p2.length) {
    throw Exception('The number of selected players should be equal in the two teams');
  }

  // Get indices of the players in their respective teams
  List<int> indexP1 = [];
  List<int> indexP2 = [];

  for (var player in p1) {
    indexP1.add(firstTeam.players.indexOf(player));
  }

  for (var player in p2) {
    indexP2.add(secondTeam.players.indexOf(player));
  }

  // Swap players between the two teams
  for (int i = 0; i < p1.length; i++) {
    // Swap the players at their respective indices
    Player temp = firstTeam.players[indexP1[i]];
    firstTeam.players[indexP1[i]] = secondTeam.players[indexP2[i]];
    secondTeam.players[indexP2[i]] = temp;
  }

  // Recalculate the overall ratings for the teams after swapping
  firstTeam.calculateOverall();
  secondTeam.calculateOverall();

  // Optionally, you could add a delay or some indication of an asynchronous operation
  await Future.delayed(Duration(milliseconds: 100));
}

}
