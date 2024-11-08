import 'package:team_maker/domain/entities/game.dart';
import 'package:team_maker/domain/controllers/gamecontroller.dart';
import '../domain/entities/player.dart';

class GameService {
  final Gamecontroller _gameController;

  // Private constructor
  GameService._internal(this._gameController);

  // The singleton instance
  static final GameService _instance = GameService._internal(Gamecontroller());

  // Factory constructor to return the singleton instance
  factory GameService() {
    return _instance;
  }

  // Initialize the service by loading games from local storage
  Future<void> initialize() async {
    await _gameController.loadGames();
  }

  // Get all games from the controller
  List<Game> getAllGames() {
    return _gameController.getAllGames();
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
}
