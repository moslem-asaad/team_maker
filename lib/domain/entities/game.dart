import 'dart:convert';
import 'dart:math';

import 'package:team_maker/domain/entities/score.dart';
import 'package:team_maker/domain/entities/team.dart';

import 'player.dart';

class Game {
  DateTime? gameDate;

  int? numOfTeams;
  List<Player>? players;
  // based on team size and num of players will generate n teams

  List<Team>? teams; // default 2 teams
  String? gameDuration;
  //List<int>? score; //[0] - team1 scoore, [1] team2 score ..
  //Map<List<Team>,List<int>>? scores; /// modify
  List<Score>? scores = [];
  bool? automaticGenerating = true;
  bool? randomGenerating = false;

  Game(
      {this.numOfTeams,
      this.players,
      this.automaticGenerating,
      this.randomGenerating}) {
        if(players!.length < 2) throw Exception('game should contain at least two players');
        if(players!.length < numOfTeams!) throw Exception("number of teams can't exceed the number of players (you defined ${numOfTeams} teams while having just ${players!.length} players)");
    gameDate = DateTime.now();

    generateTeams();
  }

  void makeManualGenerating() {
    automaticGenerating = false;
  }

  void makeRandomGenerating() {
    randomGenerating = true;
  }

  List<Team> generateTeams() {
    if (!automaticGenerating!)
      return generateManually();
    else {
      if (randomGenerating!)
        return generateRandomlly();
      else {
        return generateEqually();
      }
    }
  }

  List<Team> generateManually() {
    //int numTeams = calculateNumOfTeams();

    teams = List.generate(numOfTeams!, (index) => Team([]));
    return teams!;
  }

  List<Team> generateRandomlly() {
    // int numTeams = calculateNumOfTeams();

    teams = List.generate(numOfTeams!, (index) => Team([]));

    //Shuffle the players list to ensure randomness
    List<Player> shuffledPlayers = List.from(players!);
    shuffledPlayers.shuffle(Random());

    //Distribute players across the teams randomly
    int teamIndex = 0;
    for (Player player in shuffledPlayers) {
      teams![teamIndex].players.add(player);
      teamIndex = (teamIndex + 1) %
          numOfTeams!; // Move to the next team, looping back if needed
    }

    // Step 5: Recalculate each team's average rating
    int indx = 1;
    for (var team in teams!) {
      team.calculateOverall();
      team.defaultName = 'Team ${indx}';
      indx++;
    }

    this.teams = teams!;
    return teams!;
  }

  List<Team> generateEqually() {
    //int numTeams = calculateNumOfTeams();
    double epsilon = 1.5 * findOptimalEpsilon();

    // Initialize teams
    teams = List.generate(numOfTeams!, (_) => Team([]));

    // Shuffle players to ensure different results on each call
    List<Player> shuffledPlayers = List.from(players!)..shuffle(Random());

    bool teamsBalanced = false;

    // Attempt to balance teams within the epsilon limit
    while (!teamsBalanced) {
      // Clear teams before each attempt
      teams!.forEach((team) => team.players.clear());

      // Distribute players across teams
      for (int i = 0; i < shuffledPlayers.length; i++) {
        teams![i % numOfTeams!].players.add(shuffledPlayers[i]);
      }

      // Calculate each team’s average rating
      List<double> teamAverages = teams!.map((team) {
        double totalRating =
            team.players.fold(0, (sum, player) => sum + (player.overall ?? 0));
        return team.players.isNotEmpty
            ? totalRating / team.players.length
            : 0.0;
      }).toList();

      // Calculate max and min average team ratings
      double maxAverage = teamAverages.reduce(max);
      double minAverage = teamAverages.reduce(min);

      // Check if the difference is within the epsilon tolerance
      teamsBalanced = (maxAverage - minAverage) <= epsilon;

      // Shuffle players again if not balanced
      if (!teamsBalanced) {
        shuffledPlayers.shuffle(Random());
      }
    }

    // Recalculate each team’s overall rating
    int indx = 1;
    for (var team in teams!) {
      team.calculateOverall();
      team.defaultName = 'Team ${indx}';
      indx++;
    }
    this.teams = teams!;
    return teams!;
  }

  // Method to find the optimal epsilon
  double findOptimalEpsilon() {
    // int numTeams = calculateNumOfTeams();
    double minEpsilon = 0;
    double maxEpsilon = players!.map((p) => p.overall ?? 0).reduce(max) -
        players!.map((p) => p.overall ?? 0).reduce(min);
    double epsilonThreshold = 0.01; // Precision level for epsilon

    while ((maxEpsilon - minEpsilon) > epsilonThreshold) {
      double midEpsilon = (minEpsilon + maxEpsilon) / 2;

      // Check if we can divide teams with the current epsilon
      if (canDivideTeams(numOfTeams!, midEpsilon)) {
        maxEpsilon = midEpsilon;
      } else {
        minEpsilon = midEpsilon;
      }
    }
    return maxEpsilon;
  }

