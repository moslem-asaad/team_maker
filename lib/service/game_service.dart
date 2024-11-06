import 'package:team_maker/domain/entities/game.dart';
import 'package:team_maker/domain/controllers/gamecontroller.dart';

import '../domain/entities/player.dart';

class GameService {
  final Gamecontroller _gameController;

  GameService(this._gameController);

  // Initialize the service by loading games from local storage
  Future<void> initialize() async {
    await _gameController.loadGames();
  }

  // Get all games from the controller
  List<Game> getAllGames() {
    return _gameController.getAllGames();
  }

  Future<void> addGame(int teamSize, List<Player> players, bool automaticGenerating,bool randomGenerating) async{
    Game game = Game(teamSize: teamSize,
    players: players,
    automaticGenerating: automaticGenerating,
    randomGenerating: randomGenerating
    );
    await _gameController.addGame(game);
  }

  Future<void> deleteGame(int index)async{
    await _gameController.deleteGame(index);
  }

  Future<void> updateGame(int index, Game updatedGame)async{
    await _gameController.updateGame(index,updatedGame);
  }

}
