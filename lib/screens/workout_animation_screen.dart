import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'dart:async'; // Import for Timer
import '../models/exercise_model.dart';

class WorkoutAnimationScreen extends StatefulWidget {
  final List<Exercise> exercises;

  WorkoutAnimationScreen({required this.exercises});

  @override
  _WorkoutAnimationScreenState createState() => _WorkoutAnimationScreenState();
}

class _WorkoutAnimationScreenState extends State<WorkoutAnimationScreen> {
  int currentExerciseIndex = 0;
  bool isResting = false;
  late int countdown; // Will be set based on exercise duration
  late Timer timer;

  // Updated Color Palette
  final Color primaryColor = Color(0xFF3B1E54); // Dark purple
  final Color secondaryColor = Color(0xFF9B7EBD); // Medium purple
  final Color backgroundColor = Color(0xFFF7EFE5); // Light background
  final Color textColor = Color(0xFF674188); // Medium purple for text
  final Color accentColor = Color(0xFFC8A1E0); // Light purple for accents

  @override
  void initState() {
    super.initState();
    startWorkout();
  }

  void startWorkout() {
    _playExercise();
  }

  void _playExercise() {
    if (!mounted) return;

    if (currentExerciseIndex < widget.exercises.length) {
      setState(() {
        isResting = false;
        // Use the exercise's actual duration
        countdown = widget.exercises[currentExerciseIndex].duration;
      });

      timer = Timer.periodic(Duration(seconds: 1), (timer) {
        if (!mounted) return;

        setState(() {
          if (countdown > 0) {
            countdown--;
          } else {
            timer.cancel();
            // Skip rest after the last exercise
            if (currentExerciseIndex == widget.exercises.length - 1) {
              Navigator.pop(context);
            } else {
              _startRest();
            }
          }
        });
      });
    } else {
      Navigator.pop(context);
    }
  }

  void _startRest() {
    setState(() {
      isResting = true;
      // Use the exercise's actual rest time
      countdown = widget.exercises[currentExerciseIndex].restTime;
    });

    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!mounted) return;

      setState(() {
        if (countdown > 0) {
          countdown--;
        } else {
          timer.cancel();
          currentExerciseIndex++;
          _playExercise();
        }
      });
    });
  }

  @override
  void dispose() {
    timer.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = MediaQuery.of(context).padding;
    // Calculate available height (excluding status bar and app bar)
    final availableHeight =
        screenHeight - padding.top - padding.bottom - kToolbarHeight;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Workout Animation',
          style: TextStyle(color: Color(0xFFEEEEEE)),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
      ),
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: currentExerciseIndex < widget.exercises.length
            ? SingleChildScrollView(
                child: Container(
                  height: availableHeight,
                  child: Column(
                    children: [
                      // Exercise Name Section (8% of available height)
                      Container(
                        height: availableHeight * 0.08,
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        alignment: Alignment.center,
                        child: Text(
                          isResting
                              ? 'Rest Time'
                              : widget.exercises[currentExerciseIndex].name,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ),

                      // Animation Section (50% of available height)
                      Container(
                        height: availableHeight * 0.5,
                        width: double.infinity,
                        child: !isResting
                            ? Center(
                                child: Lottie.asset(
                                  widget.exercises[currentExerciseIndex]
                                      .animationPath,
                                  width: screenWidth * 0.8,
                                  height: availableHeight * 0.45,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    print('Error loading animation: $error');
                                    return Container(
                                      color: Colors.grey[200],
                                      child: Center(
                                        child: Text(
                                          'Exercise: ${widget.exercises[currentExerciseIndex].name}',
                                          style: TextStyle(
                                            fontSize: 20,
                                            color: textColor,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Next Exercise:',
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: textColor,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    widget.exercises[currentExerciseIndex + 1]
                                        .name,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  Lottie.asset(
                                    widget.exercises[currentExerciseIndex + 1]
                                        .animationPath,
                                    width: screenWidth * 0.6,
                                    height: availableHeight * 0.3,
                                    fit: BoxFit.contain,
                                  ),
                                ],
                              ),
                      ),

                      // Timer Section (15% of available height)
                      Container(
                        height: availableHeight * 0.15,
                        child: Center(
                          child: Container(
                            width: screenWidth * 0.3,
                            height: screenWidth * 0.3,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: accentColor,
                                width: 4,
                              ),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    countdown.toString(),
                                    style: TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ),
                                  Text(
                                    'seconds',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: textColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : Center(
                child: Text(
                  'All Exercises Completed!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ),
      ),
    );
  }
}

