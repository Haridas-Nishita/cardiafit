import 'package:cardiafit/DetectionScreen.dart';
import 'package:cardiafit/Model/ExerciseDataModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:cardiafit/coolDown_animation_screen.dart';

class CoolDownExerciseList extends StatefulWidget {
  final Map<String, dynamic> userParams;

  const CoolDownExerciseList({super.key, required this.userParams});

  @override
  State<CoolDownExerciseList> createState() => _CoolDownExerciseListState();
}

class _CoolDownExerciseListState extends State<CoolDownExerciseList> {
  List<ExerciseDataModel> exerciseList = [];
  loadData() {
    exerciseList.add(
      ExerciseDataModel(
        "Brisk Walk",
        "BriskWalk.json",
        Color.fromRGBO(220, 198, 235, 1),
        ExerciseType.BriskWalk,
      ),
    );
    exerciseList.add(
      ExerciseDataModel(
        "Thigh Stretch Left",
        "ThighStretchLeft.json",
        Color.fromRGBO(220, 198, 235, 1),
        ExerciseType.ThighStretchLeft,
      ),
    );
    exerciseList.add(
      ExerciseDataModel(
        "Thigh Stretch Right",
        "ThighStretchLeft.json",
        Color.fromRGBO(220, 198, 235, 1),
        ExerciseType.ThighStretchRight,
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
    exerciseList.add(
      ExerciseDataModel(
        "Pigeon Stretch Left",
        "PigeonStretchLeft.json",
        Color.fromRGBO(220, 198, 235, 1),
        ExerciseType.PigeonStretchLeft,
      ),
    );
    exerciseList.add(
      ExerciseDataModel(
        "Pigeon Stretch Right",
        "PigeonStretchRight.json",
        Color.fromRGBO(220, 198, 235, 1),
        ExerciseType.PigeonStretchRight,
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
        title: Text(
          "Cool-down Exercises",
          style: TextStyle(color: Colors.white),
        ),
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
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/cooldown-animation',
                    arguments: {
                      'exercises': exerciseList,
                      'userParams': widget.userParams,
                    },
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
                  'Start Cool-down',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
