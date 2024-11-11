import 'package:flutter/material.dart';
import 'package:team_maker/domain/entities/player.dart';

class MultiSelectDropdown extends StatefulWidget {
  final List<Player> availablePlayers;
  final List<Player> selectedPlayers;
  final Function(Player) onPlayerSelected;
  final Function(Player) onPlayerDeselected;

  const MultiSelectDropdown({
    Key? key,
    required this.availablePlayers,
    required this.selectedPlayers,
    required this.onPlayerSelected,
    required this.onPlayerDeselected,
  }) : super(key: key);

  @override
  _MultiSelectDropdownState createState() => _MultiSelectDropdownState();
}

class _MultiSelectDropdownState extends State<MultiSelectDropdown> {
  bool _isDropdownOpen = false;

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _isDropdownOpen = !_isDropdownOpen;
            });
          },
          child: Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Select Players'),
                Icon(
                  _isDropdownOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                ),
              ],
            ),
          ),
        ),
        if (_isDropdownOpen)
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8.0),
              color: Colors.white,
            ),
            constraints: BoxConstraints(
              maxHeight: 300.0, // Adjust the height as needed
            ),
            child: ListView(
              children: widget.availablePlayers.map((player) {
                final isSelected = widget.selectedPlayers.contains(player);
                return ListTile(
                  leading: isSelected
                      ? Icon(Icons.check, color: Colors.blue)
                      : SizedBox.shrink(),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        constraints: BoxConstraints(
                          maxWidth:
                              width * 0.3, // Adjust this value to fit approximately 30 characters
                        ),
                        child: Text(
                          player.fullName ?? 'Unnamed Player',
                          style: TextStyle(
                            fontSize: 18,
                          ),
                          softWrap: true,
                          maxLines: 2, // Allows unlimited lines
                          overflow: TextOverflow.visible,
                        ),
                      ),
                      Text(
                        'overall - ${player.overall?.toInt()}',
                        style: TextStyle(
                          fontSize: 12, // Make the overall smaller
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        widget.onPlayerDeselected(player);
                      } else {
                        widget.onPlayerSelected(player);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}
