import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Navigate to the onboarding screen after 3 seconds
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/onboarding');
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF8F87F1),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Color(0xFF8F87F1), // Light purple background
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Add your logo or app name here
              SvgPicture.asset(
                'assets/logo/RatLogo.svg',
                width: 150,
                height: 150,
              ),
              SizedBox(height: 20),
              Text(
                'Fitness App',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D2B38), // Dark purple for text
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Your journey to fitness starts here!',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF1A1825), // Darker purple for secondary text
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
