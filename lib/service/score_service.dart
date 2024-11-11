import 'package:team_maker/domain/entities/score.dart';

import '../domain/controllers/scoreController.dart';
import '../domain/entities/team.dart';

class ScoreService {
  // Private constructor for singleton
  ScoreService._privateConstructor();

  // The single instance of ScoreService
  static final ScoreService _instance = ScoreService._privateConstructor();

  // Factory constructor to return the same instance
  factory ScoreService() {
    return _instance;
  }

  final ScoreController _scoreController = ScoreController();

  // Initialize the service by loading scores from local storage
  Future<void> initialize() async {
    await _scoreController.initialize();
  }

  // Get all scores
  List<Score> getAllScores() {
    return _scoreController.getAllScores();
  }

  // Add a score and save it to local storage
  Future<Score> addScore(Team team1, Team team2, int team1_score, int team2_score) async {
    return await _scoreController.addScore(team1,team2,team1_score,team2_score);
  }

  // Delete a score by ID and save changes to local storage
  Future<void> deleteScore(int id) async {
    await _scoreController.deleteScore(id);
  }
Future<void> deleteAllScores() async {
    await _scoreController.deleteAllScores();
    print('all scores deleted');
  }
  // Update a score by ID and save changes to local storage
  Future<Score> updateScore(int id, int score1,int score2) async {
    return await _scoreController.updateScore(id, score1,score2);
  }
}
