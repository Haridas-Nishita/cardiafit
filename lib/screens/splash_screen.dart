import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Navigate to the next screen after 3 seconds
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/onboarding');
    });

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF3B1E54), // Dark purple
              Color(0xFF674188), // Medium purple
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Add your logo or app name here
              Image.asset(
                'assets/images/logo.png', // Replace with your logo path
                width: 150,
                height: 150,
              ),
              SizedBox(height: 20),
              Text(
                'Fitness App',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFEEEEEE), // Light gray for text
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Your journey to fitness starts here!',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFFD4BEE4), // Light purple for text
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}