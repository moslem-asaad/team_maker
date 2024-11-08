import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:team_maker/domain/entities/game.dart';
import 'package:team_maker/domain/entities/player.dart';
import 'package:team_maker/domain/entities/team.dart';

void main() {
  test('generateRandomlly distributes players randomly into teams', () {
    // Set up a list of players
    List<Player> players = [
      Player('Player 1', 80, 70, 75, '1'),
      Player('Player 2', 85, 65, 80, '2'),
      Player('Player 3', 78, 80, 72, '3'),
      Player('Player 4', 82, 75, 77, '4'),
      Player('Player 5', 90, 68, 85, '5'),
      Player('Player 6', 76, 82, 70, '6'),
      Player('Player 7', 80, 70, 75, '7'),
      Player('Player 8', 85, 65, 80, '8'),
      Player('Player 9', 78, 80, 72, '9'),
      Player('Player 10', 82, 75, 77, '10'),
      Player('Player 11', 90, 68, 85, '11'),
      Player('Player 12', 76, 82, 70, '12'),
      Player('Player 13', 80, 70, 75, '13'),
      Player('Player 14', 85, 65, 80, '14'),
      Player('Player 15', 78, 80, 72, '15'),
      Player('Player 16', 82, 75, 77, '16'),
      Player('Player 17', 90, 68, 85, '17'),
      Player('Player 18', 76, 82, 70, '18'),
    ];

    // Create a Game instance with team size 3 and players
    Game game = Game(numOfTeams: 2, players: players, automaticGenerating: true, randomGenerating: true);

    // Call generateRandomlly
    List<Team> teams = game.generateRandomlly();

    // Assert that teams are created correctly
    //expect(teams.length, game.calculateNumOfTeams());
    expect(teams.fold<int>(0, (sum, team) => sum + team.players.length), players.length);

    // Ensure each player is only assigned to one team
    final allAssignedPlayers = teams.expand((team) => team.players).toList();
    expect(allAssignedPlayers.toSet().length, players.length);

    // Print out team information for verification
    for (int i = 0; i < teams.length; i++) {
      print('Team ${i + 1}:');
      teams[i].players.forEach((player) {
        print('  - ${player.fullName} (Overall: ${player.overall?.toStringAsFixed(2) ?? 'N/A'})');
      });
    }
  });

  test('findOptimalEpsilon finds minimum epsilon for balanced teams', () {
    // Set up players with varying ratings
    List<Player> players = [
      Player('Player 1', 90, 85, 80, '1'),
      Player('Player 2', 88, 82, 75, '2'),
      Player('Player 3', 70, 65, 68, '3'),
      Player('Player 4', 95, 70, 73, '4'),
      Player('Player 5', 95, 90, 85, '5'),
      Player('Player 6', 60, 55, 58, '6'),
    ];

    // Create a Game instance
    Game game = Game(numOfTeams: 2, players: players, automaticGenerating: true, randomGenerating: false);

    // Calculate the optimal epsilon
    double epsilon = game.findOptimalEpsilon();

    // Assertions
    // Here you should check that epsilon is small enough for balanced teams
    expect(epsilon, isNotNull);
    expect(epsilon, isNonZero);
    print("Optimal epsilon found: $epsilon");
  });

   test('generateEqually distributes players equally into teams', () {
    // Set up a list of players
    List<Player> players = [
      Player('Player 1', 90, 85, 80, '1'),
      Player('Player 2', 88, 82, 75, '2'),
      Player('Player 3', 70, 65, 68, '3'),
      Player('Player 4', 95, 70, 73, '4'),
      Player('Player 5', 95, 90, 85, '5'),
      Player('Player 6', 60, 55, 58, '6'),
      Player('Player 7', 75, 80, 78, '7'),
      Player('Player 8', 85, 70, 82, '8'),
      Player('Player 9', 80, 75, 79, '9'),
      Player('Player 10', 92, 87, 85, '10'),
      Player('Player 11', 92, 95, 91, '11'),
      Player('Player 12', 92, 97, 97, '12'),
    ];

    // Create a Game instance with team size and players
    Game game = Game(numOfTeams: 2, players: players, automaticGenerating: true, randomGenerating: false);

    // Call generateEqually
    List<Team> teams = game.generateEqually();

    // Calculate the number of teams
   // int expectedNumTeams = game.calculateNumOfTeams();
    //expect(teams.length, expectedNumTeams, reason: 'Should create the correct number of teams');

    // Ensure each player is only assigned to one team
    final allAssignedPlayers = teams.expand((team) => team.players).toList();
    expect(allAssignedPlayers.toSet().length, players.length, reason: 'All players should be assigned exactly once');

    // Calculate team average ratings
    List<double> teamAverages = teams.map((team) {
      double teamTotal = team.players.fold(0, (sum, player) => sum + (player.overall ?? 0));
      return team.players.isNotEmpty ? teamTotal / team.players.length : 0.0;
    }).toList();

    // Calculate the difference between max and min average ratings
    double maxAverage = teamAverages.reduce((a, b) => a > b ? a : b);
    double minAverage = teamAverages.reduce((a, b) => a < b ? a : b);
    double epsilon = game.findOptimalEpsilon();

    // Assert that the rating difference between teams is within epsilon
    expect((maxAverage - minAverage), lessThanOrEqualTo(epsilon), reason: 'Teams should be balanced within epsilon');

    // Print out team information for verification
    for (int i = 0; i < teams.length; i++) {
      print('Team ${i + 1}:');
      teams[i].players.forEach((player) {
        print('  - ${player.fullName} (Overall: ${player.overall?.toStringAsFixed(2) ?? 'N/A'})');
      });
      print('overall - ${teams[i].avgTeamRate}');
    }
    print('epsilon ${epsilon}');
  });

  test('generateEqually creates different distributions on consecutive runs', () {
    // Set up a list of players
    List<Player> players = [
     Player('Player 1', 90, 85, 80, '1'),
      Player('Player 2', 88, 82, 75, '2'),
      Player('Player 3', 70, 65, 68, '3'),
      Player('Player 4', 95, 70, 73, '4'),
      Player('Player 5', 95, 90, 85, '5'),
      Player('Player 6', 60, 55, 58, '6'),
      Player('Player 7', 75, 80, 78, '7'),
      Player('Player 8', 85, 70, 82, '8'),
      Player('Player 9', 80, 75, 79, '9'),
      Player('Player 10', 92, 87, 85, '10'),
      Player('Player 11', 92, 95, 91, '11'),
      Player('Player 12', 92, 97, 97, '12'),
      Player('Player 13', 88, 77, 90, '13'),
      Player('Player 14', 96, 87, 79, '14'),
    ];

    // Create a Game instance with team size and players
    Game game = Game(numOfTeams: 2, players: players, automaticGenerating: true, randomGenerating: false);

    // Run generateEqually twice and check that teams differ
    List<Team> teamsFirstRun = game.generateEqually();
    List<Team> teamsSecondRun = game.generateEqually();

    // Check that the distributions in both runs are not exactly the same
    bool areDistributionsDifferent = false;

    for (int i = 0; i < teamsFirstRun.length; i++) {
      if (!ListEquality().equals(
          teamsFirstRun[i].players.map((p) => p.id).toList(),
          teamsSecondRun[i].players.map((p) => p.id).toList())) {
        areDistributionsDifferent = true;
        break;
      }
    }

    expect(areDistributionsDifferent, isTrue, reason: 'generateEqually should create different distributions on consecutive runs');

    print('----------first run-----------------');
    for (int i = 0; i < teamsFirstRun.length; i++) {
      print('Team ${i + 1}:');
      teamsFirstRun[i].players.forEach((player) {
        print('  - ${player.fullName} (Overall: ${player.overall?.toStringAsFixed(2) ?? 'N/A'})');
      });
      print('overall - ${teamsFirstRun[i].avgTeamRate}');
    }

    print('------------second run-------------');
    for (int i = 0; i < teamsSecondRun.length; i++) {
      print('Team ${i + 1}:');
      teamsSecondRun[i].players.forEach((player) {
        print('  - ${player.fullName} (Overall: ${player.overall?.toStringAsFixed(2) ?? 'N/A'})');
      });
      print('overall - ${teamsSecondRun[i].avgTeamRate}');
    }
  });



}
