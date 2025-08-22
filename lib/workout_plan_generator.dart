import '../models/exercise_model.dart';

class WorkoutPlanGenerator {
  static List<Exercise> generateWorkoutPlan({
    required int age,
    required String gender,
    required String medicalHistory,
    required String currentDiagnosis,
    required int restingHeartRate,
    required String bloodPressure,
    required double bmi,
  }) {
    List<Exercise> workoutPlan = [];

    // List of allowed exercises
    final allowedExercises = [
      'BentOverRow.json',
      'BriskWalk.json',
      'CalfRaise.json',
      'ChestStretch.json',
      'FrontLungeLeft.json',
      'FrontLungeRight.json',
      'HipLift.json',
      'HipSwingLeft.json',
      'HipSwingRight.json',
      'LegKickBackLeft.json',
      'LegKickBackRight.json',
      'LegStraightenUpDown.json',
      'LightMarching.json',
      'PunchOut.json',
      'RegularSquat.json',
      'RussianTwist.json',
      'ShoulderShrug.json',
      'ShoulderStretchLeft.json',
      'ShoulderStretchRight.json',
      'SideLegRaiseLeft.json',
      'SideLegRaiseRight.json',
      'ThighStretchLeft.json',
      'ThighStretchRight.json',
      'WallSit.json',
    ];

    // 1. Start with light marching (2 minutes)
    workoutPlan.add(
      Exercise(
        name: 'Light Marching',
        animationPath: 'assets/animations/LightMarching.json',
        duration: 120,
        restTime: 30,
        type: ExerciseType.cardio,
      ),
    );

    // 2. Add warm-up exercises (fixed for all)
    final warmUpExercises = [
      Exercise(
        name: 'Shoulder Shrug',
        animationPath: 'assets/animations/ShoulderShrug.json',
        duration: 30,
        restTime: 15,
        type: ExerciseType.warmUp,
      ),
      Exercise(
        name: 'Chest Stretch',
        animationPath: 'assets/animations/ChestStretch.json',
        duration: 30,
        restTime: 15,
        type: ExerciseType.warmUp,
      ),
      Exercise(
        name: 'Thigh Stretch Left',
        animationPath: 'assets/animations/ThighStretchLeft.json',
        duration: 30,
        restTime: 15,
        type: ExerciseType.warmUp,
      ),
      Exercise(
        name: 'Thigh Stretch Right',
        animationPath: 'assets/animations/ThighStretchRight.json',
        duration: 30,
        restTime: 15,
        type: ExerciseType.warmUp,
      ),
    ];
    workoutPlan.addAll(warmUpExercises);

    // 3. Add main exercises (customized)
    List<Exercise> mainExercises = _generateMainExercises(
      age: age,
      gender: gender,
      medicalHistory: medicalHistory,
      currentDiagnosis: currentDiagnosis,
      restingHeartRate: restingHeartRate,
      bloodPressure: bloodPressure,
      bmi: bmi,
      allowedExercises: allowedExercises,
    );
    workoutPlan.addAll(mainExercises);

    // 4. Add cool-down exercises (fixed for all)
    final coolDownExercises = [
      Exercise(
        name: 'Chest Stretch',
        animationPath: 'assets/animations/ChestStretch.json',
        duration: 30,
        restTime: 15,
        type: ExerciseType.coolDown,
      ),
      Exercise(
        name: 'Thigh Stretch Left',
        animationPath: 'assets/animations/ThighStretchLeft.json',
        duration: 30,
        restTime: 15,
        type: ExerciseType.coolDown,
      ),
      Exercise(
        name: 'Thigh Stretch Right',
        animationPath: 'assets/animations/ThighStretchRight.json',
        duration: 30,
        restTime: 15,
        type: ExerciseType.coolDown,
      ),
      Exercise(
        name: 'Hip Lift',
        animationPath: 'assets/animations/HipLift.json',
        duration: 30,
        restTime: 15,
        type: ExerciseType.coolDown,
      ),
    ];
    workoutPlan.addAll(coolDownExercises);

    // 5. End with light brisk walk (2 minutes)
    workoutPlan.add(
      Exercise(
        name: 'Light Brisk Walk',
        animationPath: 'assets/animations/BriskWalk.json',
        duration: 120,
        restTime: 0,
        type: ExerciseType.cardio,
      ),
    );

    return workoutPlan;
  }

