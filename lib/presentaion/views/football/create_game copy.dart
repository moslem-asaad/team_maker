import 'package:flutter/material.dart';
import 'package:team_maker/constants/colors.dart';
import 'package:team_maker/domain/entities/game.dart';
import 'package:team_maker/domain/entities/player.dart';
import 'package:team_maker/presentaion/views/football/generate_game.dart';
import 'package:team_maker/presentaion/views/football/widgets/multi_selection.dart';
import 'package:team_maker/service/game_service.dart';
import 'package:team_maker/service/player_service.dart';

import '../../constFunctions/show_player_dialog.dart';

class CreateGameScreen extends StatefulWidget {
  const CreateGameScreen({super.key});

  @override
  State<CreateGameScreen> createState() => _CreateGameScreenState();
}

class _CreateGameScreenState extends State<CreateGameScreen> {
  late final PlayerService _playerService;
  late final GameService _gameService;
  List<Player> _availablePlayers = [];
  List<Player> _selectedPlayers = [];
  int _numOfTeams = 2;
  bool isAutomaticBuild = true;
  bool isRandomGeneration = true;
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _playerService = PlayerService();
    _gameService = GameService();
    _initializeData();
    // _teamSizeController.text = _numOfTeams;
  }

  @override
  void dispose() {
    // _teamSizeController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    await _playerService.initialize();
    setState(() {
      _availablePlayers = _playerService.getAllPlayers();
    });
  }

  void _clearallChoices() {
    setState(() {
      _selectedPlayers.clear();
      isAutomaticBuild = true;
      isRandomGeneration = true;
      _numOfTeams = 2;
      // _teamSizeController.dispose();
      // _teamSizeController = TextEditingController();
    });
  }
  

  void _togglePlayerSelection(Player player) {
    setState(() {
      if (_selectedPlayers.contains(player)) {
        _selectedPlayers.remove(player);
      } else {
        _selectedPlayers.add(player);
      }
    });
  }

  Future<void> _addPlayer() async {
    showPlayerDataDialog(
      context,
      (String name, int attackRate, int midRate, int defRate) async {
        // Add the new player to the service
        await _playerService.addPlayer(
          name: name,
          attackRate: attackRate,
          midRate: midRate,
          defRate: defRate,
        );

        setState(() {
          // Refresh the available players list
          _availablePlayers = _playerService.getAllPlayers();

          // Find the new player in the updated available players list
          final newPlayer = _availablePlayers.firstWhere(
            (player) => player.id == (_availablePlayers.length - 1).toString(),
            //orElse: () => null,
          );

          // If the player was added successfully, add them to the selected list
          if (newPlayer != null) {
            _selectedPlayers.add(newPlayer);
          }
        });
      },
    );
  }

  void _saveGame() async {
    // Parse team size input
    int numOfTeams = /*int.tryParse(_teamSizeController.text) ?? 0;*/
        _numOfTeams;

    if (numOfTeams <= 0) {
      // Handle invalid team size input
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid team size')),
      );
      return;
    }

    try {
      Game game = await _gameService.generateGame(
          numOfTeams, _selectedPlayers, isAutomaticBuild, isRandomGeneration);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Game saved and teams generated')),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GeneratedTeamsScreen(
            game: game,
          ), // Replace with your actual screen
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${error.toString()}')),
      );
    }
  }

  void _selectAll() {
    setState(() {
      _selectedPlayers = List.from(_availablePlayers);
    });
  }

  void _showFullScreenPlayerList() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.8,
              maxChildSize: 0.95,
              minChildSize: 0.6,
              builder: (context, scrollController) {
                return Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              setModalState(() {
                                _selectAll();
                              });
                            },
                            child: Text('select all'),
                          ),
                          const Spacer(),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                setModalState(() {
                                  _selectedPlayers = [];
                                });
                              });
                            },
                            child: Text('clear all'),
                          ),
                        ],
                      ),
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          itemCount: _availablePlayers.length,
                          itemBuilder: (context, index) {
                            final player = _availablePlayers[index];
                            final isSelected =
                                _selectedPlayers.contains(player);
                            return ListTile(
                              title: Text(
                                player.fullName ?? 'Unnamed Player',
                                style: const TextStyle(fontSize: 16),
                              ),
                              subtitle: Text(
                                'Overall Rating: ${player.overall?.toStringAsFixed(2) ?? 'N/A'}',
                                style: const TextStyle(fontSize: 14),
                              ),
                              leading: Checkbox(
                                value: isSelected,
                                onChanged: (value) {
                                  setModalState(() {
                                    if (value == true) {
                                      _selectedPlayers.add(player);
                                    } else {
                                      _selectedPlayers.remove(player);
                                    }
                                  });
                                },
                              ),
                              onTap: () {
                                setModalState(() {
                                  if (isSelected) {
                                    _selectedPlayers.remove(player);
                                  } else {
                                    _selectedPlayers.add(player);
                                  }
                                });
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 20),
                          backgroundColor: Color.fromARGB(255, 166, 255, 144),
                          shadowColor: lightCyan,
                        ),
                        child: const Text(
                          'Okay',
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    ).then((_) {
      setState(() {}); // Refresh the state when the modal closes
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Game')),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep < 3) {
            setState(() {
              _currentStep += 1;
            });
          } else {
            _saveGame();
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() {
              _currentStep -= 1;
            });
          }
        },
        steps: [
          Step(
            title: const Text('Select Number of Teams'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Number Of Teams: $_numOfTeams',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Slider(
                  value: _numOfTeams.toDouble(),
                  min: 2,
                  max: 10,
                  divisions: 8, // Number of divisions for each step
                  label: '$_numOfTeams',
                  onChanged: (double value) {
                    setState(() {
                      _numOfTeams = value.toInt();
                    });
                  },
                  activeColor:
                      Colors.blue, // Color of the active portion of the slider
                  inactiveColor:
                      Colors.blue[50], // Color of the inactive portion
                ),
              ],
            ),
          ),
          Step(
            title: const Text('Choose Build and Generation Type'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Choose build type:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Wrap(
                  spacing: 20,
                  children: [
                    Row(
                      children: [
                        Radio<bool>(
                          value: true,
                          groupValue: isAutomaticBuild,
                          onChanged: (value) {
                            setState(() {
                              isAutomaticBuild = value!;
                            });
                          },
                        ),
                        const Text('Automatic Build',
                            style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 20),
                        Radio<bool>(
                          value: false,
                          groupValue: isAutomaticBuild,
                          onChanged: (value) {
                            setState(() {
                              isAutomaticBuild = value!;
                            });
                          },
                        ),
                        const Text('Manual Build',
                            style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  ],
                ),
                if (isAutomaticBuild) ...[
                  const SizedBox(height: 10),
                  const Text(
                    'Choose generation type:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Wrap(
                    spacing: 20,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Radio<bool>(
                            value: true,
                            groupValue: isRandomGeneration,
                            onChanged: (value) {
                              setState(() {
                                isRandomGeneration = value!;
                              });
                            },
                          ),
                          const Text('Random Generation',
                              style: TextStyle(fontSize: 16)),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Radio<bool>(
                            value: false,
                            groupValue: isRandomGeneration,
                            onChanged: (value) {
                              setState(() {
                                isRandomGeneration = value!;
                              });
                            },
                          ),
                          const Text('Fairness Generation',
                              style: TextStyle(fontSize: 16)),
                        ],
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          _selectPlayers(),
          Step(
            title: const Text('Review & Confirm'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Review your game settings:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text('Number of Teams: $_numOfTeams'),
                Text(
                    'Build Type: ${isAutomaticBuild ? 'Automatic' : 'Manual'}'),
                if (isAutomaticBuild)
                  Text(
                      'Generation Type: ${isRandomGeneration ? 'Random' : 'Fairness'}'),
                const Text('Selected Players:'),
                Wrap(
                  spacing: 8,
                  children: _selectedPlayers.map((player) {
                    return Chip(
                      label: Text(player.fullName ?? 'Unnamed Player'),
                      onDeleted: () {
                        setState(() {
                          _selectedPlayers.remove(player);
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Step _selectPlayers() {
  return Step(
    title: const Text('Select Players'),
    content: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_selectedPlayers.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: _selectedPlayers.map((player) {
              return Chip(
                label: Text(player.fullName ?? 'Unnamed Player'),
                onDeleted: () {
                  _togglePlayerSelection(player);
                },
              );
            }).toList(),
          ),
        const SizedBox(height: 10),
        MultiSelectDropdown(
          availablePlayers: _availablePlayers,
          selectedPlayers: _selectedPlayers,
          onPlayerSelected: (player) {
            setState(() {
              _selectedPlayers.add(player);
            });
          },
          onPlayerDeselected: (player) {
            setState(() {
              _selectedPlayers.remove(player);
            });
          },
        ),
        ElevatedButton.icon(
          icon: Icon(Icons.add),
          label: Text('Add New Player'),
          onPressed:_addPlayer,
        ),
        ElevatedButton.icon(
          icon: Icon(Icons.add),
          label: Text('Show All players list'),
          onPressed:_showFullScreenPlayerList,
        ),
      ],
    ),
  );
}


}


/*


import 'package:flutter/material.dart';
import 'package:team_maker/constants/colors.dart';
import 'package:team_maker/domain/entities/game.dart';
import 'package:team_maker/domain/entities/player.dart';
import 'package:team_maker/presentaion/views/football/generate_game.dart';
import 'package:team_maker/service/game_service.dart';
import 'package:team_maker/service/player_service.dart';
import 'package:team_maker/domain/controllers/playerController.dart';

import '../../constFunctions/show_player_dialog.dart';

class CreateGameScreen extends StatefulWidget {
  const CreateGameScreen({super.key});

  @override
  State<CreateGameScreen> createState() => _CreateGameScreenState();
}

class _CreateGameScreenState extends State<CreateGameScreen> {
  late final PlayerService _playerService;
  late final GameService _gameService;
  List<Player> _availablePlayers = [];
  List<Player> _selectedPlayers = [];
  // TextEditingController _teamSizeController = TextEditingController();

  bool isAutomaticBuild = true;
  bool isRandomGeneration = true;

  final ScrollController _scrollController = ScrollController();
  bool _canScrollUp = false;
  bool _canScrollDown = true;
  int _numOfTeams = 2;

  @override
  void initState() {
    super.initState();
    _playerService = PlayerService();
    _gameService = GameService();
    _initializeData();
    // _teamSizeController.text = _numOfTeams;
    _scrollController.addListener(_updateScrollIndicators);
  }

  @override
  void dispose() {
    // _teamSizeController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    await _playerService.initialize();
    setState(() {
      _availablePlayers = _playerService.getAllPlayers();
    });
  }

  void _updateScrollIndicators() {
    setState(() {
      _canScrollUp = _scrollController.offset > 0;
      _canScrollDown =
          _scrollController.offset < _scrollController.position.maxScrollExtent;
    });
  }

  void _clearallChoices() {
    setState(() {
      _selectedPlayers.clear();
      isAutomaticBuild = true;
      isRandomGeneration = true;
      _numOfTeams = 2;
      // _teamSizeController.dispose();
      // _teamSizeController = TextEditingController();
    });
  }

  Future<void> _addPlayer() async {
    showPlayerDataDialog(
      context,
      (String name, int attackRate, int midRate, int defRate) async {
        // Add the new player to the service
        await _playerService.addPlayer(
          name: name,
          attackRate: attackRate,
          midRate: midRate,
          defRate: defRate,
        );

        setState(() {
          // Refresh the available players list
          _availablePlayers = _playerService.getAllPlayers();

          // Find the new player in the updated available players list
          final newPlayer = _availablePlayers.firstWhere(
            (player) => player.id == (_availablePlayers.length - 1).toString(),
            //orElse: () => null,
          );

          // If the player was added successfully, add them to the selected list
          if (newPlayer != null) {
            _selectedPlayers.add(newPlayer);
          }
        });
      },
    );
  }

  void _saveGame() async {
    /*if (_teamSizeController.text.isEmpty) {
      // Handle missing team size input
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a team size')),
      );
      return;
    }*/
    // Parse team size input
    int numOfTeams = /*int.tryParse(_teamSizeController.text) ?? 0;*/
        _numOfTeams;

    if (numOfTeams <= 0) {
      // Handle invalid team size input
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid team size')),
      );
      return;
    }

    try {
      Game game = await _gameService.generateGame(
          numOfTeams, _selectedPlayers, isAutomaticBuild, isRandomGeneration);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Game saved and teams generated')),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GeneratedTeamsScreen(
            game: game,
          ), // Replace with your actual screen
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${error.toString()}')),
      );
    }
  }

  void _selectAll() {
    setState(() {
      _selectedPlayers = List.from(_availablePlayers);
    });
  }

  void _showFullScreenPlayerList() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.8,
              maxChildSize: 0.95,
              minChildSize: 0.6,
              builder: (context, scrollController) {
                return Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              setModalState(() {
                                _selectAll();
                              });
                            },
                            child: Text('select all'),
                          ),
                          const Spacer(),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                setModalState(() {
                                  _selectedPlayers = [];
                                });
                              });
                            },
                            child: Text('clear all'),
                          ),
                        ],
                      ),
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          itemCount: _availablePlayers.length,
                          itemBuilder: (context, index) {
                            final player = _availablePlayers[index];
                            final isSelected =
                                _selectedPlayers.contains(player);
                            return ListTile(
                              title: Text(
                                player.fullName ?? 'Unnamed Player',
                                style: const TextStyle(fontSize: 16),
                              ),
                              subtitle: Text(
                                'Overall Rating: ${player.overall?.toStringAsFixed(2) ?? 'N/A'}',
                                style: const TextStyle(fontSize: 14),
                              ),
                              leading: Checkbox(
                                value: isSelected,
                                onChanged: (value) {
                                  setModalState(() {
                                    if (value == true) {
                                      _selectedPlayers.add(player);
                                    } else {
                                      _selectedPlayers.remove(player);
                                    }
                                  });
                                },
                              ),
                              onTap: () {
                                setModalState(() {
                                  if (isSelected) {
                                    _selectedPlayers.remove(player);
                                  } else {
                                    _selectedPlayers.add(player);
                                  }
                                });
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 20),
                          backgroundColor: Color.fromARGB(255, 166, 255, 144),
                          shadowColor: lightCyan,
                        ),
                        child: const Text(
                          'Okay',
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    ).then((_) {
      setState(() {}); // Refresh the state when the modal closes
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Game')),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Number Of Teams: $_numOfTeams', // Display the current number of teams
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Slider(
                      value: _numOfTeams.toDouble(),
                      min: 2,
                      max: 10,
                      divisions: 8, // Number of divisions for each step
                      label: '$_numOfTeams',
                      onChanged: (double value) {
                        setState(() {
                          _numOfTeams = value.toInt();
                        });
                      },
                      activeColor: Colors
                          .blue, // Color of the active portion of the slider
                      inactiveColor:
                          Colors.blue[50], // Color of the inactive portion
                    ),
                    const SizedBox(height: 20),

                    // Build Type Options
                    const Text(
                      'Choose build type:',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Radio<bool>(
                          value: true,
                          groupValue: isAutomaticBuild,
                          onChanged: (value) {
                            setState(() {
                              isAutomaticBuild = value!;
                            });
                          },
                        ),
                        const Text('Automatic Build',
                            style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 20),
                        Radio<bool>(
                          value: false,
                          groupValue: isAutomaticBuild,
                          onChanged: (value) {
                            setState(() {
                              isAutomaticBuild = value!;
                            });
                          },
                        ),
                        const Text('Manual Build',
                            style: TextStyle(fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Conditional Generation Type Options
                    Visibility(
                      visible: isAutomaticBuild,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Choose generation type:',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 20,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Radio<bool>(
                                    value: true,
                                    groupValue: isRandomGeneration,
                                    onChanged: (value) {
                                      setState(() {
                                        isRandomGeneration = value!;
                                      });
                                    },
                                  ),
                                  const Text('Random Generation',
                                      style: TextStyle(fontSize: 16)),
                                ],
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Radio<bool>(
                                    value: false,
                                    groupValue: isRandomGeneration,
                                    onChanged: (value) {
                                      setState(() {
                                        isRandomGeneration = value!;
                                      });
                                    },
                                  ),
                                  const Text('Fairness Generation',
                                      style: TextStyle(fontSize: 16)),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),

                    // Player Selection with GestureDetector
                    const Text(
                      'Select players:',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Divider(height: 1),
                    GestureDetector(
                      onTap: _showFullScreenPlayerList,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        height: isAutomaticBuild
                            ? 200
                            : 300, // Expand height in Manual Build
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 12),
                        child: GridView.builder(
                          controller: _scrollController,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, // Display two players per row
                            childAspectRatio:
                                2.5, // Adjust the height-to-width ratio as needed
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                          ),
                          itemCount: _availablePlayers.length,
                          itemBuilder: (context, index) {
                            final player = _availablePlayers[index];
                            final isSelected =
                                _selectedPlayers.contains(player);
                            return ListTile(
                              title: Text(
                                player.fullName ?? 'Unnamed Player',
                                style: const TextStyle(fontSize: 16),
                              ),
                              subtitle: Text(
                                '${player.overall?.toStringAsFixed(2) ?? 'N/A'}',
                                style: const TextStyle(fontSize: 14),
                              ),
                              leading: Checkbox(
                                value: isSelected,
                                onChanged: (value) {
                                  setState(() {
                                    if (value == true) {
                                      _selectedPlayers.add(player);
                                    } else {
                                      _selectedPlayers.remove(player);
                                    }
                                  });
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    // Section for displaying selected players as chips/tags
                    if (_selectedPlayers.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.only(top: 10.0, left: 8.0),
                        child: Text(
                          'Selected Players:',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8.0, // Horizontal space between chips
                        runSpacing: 4.0, // Vertical space between rows
                        children: _selectedPlayers.map((player) {
                          return Chip(
                            label: Text(
                              player.fullName ?? 'Unnamed Player',
                              style: const TextStyle(fontSize: 14),
                            ),
                            avatar: CircleAvatar(
                              child: Text(
                                player.fullName != null &&
                                        player.fullName!.isNotEmpty
                                    ? player.fullName![0]
                                    : '?',
                              ),
                            ),
                            onDeleted: () {
                              setState(() {
                                _selectedPlayers.remove(player);
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ]
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            //color: Colors.blue[50],
            child: Wrap(
              spacing: 10, // Horizontal space between buttons
              runSpacing: 10, // Vertical space between lines if they wrap
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.save, color: Colors.white),
                  label: const Text("Save Game"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 16),
                  ),
                  onPressed: _saveGame,
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.person_add, color: Colors.white),
                  label: const Text("Add New Player"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 16),
                  ),
                  onPressed: _addPlayer,
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.clear, color: Colors.white),
                  label: const Text("Clear All"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 16),
                  ),
                  onPressed: _clearallChoices,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


*/


