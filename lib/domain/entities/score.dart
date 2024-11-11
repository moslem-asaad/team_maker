import 'package:team_maker/domain/entities/team.dart';

class Score {
  Team? team1;
  Team? team2;
  int? team1_score;
  int? team2_score;
  int? id;

  Score({
    required this.team1,
    required this.team2,
    required this.team1_score,
    required this.team2_score,
    required this.id,
  });

  // Convert a Score instance to a JSON-compatible map
  Map<String, dynamic> toJson() {
    return {
      'team1': team1?.toJson(), 
      'team2': team2?.toJson(),
      'team1_score': team1_score,
      'team2_score': team2_score,
      'id': id,
    };
  }

  // Create a Score instance from a JSON-compatible map
  factory Score.fromJson(Map<String, dynamic> json) {
    print('score ${json}');
    return Score(
      team1: json['team1'] != null ? Team.fromJson(json['team1']) : null, 
      team2: json['team2'] != null ? Team.fromJson(json['team2']) : null, 
      team1_score: json['team1_score'] as int?,
      team2_score: json['team2_score'] as int?,
      id: json['id'] as int?,
    );
  }
}