  bool canDivideTeams(int m, double epsilon) {
    if (players == null ||
        players!.isEmpty ||
        m <= 0 ||
        numOfTeams == null ||
        numOfTeams! <= 0) {
      return false;
    }

    // Sort players by their overall rating to facilitate balanced team creation
    List<Player> sortedPlayers = List.from(players!)
      ..sort((a, b) => a.overall!.compareTo(b.overall!));

    // Initialize m teams
    List<List<Player>> teamPlayers = List.generate(m, (_) => []);

    // Distribute players in a round-robin manner to balance teams
    for (int i = 0; i < sortedPlayers.length; i++) {
      teamPlayers[i % m].add(sortedPlayers[i]);
    }

    // Calculate the average rating for each team
    List<double> teamAverages = teamPlayers.map((team) {
      double teamTotal = team.fold(0, (sum, player) => sum + player.overall!);
      return team.isNotEmpty ? teamTotal / team.length : 0.0;
    }).toList();

    // Find the maximum and minimum average ratings
    double maxAverage = teamAverages.reduce((a, b) => a > b ? a : b);
    double minAverage = teamAverages.reduce((a, b) => a < b ? a : b);

    // Check if the difference between max and min average is within epsilon
    return (maxAverage - minAverage) <= epsilon;
  }

  /*int calculateNumOfTeams() {
    double numTeams = (players!.length / teamSize!);
    return numTeams.toInt() < numTeams
        ? numTeams.toInt() + 1
        : numTeams.toInt();
  }*/

  /*void addScore(Team team1, Team team2, int scoreTeam1, int scoreTeam2) {
    scores ??= {};
    scores![<Team>[team1, team2]] = <int>[scoreTeam1, scoreTeam2];
  }*/
  void addScore(Score score) {
    scores ??= [];
    scores!.add(score);
  }

  void editScore(Score score) {
    for (var s in scores!) {
      if (s.id == score.id) {
        s = score;
        break;
      }
    }
  }

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      numOfTeams: json['numOfTeams'] as int?,
      players: (json['players'] as List<dynamic>?)
          ?.map((playerJson) => Player.fromJson(playerJson))
          .toList(),
      automaticGenerating: json['automaticGenerating'] as bool?,
      randomGenerating: json['randomGenerating'] as bool?,
    )
      ..gameDate =
          json['gameDate'] != null ? DateTime.parse(json['gameDate']) : null
      ..teams = (json['teams'] as List<dynamic>?)
          ?.map((teamJson) => Team.fromJson(teamJson))
          .toList()
      ..gameDuration = json['gameDuration'] as String?
      ..scores = (json['scores'] as List<dynamic>?)
          ?.map(
              (scoreJson) => Score.fromJson(scoreJson as Map<String, dynamic>))
          .toList();
  }

  Map<String, dynamic> toJson() => {
        'gameDate': gameDate?.toIso8601String(),
        'numOfTeams': numOfTeams,
        'players': players?.map((player) => player.toJson()).toList(),
        'teams': teams?.map((team) => team.toJson()).toList(),
        'gameDuration': gameDuration,
        'scores': scores?.map((score) => score.toJson()).toList(),
        'automaticGenerating': automaticGenerating,
        'randomGenerating': randomGenerating,
      };

  /*void editScore(Team team1, Team team2, int scoreTeam1, int scoreTeam2) {
    if (scores != null && scores!.containsKey([team1, team2])) {
      scores![<Team>[team1, team2]] = <int>[scoreTeam1, scoreTeam2];
    } else {
      throw Exception('Score for the specified teams does not exist.');
    }
  }*/

  /*factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      numOfTeams: json['numOfTeams'] as int?,
      players: (json['players'] as List<dynamic>?)
          ?.map((playerJson) => Player.fromJson(playerJson))
          .toList(),
      automaticGenerating: json['automaticGenerating'] as bool?,
      randomGenerating: json['randomGenerating'] as bool?,
    )
      ..gameDate =
          json['gameDate'] != null ? DateTime.parse(json['gameDate']) : null
      ..teams = (json['teams'] as List<dynamic>?)
          ?.map((teamJson) => Team.fromJson(teamJson))
          .toList()
      ..gameDuration = json['gameDuration'] as String?
      ..scores = (json['scores'] as Map<String, dynamic>?)?.map(
        (key, value) {
          List<Team> teams = (jsonDecode(key) as List<dynamic>)
              .map((teamJson) => Team.fromJson(teamJson))
              .toList();
          List<int> scores = (value as List<dynamic>).cast<int>();
          return MapEntry(teams, scores);
        },
      );
  }

  Map<String, dynamic> toJson() => {
        'gameDate': gameDate?.toIso8601String(),
        'numOfTeams': numOfTeams,
        'players': players?.map((player) => player.toJson()).toList(),
        'teams': teams?.map((team) => team.toJson()).toList(),
        'gameDuration': gameDuration,
        'scores': scores?.map((key, value) {
          String encodedKey =
              jsonEncode(key.map((team) => team.toJson()).toList());
          return MapEntry(encodedKey, value);
        }),
        'automaticGenerating': automaticGenerating,
        'randomGenerating': randomGenerating,
      };*/
}
