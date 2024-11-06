import 'dart:math';

import 'package:team_maker/domain/entities/team.dart';

import 'player.dart';

class Game{
  DateTime? gameDate;
  
  int? teamSize;
  List<Player>? players;
  // based on team size and num of players will generate n teams
   
  List<Team>? teams; // default 2 teams
  String? gameDuration;
  List<int>? score; //[0] - team1 scoore, [1] team2 score .. 
  
  bool? automaticGenerating = true;
  bool? randomGenerating = false;

  Game({this.teamSize,this.players,this.automaticGenerating,this.randomGenerating}){
    gameDate = DateTime.now();
    generateTeams();
  }

  void makeManualGenerating(){
    automaticGenerating = false;
  }

  void makeRandomGenerating(){
    randomGenerating = true;
  }
  
  List<Team> generateTeams() {
    if(!automaticGenerating!) return generateManually();
    else{
      if(randomGenerating!) return generateRandomlly();
      else{
        return generateEqually();
      }
    }
  }
  
  List<Team> generateManually() {
    int numTeams = calculateNumOfTeams();
  
    teams = List.generate(numTeams, (index) => Team([]));
    return teams!;
  }
  
  List<Team> generateRandomlly() {
  int numTeams = calculateNumOfTeams();
  
  teams = List.generate(numTeams, (index) => Team([]));

  //Shuffle the players list to ensure randomness
  List<Player> shuffledPlayers = List.from(players!);
  shuffledPlayers.shuffle(Random());

  //Distribute players across the teams randomly
  int teamIndex = 0;
  for (Player player in shuffledPlayers) {
    teams![teamIndex].players.add(player);
    teamIndex = (teamIndex + 1) % numTeams; // Move to the next team, looping back if needed
  }

  // Step 5: Recalculate each team's average rating
  for (var team in teams!) {
    team.calculateOverall();
  }
  return teams!;
}
  
  List<Team> generateEqually() {
    int numTeams = calculateNumOfTeams();
  
    teams = List.generate(numTeams, (index) => Team([]));
    return teams!;
  }

  int calculateNumOfTeams(){
    double  numTeams = (players!.length/teamSize!);
    return numTeams.toInt() < numTeams? numTeams.toInt()+1: numTeams.toInt();
  }

  factory Game.fromJson(Map<String, dynamic> json) {
  return Game(
    teamSize: json['teamSize'] as int?,
    players: (json['players'] as List<dynamic>?)
        ?.map((playerJson) => Player.fromJson(playerJson))
        .toList(),
    automaticGenerating: json['automaticGenerating'] as bool?,
    randomGenerating: json['randomGenerating'] as bool?,
  )
    ..gameDate = json['gameDate'] != null ? DateTime.parse(json['gameDate']) : null
    ..teams = (json['teams'] as List<dynamic>?)
        ?.map((teamJson) => Team.fromJson(teamJson))
        .toList()
    ..gameDuration = json['gameDuration'] as String?
    ..score = (json['score'] as List<dynamic>?)?.map((e) => e as int).toList();
}


  Map<String, dynamic> toJson() => {
  'gameDate': gameDate?.toIso8601String(),
  'teamSize': teamSize,
  'players': players?.map((player) => player.toJson()).toList(),
  'teams': teams?.map((team) => team.toJson()).toList(),
  'gameDuration': gameDuration,
  'score': score,
  'automaticGenerating': automaticGenerating,
  'randomGenerating': randomGenerating,
};


}