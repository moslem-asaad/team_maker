import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:team_maker/domain/entities/score.dart';
import 'package:team_maker/domain/entities/team.dart';

class ScoreController {
  // Private constructor for singleton
  ScoreController._privateConstructor();

  // The single instance of ScoreController
  static final ScoreController _instance = ScoreController._privateConstructor();

  // Factory constructor to return the same instance
  factory ScoreController() {
    return _instance;
  }

  // List to hold scores
  List<Score> _scores = [];

  static const String _storageKey = 'savedScores';

  // Initialize by loading from local storage
  Future<void> initialize() async {
  print('loading scores');
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? storedScores = prefs.getString(_storageKey);
  print('stored scores string $storedScores');
  if (storedScores != null) {
    List<dynamic> decodedList = jsonDecode(storedScores);
    print('stored scores list $decodedList');
    // Ensure each element is decoded from a JSON string to a Map
    _scores = decodedList.map((jsonString) {
      // Decode the string to a Map before parsing it into a Score
      Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      return Score.fromJson(jsonMap);
    }).toList();
  }
}

  // Method to add a score and save it to local storage
  Future<Score> addScore(Team team1, Team team2, int team1_score, int team2_score) async {
    Score score = Score(team1: team1,team2: team2,team1_score: team1_score,team2_score: team2_score,id: _scores.length);
    _scores.add(score);
    await _saveToLocalStorage();
    return score;
  }

  // Method to get all scores
  List<Score> getAllScores() {
    return List.unmodifiable(_scores);
  }

  Future<void> deleteAllScores() async {
    _scores.clear();
    await _saveToLocalStorage();
  }

  // Method to delete a score by ID and save changes to local storage
  Future<void> deleteScore(int id) async {
    _scores.removeWhere((score) => score.id == id);
    await _saveToLocalStorage();
  }

  // Method to update a score by ID and save changes to local storage
  Future<Score> updateScore(int id, int score1, int score2) async {
    for (int i = 0; i < _scores.length; i++) {
      if (_scores[i].id == id) {
        _scores[i].team1_score = score1;
        _scores[i].team2_score = score2;
        //_scores[i] = updatedScore;
        await _saveToLocalStorage();
        return _scores[i];
      }
    }
    throw Exception('Score with ID $id not found.');
  }

  // Private method to save scores to local storage
  Future<void> _saveToLocalStorage() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> encodedScores = _scores.map((score) => jsonEncode(score.toJson())).toList();
    await prefs.setString(_storageKey, jsonEncode(encodedScores));
  }
}
