import 'package:team_maker/domain/entities/game.dart';
import 'package:team_maker/domain/controllers/gamecontroller.dart';
import 'package:team_maker/service/score_service.dart';
import '../domain/entities/player.dart';
import '../domain/entities/score.dart';
import '../domain/entities/team.dart';

class GameService {
  final Gamecontroller _gameController;
  final ScoreService _scoreService;

  // Private constructor
  GameService._internal(this._gameController, this._scoreService);

  // The singleton instance
  static final GameService _instance = GameService._internal(Gamecontroller(),ScoreService());

  // Factory constructor to return the singleton instance
  factory GameService() {
    return _instance;
  }

  // Initialize the service by loading games from local storage
  Future<void> initialize() async {
    await _scoreService.initialize();
    print('before load ganmes');
    await _gameController.loadGames();
  }

  // Get all games from the controller
  List<Game> getAllGames() {
    return _gameController.getAllGames();
  }

  Future<void> deleteAllGames() async {
    print('all games deleted');
    await _gameController.deleteAllGames();
  }

  Future<void> saveGame (Game game)async{
    await _gameController.addGame(game);
  }

  Future<void> addGame(int numOfTeams, List<Player> players, bool automaticGenerating, bool randomGenerating) async {
    Game game = Game(
      numOfTeams: numOfTeams,
      players: players,
      automaticGenerating: automaticGenerating,
      randomGenerating: randomGenerating,
    );
    await _gameController.addGame(game);
  }

  Future<void> deleteGame(int index) async {
    await _gameController.deleteGame(index);
  }

  Future<void> updateGame(int index, Game updatedGame) async {
    await _gameController.updateGame(index, updatedGame);
  }

  Future<Game> generateGame(int numOfTeams, List<Player> players, bool automaticGenerating, bool randomGenerating) async {
    return await _gameController.generateGame(numOfTeams, players, automaticGenerating, randomGenerating);
  }

  Future<void> addScore(Game game,Team team1, Team team2, int scoreTeam1, int scoreTeam2) async{
    // needs to handle if score added and game not to remove the score.
    Score score = await _scoreService.addScore(team1, team2, scoreTeam1, scoreTeam2);
    await _gameController.addScore(game,score);
  }

  Future <void> editScore(Game game,Team team1, Team team2, int scoreTeam1, int scoreTeam2,int scoreId) async{
    Score score = await _scoreService.updateScore(scoreId, scoreTeam1,scoreTeam2);
    await _gameController.editScore(game,score);
  }

  Future<void> deleteGameByInstance(Game game) async {
    await _gameController.deleteGameByInstance(game);
  }


  
}
