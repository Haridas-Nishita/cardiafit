import 'package:cardiafit/DetectionScreen.dart';
import 'package:cardiafit/Model/ExerciseDataModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ExerciseListingScreen extends StatefulWidget {
  final Map<String, dynamic> userParams;
  const ExerciseListingScreen({super.key, required this.userParams});

  @override
  State<ExerciseListingScreen> createState() => _ExerciseListingScreenState();
}

class _ExerciseListingScreenState extends State<ExerciseListingScreen> {
  List<ExerciseDataModel> exerciseList = [];

  // Define exercise groups by risk level
  final Map<String, List<ExerciseDataModel>> exerciseGroups = {
    'highRisk': [],
    'moderateRisk': [],
    'lowRisk': [],
  };

  void loadData() {
    // Get user parameters
    final age = widget.userParams['age'] as int?;
    final medicalHistory = widget.userParams['medicalHistory'] as String?;
    final currentDiagnosis = widget.userParams['currentDiagnosis'] as String?;
    final restingHeartRate = widget.userParams['restingHeartRate'] as int?;
    final bloodPressure = widget.userParams['bloodPressure'] as String?;
    final bmi = widget.userParams['bmi'] as double?;

    // Parse blood pressure
    List<String>? bpParts = bloodPressure?.split('/');
    int? systolic = bpParts != null ? int.tryParse(bpParts[0]) : null;
    int? diastolic = bpParts != null ? int.tryParse(bpParts[1]) : null;

    // Segregate exercises into risk groups
    // High Risk Exercises (very gentle, low impact)
    exerciseGroups['highRisk'] = [
      ExerciseDataModel(
        "Shoulder Shrug",
        "ShoulderShrug.json",
        Color.fromRGBO(220, 198, 235, 1),
        ExerciseType.ShoulderShrug,
      ),
      ExerciseDataModel(
        "Leg Straighten Up Down",
        "LegStraightenUpDown.json",
        Color.fromRGBO(220, 198, 235, 1),
        ExerciseType.LegStraightenUpDown,
      ),
      ExerciseDataModel(
        "Calf Raise",
        "CalfRaise.json",
        Color.fromRGBO(220, 198, 235, 1),
        ExerciseType.CalfRaise,
      ),
      ExerciseDataModel(
        "Dynamic Hip Lift",
        "HipLift.json",
        Color.fromRGBO(220, 198, 235, 1),
        ExerciseType.HipLift,
      ),
    ];

    // Moderate Risk Exercises (low impact)
    exerciseGroups['moderateRisk'] = [
      ExerciseDataModel(
        "Side leg raise left",
        "SideLegRaiseLeft.json",
        Color.fromRGBO(220, 198, 235, 1),
        ExerciseType.SideLegRaiseLeft,
      ),
      ExerciseDataModel(
        "Side leg raise right",
        "SideLegRaiseRight.json",
        Color.fromRGBO(220, 198, 235, 1),
        ExerciseType.SideLegRaiseRight,
      ),
      ExerciseDataModel(
        "Leg Kick Back Right",
        "LegKickBackRight.json",
        Color.fromRGBO(220, 198, 235, 1),
        ExerciseType.LegKickBackRight,
      ),
      ExerciseDataModel(
        "Leg Kick Back Left",
        "LegKickBackLeft.json",
        Color.fromRGBO(220, 198, 235, 1),
        ExerciseType.LegKickBackLeft,
      ),
      ExerciseDataModel(
        "Hip Swing Right",
        "HipSwingRight.json",
        Color.fromRGBO(220, 198, 235, 1),
        ExerciseType.HipSwingRight,
      ),
      ExerciseDataModel(
        "Hip Swing Left",
        "HipSwingLeft.json",
        Color.fromRGBO(220, 198, 235, 1),
        ExerciseType.HipSwingLeft,
      ),
    ];

    // Low Risk Exercises (moderate impact)
    exerciseGroups['lowRisk'] = [
      ExerciseDataModel(
        "Push Ups",
        "pushup.gif",
        Color.fromRGBO(220, 198, 235, 1),
        ExerciseType.PushUps,
      ),
      ExerciseDataModel(
        "Squats",
        "squat.gif",
        Color.fromRGBO(220, 198, 235, 1),
        ExerciseType.Squats,
      ),
      ExerciseDataModel(
        "Russian Twist",
        "RussianTwist.json",
        Color.fromRGBO(220, 198, 235, 1),
        ExerciseType.RussianTwist,
      ),
      ExerciseDataModel(
        "Jumping jack",
        "jumping.gif",
        Color.fromRGBO(220, 198, 235, 1),
        ExerciseType.JumpingJack,
      ),
      ExerciseDataModel(
        "Front Lunge Left",
        "FrontLungeLeft.json",
        Color.fromRGBO(220, 198, 235, 1),
        ExerciseType.FrontLungeLeft,
      ),
      ExerciseDataModel(
        "Front Lunge Right",
        "FrontLungeRight.json",
        Color.fromRGBO(220, 198, 235, 1),
        ExerciseType.FrontLungeRight,
      ),
      ExerciseDataModel(
        "Sit Ups",
        "SitUps.json",
        Color.fromRGBO(220, 198, 235, 1),
        ExerciseType.SitUps,
      ),
      ExerciseDataModel(
        "Crunches",
        "ReverseCrunches.json",
        Color.fromRGBO(220, 198, 235, 1),
        ExerciseType.ReverseCrunches,
      ),
    ];

    // Determine user's risk level
    String riskLevel;
    if (medicalHistory == 'Bypass Surgery' ||
        currentDiagnosis == 'Heart Failure' ||
        (systolic != null && systolic > 140) ||
        (diastolic != null && diastolic > 90) ||
        (restingHeartRate != null && restingHeartRate > 100)) {
      riskLevel = 'highRisk';
    } else if (medicalHistory == 'Previous Heart Attack' ||
        currentDiagnosis == 'Coronary Artery Disease' ||
        (bmi != null && bmi > 30)) {
      riskLevel = 'moderateRisk';
    } else {
      riskLevel = 'lowRisk';
    }

    // Select 4 exercises based on risk level, keeping left/right exercises together
    List<ExerciseDataModel> selectedExercises = [];
    List<ExerciseDataModel> availableExercises = List.from(
      exerciseGroups[riskLevel]!,
    );

    // First, add paired exercises (left/right)
    for (int i = 0; i < availableExercises.length - 1; i++) {
      if (availableExercises[i].title.toLowerCase().contains('left') &&
          availableExercises[i + 1].title.toLowerCase().contains('right')) {
        selectedExercises.add(availableExercises[i]);
        selectedExercises.add(availableExercises[i + 1]);
        availableExercises.removeAt(i + 1);
        availableExercises.removeAt(i);
        i--;
      }
    }

    // Add remaining exercises until we have 4
    while (selectedExercises.length < 4 && availableExercises.isNotEmpty) {
      selectedExercises.add(availableExercises.removeAt(0));
    }

    setState(() {
      exerciseList = selectedExercises;
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
        title: Text("Main Exercises", style: TextStyle(color: Colors.white)),
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
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => Detectionscreen(
                                exerciseDataModel: exerciseList[index],
                              ),
                        ),
                      );
                    },
                    child: Container(
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
                    '/cooldown',
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
                  'Next: Cool-down Exercises',
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
