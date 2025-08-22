import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:cardiafit/Model/ExerciseDataModel.dart';
import 'package:cardiafit/ExerciselistScreen.dart';
import 'dart:async';

class WarmupAnimationScreen extends StatefulWidget {
  final List<ExerciseDataModel> exercises;
  final Map<String, dynamic> userParams;

  const WarmupAnimationScreen({
    Key? key,
    required this.exercises,
    required this.userParams,
  }) : super(key: key);

  @override
  State<WarmupAnimationScreen> createState() => _WarmupAnimationScreenState();
}

class _WarmupAnimationScreenState extends State<WarmupAnimationScreen> {
  int currentExerciseIndex = 0;
  int timeRemaining = 120; // 2 minutes for first exercise
  bool isRest = false;
  bool isWorkoutComplete = false;
  bool isPaused = false;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!isPaused) {
        setState(() {
          if (timeRemaining > 0) {
            timeRemaining--;
          } else {
            if (currentExerciseIndex < widget.exercises.length - 1) {
              if (!isRest) {
                // Start rest period
                isRest = true;
                timeRemaining = 10;
              } else {
                // Move to next exercise
                currentExerciseIndex++;
                isRest = false;
                timeRemaining = 30; // 30 seconds for other exercises
              }
            } else {
              // Workout complete
              isWorkoutComplete = true;
              timer.cancel();
            }
          }
        });
      }
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  String get timeString {
    int minutes = timeRemaining ~/ 60;
    int seconds = timeRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Widget getExercisePreview() {
    if (isRest && currentExerciseIndex < widget.exercises.length - 1) {
      // Show next exercise preview during rest
      final nextExercise = widget.exercises[currentExerciseIndex + 1];
      return Container(
        height: 300,
        child: Column(
          children: [
            Text(
              "Next: ${nextExercise.title}",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3B1E54),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child:
                  nextExercise.image.endsWith('.json')
                      ? Lottie.asset('assets/${nextExercise.image}')
                      : Image.asset('assets/${nextExercise.image}'),
            ),
          ],
        ),
      );
    } else {
      // Show current exercise
      return Container(
        height: 300,
        child:
            widget.exercises[currentExerciseIndex].image.endsWith('.json')
                ? Lottie.asset(
                  'assets/${widget.exercises[currentExerciseIndex].image}',
                )
                : Image.asset(
                  'assets/${widget.exercises[currentExerciseIndex].image}',
                ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Warm-up Workout", style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF3B1E54),
        actions: [
          IconButton(
            icon: Icon(isPaused ? Icons.play_arrow : Icons.pause),
            onPressed: () {
              setState(() {
                isPaused = !isPaused;
              });
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF7EFE5), Color(0xFFD4BEE4)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!isWorkoutComplete) ...[
              Text(
                isRest
                    ? "Rest Time"
                    : widget.exercises[currentExerciseIndex].title,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3B1E54),
                ),
              ),
              SizedBox(height: 20),
              Text(
                timeString,
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3B1E54),
                ),
              ),
              SizedBox(height: 40),
              getExercisePreview(),
              SizedBox(height: 40),
              Text(
                "Exercise ${currentExerciseIndex + 1} of ${widget.exercises.length}",
                style: TextStyle(fontSize: 18, color: Color(0xFF3B1E54)),
              ),
            ] else ...[
              Icon(Icons.check_circle, size: 100, color: Colors.green),
              SizedBox(height: 20),
              Text(
                "Workout Complete!",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3B1E54),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/workout-plan',
                    arguments: widget.userParams,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF3B1E54),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'Next: Main Exercises',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
