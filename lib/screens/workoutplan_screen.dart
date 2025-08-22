import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../models/exercise_model.dart';
import '../screens/workout_animation_screen.dart'; // Import the workout animation screen
import '../workout_plan_generator.dart';

class WorkoutPlanScreen extends StatelessWidget {
  late final List<Exercise> exercises;

  @override
  Widget build(BuildContext context) {
    // Get the arguments passed from OnboardingScreen
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    // Generate the workout plan using the passed parameters
    exercises = WorkoutPlanGenerator.generateWorkoutPlan(
      age: args['age'] as int,
      gender: args['gender'] as String,
      medicalHistory: args['medicalHistory'] as String,
      currentDiagnosis: args['currentDiagnosis'] as String,
      restingHeartRate: args['restingHeartRate'] as int,
      bloodPressure: args['bloodPressure'] as String,
      bmi: args['bmi'] as double,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Workout Plan',
          style: TextStyle(color: Color(0xFFEEEEEE)), // Light gray text
        ),
        backgroundColor: Color(0xFF3B1E54), // Dark purple for app bar
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF7EFE5), // Light background
              Color(0xFFD4BEE4), // Light purple
            ],
          ),
        ),
        child: Column(
          children: [
            // List of exercises
            Expanded(
              child: ListView.builder(
                itemCount: exercises.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.all(8),
                    color: Color(0xFFEEEEEE), // Light gray for card background
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      // Display the Lottie animation for the exercise
                      leading: Lottie.asset(
                        exercises[index].animationPath, // Updated path
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                      // Display the exercise name
                      title: Text(
                        exercises[index].name,
                        style: TextStyle(
                          color: Color(0xFF3B1E54), // Dark purple for text
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        color: Color(0xFF674188), // Medium purple for icon
                      ),
                      onTap: () {
                        // Navigate to the WorkoutAnimationScreen for the selected exercise
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WorkoutAnimationScreen(
                                exercises: [exercises[index]]),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            // Start Workout button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to the WorkoutAnimationScreen and pass the list of exercises
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          WorkoutAnimationScreen(exercises: exercises),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Color(0xFF9B7EBD), // Medium purple for button
                  foregroundColor: Color(0xFFEEEEEE), // Light gray text
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Start Workout',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
