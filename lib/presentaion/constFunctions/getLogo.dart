import 'package:flutter/material.dart';
import 'package:team_maker/constants/images.dart';

getLogo(BuildContext context,double ratio) {
  
  return ClipRRect(
    borderRadius: BorderRadius.circular(20),
    child: Image.asset(
      teamMakerPath,
      width: MediaQuery.of(context).size.height * ratio,
    ),
  );
}