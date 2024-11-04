import 'package:flutter/material.dart';
import 'package:team_maker/constants/colors.dart';
import 'package:team_maker/constants/images.dart';
import 'package:team_maker/constants/routes.dart';
import 'package:team_maker/presentaion/constFunctions/getImage.dart';
import 'package:team_maker/components/image_icon_button.dart';
import 'package:team_maker/constants/icons.dart';

class PickSport extends StatefulWidget {
  const PickSport({super.key});

  @override
  State<PickSport> createState() => _PickSportState();
}

class _PickSportState extends State<PickSport> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick a Sport'),
      ),
      backgroundColor: mainColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          getImage(context, 0.2, ballsPath),
          const Center(
            child: Text(
              'Select your favorite sport',
              style: TextStyle(fontSize: 20),
            ),
          ),
          const SizedBox(height: 20), // Space between text and grid
          Expanded(
            child: GridView.count(
              crossAxisCount: 2, // 2 icons per row
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              padding: const EdgeInsets.all(20),
              children: [
                ImageIconButton(
                  imagePath: footballPath,
                  size: 50.0,
                  onPressed: () {
                    Navigator.pushNamed(context, footballRout);
                  },
                ),
                ImageIconButton(
                  imagePath: tennisPath,
                  size: 50.0,
                  onPressed: () {
                    print('Tennis selected');
                  },
                ),
                ImageIconButton(
                  imagePath: basketballPath,
                  size: 300.0,
                  onPressed: () {
                    print('Basketball selected');
                  },
                ),
                ImageIconButton(
                  imagePath: volleyballPath,
                  size: 500.0,
                  onPressed: () {
                    print('Volleyball selected');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
