import 'package:flutter/material.dart';
import 'package:frontend/core/theme/colors.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTitle extends StatelessWidget {
  const AppTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        children: [
          Text(
            "TURF",
            style: GoogleFonts.climateCrisis(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            "MATE",
            style: GoogleFonts.climateCrisis(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color:AppColors.focusColor,
            ),
          ),
        ],
      ),
    );
  }
}

class WelcomeText extends StatelessWidget {
  const WelcomeText({super.key});

  @override
  Widget build(BuildContext context) {
    return  Text(
      "• Find Players • Join Matches •",
      textAlign: TextAlign.center,
      style: GoogleFonts.unicaOne(fontSize: 18, color: Colors.white70),
    );
  }
}
