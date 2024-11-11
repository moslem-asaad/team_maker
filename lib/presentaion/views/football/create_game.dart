import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:team_maker/constants/colors.dart';
import 'package:team_maker/domain/entities/game.dart';
import 'package:team_maker/domain/entities/player.dart';
import 'package:team_maker/presentaion/views/football/generate_game.dart';
import 'package:team_maker/presentaion/views/football/widgets/create_player.dart';
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
  bool isRandomGeneration = false;
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
      //isAutomaticBuild = true;
      //isRandomGeneration = true;
      //_numOfTeams = 2;
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
  // Show the CreatePlayer dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return CreatePlayer(
        onSave: (String name, int attackRate, int midRate, int defRate) async {
          await _playerService.addPlayer(
            name: name,
            attackRate: attackRate,
            midRate: midRate,
            defRate: defRate,
          );
          // After saving, refresh the state to reflect the new player
          setState(() {
            _availablePlayers = _playerService.getAllPlayers();

            // Check if the list has been updated correctly
            if (_availablePlayers.isNotEmpty) {
              // Find the new player, handle if not found
              final newPlayer = _availablePlayers.firstWhere(
                (player) => player.id == (_availablePlayers.length - 1).toString(),
                orElse: () => Player('', attackRate, midRate, defRate, ''), // Safeguard against no matching element
              );

              // Add the player to the selected list if found
              if (newPlayer != null) {
                _selectedPlayers.add(newPlayer);
              } else {
                print('New player not found in the available players list');
              }
            } else {
              print('Available players list is empty after adding a new player');
            }
          });
        },
      );
    },
  );
}


  /*showPlayerDataDialog(
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
    );*/

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
        SnackBar(content: Text('setting saved and teams generated')),
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
      backgroundColor: mainColor,
      body: Stepper(
        currentStep: _currentStep,
        connectorColor: WidgetStatePropertyAll(boldGreen),
        controlsBuilder: _buildControlBuilders,
        onStepContinue: _OnStepContinue,
        onStepCancel: _onStepCancel,
        onStepTapped: _onStepTapped,
        steps: [
          _numOfTeamsStep(),
          _buildAndGenartionStep(),
          _selectPlayersStep(),
          _reviewAndConfirmStep(),
        ],
      ),
    );
  }

  Widget _buildControlBuilders(BuildContext context, ControlsDetails details) {
    return Row(
      children: <Widget>[
        ElevatedButton(
          onPressed: details.onStepContinue,
          style: ElevatedButton.styleFrom(
            backgroundColor: boldBlue, // Change the button color
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(20), // Change the button shape
            ),
          ),
          child: const Text(
            'Next',
            style: TextStyle(color: Colors.white),
          ),
        ),
        const SizedBox(width: 10),
        OutlinedButton(
          onPressed: details.onStepCancel,
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: Colors.red), // Change the border color
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(20), // Change the button shape
            ),
          ),
          child: const Text(
            'Back',
            style: TextStyle(color: Colors.red), // Change the text color
          ),
        ),
      ],
    );
  }

  void _OnStepContinue() {
    if (_currentStep < 3) {
      setState(() {
        _currentStep += 1;
      });
    } else {
      _saveGame();
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep -= 1;
      });
    }
  }

  void _onStepTapped(int tappedStep) {
    if (tappedStep < _currentStep) {
      setState(() {
        _currentStep = tappedStep;
      });
    }
  }

  Step _numOfTeamsStep() {
    double maxTeams = _availablePlayers.length.toDouble() < 2? 10 : _availablePlayers.length.toDouble();
    return Step(
      title: const Text('Select Number of Teams'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Number Of Teams: $_numOfTeams',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Slider(
            value: _numOfTeams.toDouble(),
            min: 2,
            max: maxTeams,
            divisions:
                _availablePlayers.length < 2? 10: _availablePlayers.length, // Number of divisions for each step
            label: '$_numOfTeams',
            onChanged: (double value) {
              setState(() {
                _numOfTeams = value.toInt();
              });
            },
            activeColor:
                Colors.blue, // Color of the active portion of the slider
            inactiveColor: Colors.blue[50], // Color of the inactive portion
          ),
        ],
      ),
    );
  }

  Step _buildAndGenartionStep() {
    return Step(
      title: const Text('Choose Generation Type'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /*const Text(
            'Build type:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Wrap(
              spacing: 20,
              children: [
                Row(
                  children: [
                    Radio<bool>(
                      value: true,
                      groupValue: isAutomaticBuild,
                      activeColor: Colors.blue,
                      onChanged: (value) {
                        setState(() {
                          isAutomaticBuild = value!;
                        });
                      },
                    ),
                    const Text('Automatic Build',
                        style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 20),
                    /*Radio<bool>(
                      value: false,
                      groupValue: isAutomaticBuild,
                      activeColor: Colors.blue,
                      onChanged: (value) {
                        setState(() {
                          isAutomaticBuild = value!;
                        });
                      },
                    ),*/
                    SizedBox(width: 200,),
                    //const Text('Manual Build', style: TextStyle(fontSize: 16)),
                  ],
                ),
              ],
            ),
          ),*/
          if (isAutomaticBuild) ...[
            const SizedBox(height: 10),
            const Text(
              'Choose generation type:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 20,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Radio<bool>(
                        value: false,
                        groupValue: isRandomGeneration,
                        activeColor: Colors.blue,
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
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Radio<bool>(
                        value: true,
                        groupValue: isRandomGeneration,
                        activeColor: Colors.blue,
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
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Step _selectPlayersStep() {
    return Step(
      title: const Text('Select Players '),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: BorderSide(color: Colors.blue),
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  elevation: 10,
                ),
                onPressed: () {
                  setState(() {
                    _selectAll();
                  });
                },
                child: Text('Select All', style: TextStyle(color: boldBlue)),
              ),
              _selectedPlayers.isNotEmpty
                  ? ElevatedButton.icon(
                      icon: const Icon(Icons.clear, color: Colors.red),
                      label: const Text("Clear All",
                          style: TextStyle(color: Colors.red)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 16),
                        elevation: 10,
                      ),
                      onPressed: _clearallChoices,
                    )
                  : SizedBox(),
            ],
          ),
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
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton.icon(
                label: Text(
                  'Create New Player',
                  style: TextStyle(color: boldBlue),
                ),
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(Colors.blue),
                  elevation: WidgetStatePropertyAll(8),
                ),
                onPressed: _addPlayer,
              ),
              ElevatedButton(
                child: Text(
                  'Show All players',
                  style: TextStyle(
                    color: boldBlue,
                  ),
                ),
                style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(Colors.green),
                    elevation: WidgetStatePropertyAll(8)),
                onPressed: _showFullScreenPlayerList,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Step _reviewAndConfirmStep() {
    return Step(
      title: const Text('Review & Confirm'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Review your game settings:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text('Number of Teams: $_numOfTeams'),
          Text('Build Type: ${isAutomaticBuild ? 'Automatic' : 'Manual'}'),
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
    );
  }
}
