import 'package:flutter/material.dart';
import 'package:team_maker/constants/colors.dart';

class MyElevationButton extends StatelessWidget {

  

  final Function()? onPressed;
  final String title;
  const MyElevationButton({super.key,this.onPressed,required this.title});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white, // Inner color
        side: const BorderSide(color: Color(0xFF4BE5FA), width: 2), // Border color (light blue)
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // Optional: rounded corners
        ),
        textStyle: const TextStyle(
          color: boldGreen, // Text color (light green)
          fontWeight: FontWeight.bold,
        ),
      ),
      child: Text(
        title,
        style: const TextStyle(
          color: boldGreen, // Text color (light green)
        ),
      ),
    );
  }
}