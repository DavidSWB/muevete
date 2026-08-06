import 'package:flutter/material.dart';
import 'package:muevete/shared/theme/app_colors.dart';

class MyQuizImage extends StatelessWidget {
  const MyQuizImage({
    super.key,
    required this.imagePath,
  });


  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 30,
      margin: EdgeInsets.all(25),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppColors.softGrey,
        boxShadow:[ 
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.5),
            spreadRadius: 3,
            blurRadius: 7,
            offset: Offset(0, 3),
          ),
        ],
        image: imagePath.isEmpty 
        ? null
        : DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.contain,
        
        ),
      ),
    );
  }
}