import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF3B1E54),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF7EFE5), Color(0xFFD4BEE4)],
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Fitness App',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3B1E54),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: Text(
                  'Version 1.0.0',
                  style: TextStyle(fontSize: 16, color: Color(0xFF674188)),
                ),
              ),
              SizedBox(height: 30),
              _buildSection(
                'About the App',
                'This fitness application is designed to provide personalized exercise recommendations based on your health profile. It helps you maintain a healthy lifestyle while considering your medical conditions and physical capabilities.',
              ),
              SizedBox(height: 20),
              _buildSection(
                'Features',
                '• Personalized Exercise Plans\n'
                    '• Warm-up Routine\n'
                    '• Real-time Exercise Guidance\n'
                    '• Pose Detection of the Exercises\n'
                    '• Cool-down Routine',
              ),
              SizedBox(height: 20),
              _buildSection(
                'Safety Guidelines',
                '• Always consult your healthcare provider before starting any exercise program\n'
                    '• Start slowly and gradually increase intensity\n'
                    '• Stop immediately if you experience any pain or discomfort\n'
                    '• Stay hydrated during workouts\n'
                    '• Listen to your body and take breaks when needed',
              ),
              SizedBox(height: 20),
              _buildSection(
                'Health Profile Requirements',
                '• Age: 25-75 years\n'
                    '• Resting Heart Rate: 50-120 bpm\n'
                    '• Blood Pressure: 70-250/40-150 mmHg\n'
                    '• BMI: 10.0-50.0',
              ),
              SizedBox(height: 20),
              _buildSection(
                'Contact',
                'For support or questions, please contact:\n'
                    'Email: Team7@mlrinstitutions.ac.in\n'
              ),
              SizedBox(height: 30),
              Center(
                child: Text(
                  '© 2025 Fitness App.Powered by Team 7.',
                  style: TextStyle(fontSize: 14, color: Color(0xFF674188)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF3B1E54),
          ),
        ),
        SizedBox(height: 10),
        Text(
          content,
          style: TextStyle(fontSize: 16, color: Color(0xFF674188), height: 1.5),
        ),
      ],
    );
  }
}
