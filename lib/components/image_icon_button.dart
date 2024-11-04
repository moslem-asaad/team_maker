import 'package:flutter/material.dart';

class ImageIconButton extends StatelessWidget {
  final String imagePath;
  final double size;
  final VoidCallback onPressed;

  const ImageIconButton({
    Key? key,
    required this.imagePath,
    required this.onPressed,
    this.size = 24.0, // Default size for the icon
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white, // Background color for the icon
          border: Border.all(color: Colors.black, width: 2), // Black border
          borderRadius: BorderRadius.circular(8), // Optional: rounded corners
        ),
        child: Image.asset(
          imagePath,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