  static List<Exercise> _generateMainExercises({
    required int age,
    required String gender,
    required String medicalHistory,
    required String currentDiagnosis,
    required int restingHeartRate,
    required String bloodPressure,
    required double bmi,
    required List<String> allowedExercises,
  }) {
    // Calculate exercise and rest duration based on user parameters
    int exerciseDuration = _calculateExerciseDuration(
      age,
      medicalHistory,
      restingHeartRate,
      bmi,
      bloodPressure,
    );
    int restDuration = _calculateRestDuration(
      restingHeartRate,
      medicalHistory,
      bmi,
      bloodPressure,
    );

    // Define paired exercises
    final pairedExercises = [
      ['FrontLungeLeft.json', 'FrontLungeRight.json'],
      ['HipSwingLeft.json', 'HipSwingRight.json'],
      ['LegKickBackLeft.json', 'LegKickBackRight.json'],
      ['SideLegRaiseLeft.json', 'SideLegRaiseRight.json'],
      ['ThighStretchLeft.json', 'ThighStretchRight.json'],
    ];

    // Define single exercises
    final singleExercises = [
      'BentOverRow.json',
      'CalfRaise.json',
      'LegStraightenUpDown.json',
      'PunchOut.json',
      'RegularSquat.json',
      'RussianTwist.json',
      'WallSit.json',
    ];

    List<Exercise> selectedExercises = [];
    List<String> usedExercisePaths = [];

    // Determine number of pairs and single exercises based on risk
    int pairsCount = _determineNumberOfPairs(
      currentDiagnosis,
      medicalHistory,
      bmi,
      bloodPressure,
    );

    // Select paired exercises
    for (var pair in pairedExercises) {
      if (pairsCount > 0 && pair.every((p) => allowedExercises.contains(p))) {
        selectedExercises.addAll([
          Exercise(
            name: _getExerciseName(pair[0]),
            animationPath: 'assets/animations/${pair[0]}',
            duration: exerciseDuration,
            restTime: restDuration,
            type: ExerciseType.main,
          ),
          Exercise(
            name: _getExerciseName(pair[1]),
            animationPath: 'assets/animations/${pair[1]}',
            duration: exerciseDuration,
            restTime: restDuration,
            type: ExerciseType.main,
          ),
        ]);
        usedExercisePaths.addAll(pair);
        pairsCount--;
      }
    }

    // Fill remaining slots with single exercises
    List<String> availableSingleExercises =
        singleExercises
            .where(
              (ex) =>
                  allowedExercises.contains(ex) &&
                  !usedExercisePaths.contains(ex),
            )
            .toList();

    // Shuffle to randomize selection
    availableSingleExercises.shuffle();

    // Calculate remaining slots to maintain total exercises between 10-13
    int totalExercisesSoFar = selectedExercises.length;
    int remainingSlots = 13 - totalExercisesSoFar;

    // Ensure we have at least 10 exercises
    if (remainingSlots < 10 - totalExercisesSoFar) {
      remainingSlots = 10 - totalExercisesSoFar;
    }

    // Add single exercises
    for (var ex in availableSingleExercises.take(remainingSlots)) {
      selectedExercises.add(
        Exercise(
          name: _getExerciseName(ex),
          animationPath: 'assets/animations/$ex',
          duration: exerciseDuration,
          restTime: restDuration,
          type: ExerciseType.main,
        ),
      );
    }

    return selectedExercises;
  }

  // Helper method to convert filename to exercise name
  static String _getExerciseName(String filename) {
    return filename
        .replaceAll('.json', '')
        .replaceAll('json', '')
        .split(RegExp(r'(?=[A-Z])'))
        .join(' ');
  }

