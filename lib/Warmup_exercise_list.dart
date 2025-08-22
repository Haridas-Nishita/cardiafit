import 'package:cardiafit/DetectionScreen.dart';
import 'package:cardiafit/Model/ExerciseDataModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:cardiafit/warmup_animation_screen.dart';

class WarmupExerciseList extends StatefulWidget {
  final Map<String, dynamic> userParams;

  const WarmupExerciseList({super.key, required this.userParams});

  @override
  State<WarmupExerciseList> createState() => _WarmupExerciseListState();
}

class _WarmupExerciseListState extends State<WarmupExerciseList> {
  List<ExerciseDataModel> exerciseList = [];
  loadData() {
    exerciseList.add(
      ExerciseDataModel(
        "Light Marching",
        "LightMarching.json",
        Color.fromRGBO(220, 198, 235, 1),
        ExerciseType.Lightmarching,
      ),
    );
    exerciseList.add(
      ExerciseDataModel(
        "Punch Outs",
        "PunchOut.json",
        Color.fromRGBO(220, 198, 235, 1),
        ExerciseType.WallSit,
      ),
    );
    exerciseList.add(
      ExerciseDataModel(
        "Shoulder Stretch Left",
        "ShoulderStretch.json",
        Color.fromRGBO(220, 198, 235, 1),
        ExerciseType.ShoulderStretchLeft,
      ),
    );
    exerciseList.add(
      ExerciseDataModel(
        "Shoulder Stretch Right",
        "ShoulderStretch.json",
        Color.fromRGBO(220, 198, 235, 1),
        ExerciseType.ShoulderStretchRight,
      ),
    );
    exerciseList.add(
      ExerciseDataModel(
        "Chest Stretch",
        "ChestStretch.json",
        Color.fromRGBO(220, 198, 235, 1),
        ExerciseType.ChestStretch,
      ),
    );
    setState(() {
      exerciseList;
    });
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Warm-up Exercises", style: TextStyle(color: Colors.white)),
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
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(220, 198, 235, 1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    height: 150,
                    margin: EdgeInsets.all(10),
                    padding: EdgeInsets.all(10),
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: Text(
                            exerciseList[index].title,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF3B1E54),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child:
                              exerciseList[index].image.endsWith('.json')
                                  ? Lottie.asset(
                                    'assets/${exerciseList[index].image}',
                                  )
                                  : Image.asset(
                                    'assets/${exerciseList[index].image}',
                                  ),
                        ),
                      ],
                    ),
                  );
                },
                itemCount: exerciseList.length,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/warmup-animation',
                        arguments: {
                          'exercises': exerciseList,
                          'userParams': widget.userParams,
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF3B1E54),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      'Start Workout',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/workout-plan',
                        arguments: widget.userParams,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF8F87F1),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      'Next',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
