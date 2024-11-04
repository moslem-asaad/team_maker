import 'package:flutter/material.dart';

getImage(BuildContext context,double ratio, String path) {
  
  return ClipRRect(
    borderRadius: BorderRadius.circular(20),
    child: Image.asset(
      path,
      width: MediaQuery.of(context).size.height * ratio,
    ),
  );
}