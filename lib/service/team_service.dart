// team_service.dart
import '../domain/controllers/teamController.dart';
import '../domain/entities/player.dart';
import '../domain/entities/team.dart';


class TeamService {

  final TeamController _teamController;

  TeamService._internal(this._teamController);

  static final TeamService _instance = TeamService._internal(TeamController());

  factory TeamService() {
    return _instance;
  }


  // Initialize and load teams from local storage
  Future<void> initialize() async {
    await _teamController.loadTeams();
  }

  // Get all teams
  List<Team> getAllTeams() {
    return _teamController.getAllTeams();
  }

  // Add a player to a specific team
  Future<void> addPlayerToTeam(int teamIndex, Player player) async {
    await _teamController.addPlayerToTeam(teamIndex, player);
  }

  // Remove a player from a specific team
  Future<void> removePlayerFromTeam(int teamIndex, Player player) async {
    await _teamController.removePlayerFromTeam(teamIndex, player);
  }

  // Create a new team
  Future<void> createTeam(List<Player> players) async {
    await _teamController.addTeam(players);
  }

  // Edit an existing team by adding or removing players
  Future<void> editTeam(int index, {List<Player>? playersToAdd, List<Player>? playersToRemove}) async {
    await _teamController.editTeam(index, playersToAdd: playersToAdd, playersToRemove: playersToRemove);
  }

  Future<void> swapPlayers(Team firstTeam,Team secondTeam, Player p1, Player p2) async{
    await _teamController.swapPlayers(firstTeam,secondTeam,p1,p2);
  }

  Future<void> swapManyPlayers(Team firstTeam,Team secondTeam, List<Player> p1, List<Player> p2) async{
    await _teamController.swapManyPlayers(firstTeam,secondTeam,p1,p2);
  }
}
