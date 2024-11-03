import 'package:flutter/material.dart';
import 'package:team_maker/presentaion/constFunctions/getLogo.dart';
import 'package:team_maker/constants/routes.dart';
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
        child: getLogo(context, 0.4),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, pickSportRout);
        },
        child: const Icon(Icons.arrow_forward),
        tooltip: 'Navigate to Pick Sport',
      ),
    );
  }
}