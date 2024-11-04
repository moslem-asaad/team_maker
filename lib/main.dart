import 'package:flutter/material.dart';
import 'package:team_maker/components/my_elevation_button.dart';
import 'package:team_maker/presentaion/constFunctions/getLogo.dart';
import 'package:team_maker/constants/routes.dart';
import 'package:team_maker/presentaion/views/football/football.dart';
import 'package:team_maker/presentaion/views/football/player_managment.dart';
import 'package:team_maker/presentaion/views/pick_sport.dart';




void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey
      ),
      home: const HomePage(),
      routes: {
        pickSportRout: (context) => const PickSport(),
        footballRout:(context) => const Football(),
        playerManegmentRout: (context) => const PlayerManagementScreen(),
      },
    )
  );
}



class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
           mainAxisAlignment: MainAxisAlignment.center,
          children: [
            getLogo(context, 0.4),
        MyElevationButton(
        title:'Navigate to Pick Sport',
        onPressed: () {
          Navigator.pushNamed(context, pickSportRout);
        },
        ),
          ],
        ) 
        
      ),
      
    );
  }
}