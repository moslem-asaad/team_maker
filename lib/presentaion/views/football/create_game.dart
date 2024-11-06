import 'package:flutter/material.dart';
import 'package:team_maker/constants/colors.dart';
import 'package:team_maker/domain/entities/player.dart';
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
  List<Player> _availablePlayers = [];
  List<Player> _selectedPlayers = [];
  TextEditingController _teamSizeController = TextEditingController();

  bool isAutomaticBuild = true;
  bool isRandomGeneration = true;

  final ScrollController _scrollController = ScrollController();
  bool _canScrollUp = false;
  bool _canScrollDown = true;

  @override
  void initState() {
    super.initState();
    _playerService = PlayerService();
    _initializeData();
    _scrollController.addListener(_updateScrollIndicators);
  }

  @override
  void dispose() {
    _teamSizeController.dispose();
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
      _teamSizeController.dispose();
      _teamSizeController = TextEditingController();
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

  void _saveGame() {
    print("Game saved");
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
                    const Text(
                      'How many players in each team?',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _teamSizeController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.blue[50],
                        hintText: 'Enter team size',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 12),
                      ),
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

                    // Generation Type Options
                    const Text(
                      'Choose generation type:',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                        height: 200,
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