  static int _determineNumberOfPairs(
    String diagnosis,
    String medicalHistory,
    double bmi,
    String bloodPressure,
  ) {
    // Default to 2 pairs for low-risk patients
    int pairs = 2;

    bool isHighRisk = _isHighRisk(
      diagnosis,
      medicalHistory,
      bmi,
      bloodPressure,
    );
    bool isModerateRisk = _isModerateRisk(
      diagnosis,
      medicalHistory,
      bmi,
      bloodPressure,
    );

    if (isHighRisk) {
      pairs = 1; // Reduce paired exercises for high-risk patients
    } else if (isModerateRisk) {
      pairs = 1; // Reduce paired exercises for moderate-risk patients
    }

    return pairs;
  }

  static bool _isHighRisk(
    String diagnosis,
    String medicalHistory,
    double bmi,
    String bloodPressure,
  ) {
    try {
      final bpParts = bloodPressure.split('/');
      int systolic = int.parse(bpParts[0]);
      int diastolic = int.parse(bpParts[1]);

      return diagnosis == 'Heart Failure' ||
          medicalHistory == 'Previous Heart Attack' ||
          systolic >= 160 ||
          diastolic >= 100 ||
          bmi > 35;
    } catch (e) {
      return diagnosis == 'Heart Failure' ||
          medicalHistory == 'Previous Heart Attack' ||
          bmi > 35;
    }
  }

  static bool _isModerateRisk(
    String diagnosis,
    String medicalHistory,
    double bmi,
    String bloodPressure,
  ) {
    try {
      final bpParts = bloodPressure.split('/');
      int systolic = int.parse(bpParts[0]);
      int diastolic = int.parse(bpParts[1]);

      return diagnosis == 'Coronary Artery Disease' ||
          medicalHistory == 'Bypass Surgery' ||
          systolic >= 140 ||
          diastolic >= 90 ||
          bmi > 30;
    } catch (e) {
      return diagnosis == 'Coronary Artery Disease' ||
          medicalHistory == 'Bypass Surgery' ||
          bmi > 30;
    }
  }

  static int _calculateExerciseDuration(
    int age,
    String medicalHistory,
    int restingHeartRate,
    double bmi,
    String bloodPressure,
  ) {
    // Base duration
    int duration = 45;

    // Parse blood pressure
    int systolic = 120; // default value
    int diastolic = 80; // default value
    try {
      final bpParts = bloodPressure.split('/');
      systolic = int.parse(bpParts[0]);
      diastolic = int.parse(bpParts[1]);
    } catch (e) {
      print('Invalid blood pressure format');
    }

    // Adjust based on age
    if (age > 70)
      duration -= 15;
    else if (age > 60)
      duration -= 10;
    else if (age > 50)
      duration -= 5;

    // Adjust based on medical history
    if (medicalHistory == 'Previous Heart Attack') duration -= 10;
    if (medicalHistory == 'Bypass Surgery') duration -= 15;

    // Adjust based on resting heart rate
    if (restingHeartRate > 100)
      duration -= 10;
    else if (restingHeartRate > 90)
      duration -= 5;

    // Adjust based on bmi
    if (bmi > 35) duration -= 10;

    // Adjust based on blood pressure
    if (systolic >= 160 || diastolic >= 100) duration -= 10;

    return duration.clamp(15, 45); // Ensure duration is between 15-45 seconds
  }

  static int _calculateRestDuration(
    int restingHeartRate,
    String medicalHistory,
    double bmi,
    String bloodPressure,
  ) {
    // Base rest duration
    int duration = 30;

    // Parse blood pressure
    int systolic = 120; // default value
    int diastolic = 80; // default value
    try {
      final bpParts = bloodPressure.split('/');
      systolic = int.parse(bpParts[0]);
      diastolic = int.parse(bpParts[1]);
    } catch (e) {
      print('Invalid blood pressure format');
    }

    // Adjust based on resting heart rate
    if (restingHeartRate > 100)
      duration += 15;
    else if (restingHeartRate > 90)
      duration += 10;
    else if (restingHeartRate > 80)
      duration += 5;

    // Adjust based on medical history
    if (medicalHistory == 'Previous Heart Attack') duration += 10;
    if (medicalHistory == 'Bypass Surgery') duration += 15;

    // Adjust based on bmi
    if (bmi > 35) duration += 10;

    // Adjust based on blood pressure
    if (systolic >= 160 || diastolic >= 100) duration += 10;

    return duration.clamp(30, 75); // Ensure rest is between 30-75 seconds
  }
}
