import 'dart:io';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:cardiafit/Model/ExerciseDataModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:cardiafit/DetectionScreen.dart';

import 'main.dart';

class Detectionscreen extends StatefulWidget {
  Detectionscreen({Key? key, required this.exerciseDataModel})
    : super(key: key);
  ExerciseDataModel exerciseDataModel;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<Detectionscreen> {
  dynamic controller;
  bool isBusy = false;
  late Size size;

  //TODO declare detector
  late PoseDetector poseDetector;
  @override
  void initState() {
    super.initState();
    initializeCamera();
  }

  //TODO code to initialize the camera feed
  initializeCamera() async {
    //TODO initialize detector
    final options = PoseDetectorOptions(mode: PoseDetectionMode.stream);
    poseDetector = PoseDetector(options: options);

    controller = CameraController(
      cameras[0],
      ResolutionPreset.medium,
      imageFormatGroup:
          Platform.isAndroid
              ? ImageFormatGroup.nv21
              : ImageFormatGroup.bgra8888,
    );
    await controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      controller.startImageStream(
        (image) => {
          if (!isBusy) {isBusy = true, img = image, doPoseEstimationOnFrame()},
        },
      );
    });
  }

  //TODO pose detection on a frame
  dynamic _scanResults;
  CameraImage? img;
  doPoseEstimationOnFrame() async {
    var inputImage = _inputImageFromCameraImage();
    if (inputImage != null) {
      final List<Pose> poses = await poseDetector.processImage(inputImage!);
      print("pose=" + poses.length.toString());
      _scanResults = poses;
      if (poses.length > 0) {
        if (widget.exerciseDataModel.type == ExerciseType.PushUps) {
          detectPushUp(poses.first.landmarks);
        }else if (widget.exerciseDataModel.type == ExerciseType.Squats){
          detectSquat(poses.first.landmarks);
        }else if (widget.exerciseDataModel.type == ExerciseType.RussianTwist){
          detectRussianTwist(poses.first.landmarks);
        }else if (widget.exerciseDataModel.type == ExerciseType.JumpingJack){
          detectJumpingJack(poses.first);
        }else if (widget.exerciseDataModel.type == ExerciseType.SideLegRaiseLeft) {
          detectSideLegRaiseLeft(poses.first.landmarks);
        }
        else if (widget.exerciseDataModel.type == ExerciseType.SideLegRaiseRight) {
          detectSideLegRaiseRight(poses.first.landmarks);
        }else if (widget.exerciseDataModel.type == ExerciseType.FrontLungeLeft) {
          detectFrontLungeLeft(poses.first.landmarks);
        }else if (widget.exerciseDataModel.type == ExerciseType.FrontLungeRight) {
          detectFrontLungeRight(poses.first.landmarks);
        }else if (widget.exerciseDataModel.type == ExerciseType.LegKickBackRight) {
          detectDonkeyKickRight(poses.first.landmarks);
        }else if (widget.exerciseDataModel.type == ExerciseType.LegKickBackLeft) {
          detectDonkeyKickLeft(poses.first.landmarks);
        }else if (widget.exerciseDataModel.type == ExerciseType.LegStraightenUpDown) {
          detectLyingLegExtend(poses.first.landmarks);
        }else if (widget.exerciseDataModel.type == ExerciseType.ShoulderShrug) {
          detectShoulderShrug(poses.first.landmarks);
        }else if (widget.exerciseDataModel.type == ExerciseType.CalfRaise) {
          detectCalfRaise(poses.first.landmarks);
        }else if (widget.exerciseDataModel.type == ExerciseType.HipSwingRight) {
          detectHipSwing(poses.first.landmarks);
        }else if (widget.exerciseDataModel.type == ExerciseType.HipSwingLeft) {
          detectHipSwingLeft(poses.first.landmarks);
        }else if (widget.exerciseDataModel.type == ExerciseType.HipLift) {
          detectHipLift(poses.first.landmarks);
        }else if (widget.exerciseDataModel.type == ExerciseType.SitUps) {
          detectSitUp(poses.first.landmarks);
        }else if (widget.exerciseDataModel.type == ExerciseType.ReverseCrunches) {
          detectCrunch(poses.first.landmarks);
        }
      }
    }
    setState(() {
      _scanResults;
      isBusy = false;
    });
  }

  //close all resources
  @override
  void dispose() {
    controller?.dispose();
    poseDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> stackChildren = [];
    size = MediaQuery.of(context).size;
    if (controller != null) {
      stackChildren.add(
        Positioned(
          top: 0.0,
          left: 0.0,
          width: size.width,
          height: size.height,
          child: Container(
            child:
                (controller.value.isInitialized)
                    ? AspectRatio(
                      aspectRatio: controller.value.aspectRatio,
                      child: CameraPreview(controller),
                    )
                    : Container(),
          ),
        ),
      );

      stackChildren.add(
        Positioned(
          top: 0.0,
          left: 0.0,
          width: size.width,
          height: size.height,
          child: buildResult(),
        ),
      );

      stackChildren.add(
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            margin: EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: Colors.black,
            ),
            child: Center(
              child: Text(
                widget.exerciseDataModel.type == ExerciseType.PushUps? "$pushUpCount": widget.exerciseDataModel.type == ExerciseType.Squats? "$squatCount": widget.exerciseDataModel.type == ExerciseType.RussianTwist? "$twistCount":widget.exerciseDataModel.type == ExerciseType.SideLegRaiseLeft? "$sideLegRaiseCount" :widget.exerciseDataModel.type == ExerciseType.FrontLungeLeft? "$frontLungeLeftCount":widget.exerciseDataModel.type == ExerciseType.FrontLungeRight? "$frontLungeRightCount":widget.exerciseDataModel.type == ExerciseType.LegKickBackRight? "$donkeyKickRightCount":widget.exerciseDataModel.type == ExerciseType.LegKickBackLeft? "$donkeyKickLeftCount":widget.exerciseDataModel.type == ExerciseType.LegStraightenUpDown? "$legExtendCount":widget.exerciseDataModel.type == ExerciseType.ShoulderShrug? "$shoulderShrugCount":widget.exerciseDataModel.type == ExerciseType.CalfRaise? "$calfRaiseCount":widget.exerciseDataModel.type == ExerciseType.HipSwingRight? "$hipSwingCount":widget.exerciseDataModel.type == ExerciseType.HipSwingLeft? "$hipSwingleftCount":widget.exerciseDataModel.type == ExerciseType.HipLift? "$hipLiftCount":widget.exerciseDataModel.type == ExerciseType.SitUps? "$sitUpCount":widget.exerciseDataModel.type == ExerciseType.ReverseCrunches? "$sitUpCount":"$crunchCount",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),

            width: 70,
            height: 70,
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        margin: const EdgeInsets.only(top: 0),
        color: Colors.black,
        child: Stack(children: stackChildren),
      ),
    );
  }

  // Squats
  int squatCount = 0;
  bool isSquatting = false;
  void detectSquat(Map<PoseLandmarkType, PoseLandmark> landmarks) {
    final leftHip = landmarks[PoseLandmarkType.leftHip];
    final rightHip = landmarks[PoseLandmarkType.rightHip];
    final leftKnee = landmarks[PoseLandmarkType.leftKnee];
    final rightKnee = landmarks[PoseLandmarkType.rightKnee];
    final leftAnkle = landmarks[PoseLandmarkType.leftAnkle];
    final rightAnkle = landmarks[PoseLandmarkType.rightAnkle];
    final leftShoulder = landmarks[PoseLandmarkType.leftShoulder];
    final rightShoulder = landmarks[PoseLandmarkType.rightShoulder];

    if (leftHip == null ||
        rightHip == null ||
        leftKnee == null ||
        rightKnee == null ||
        leftAnkle == null ||
        rightAnkle == null ||
        leftShoulder == null ||
        rightShoulder == null) {
      return; // Skip detection if any key landmark is missing
    }

    // Calculate angles
    double leftKneeAngle = calculateAngle(leftHip, leftKnee, leftAnkle);
    double rightKneeAngle = calculateAngle(rightHip, rightKnee, rightAnkle);
    double avgKneeAngle = (leftKneeAngle + rightKneeAngle) / 2;

    double hipY = (leftHip.y + rightHip.y) / 2;
    double kneeY = (leftKnee.y + rightKnee.y) / 2;

    bool deepSquat = avgKneeAngle < 90; // Ensuring squat is deep enough

    if (deepSquat && hipY > kneeY) {
      if (!isSquatting) {
        isSquatting = true;
      }
    } else if (!deepSquat && isSquatting) {
      squatCount++;
      isSquatting = false;

      // Update UI
      setState(() {});
    }
  }

// Crunches
int crunchCount = 0;
bool isCrunching = false;

void detectCrunch(Map<PoseLandmarkType, PoseLandmark> landmarks) {
  final leftHip = landmarks[PoseLandmarkType.leftHip];
  final rightHip = landmarks[PoseLandmarkType.rightHip];
  final leftShoulder = landmarks[PoseLandmarkType.leftShoulder];
  final rightShoulder = landmarks[PoseLandmarkType.rightShoulder];

  if (leftHip == null || rightHip == null || leftShoulder == null || rightShoulder == null) {
    return; // Skip detection if key landmarks are missing
  }

  // Calculate the average Y-position of hips and shoulders
  double hipY = (leftHip.y + rightHip.y) / 2;
  double shoulderY = (leftShoulder.y + rightShoulder.y) / 2;

  // Detect if shoulders are lifted slightly above a threshold
  bool isUpperBodyUp = shoulderY < hipY - 30; // Adjust for sensitivity

  // Debugging output
  print("Shoulder Y: $shoulderY, Hip Y: $hipY");
  print("Upper Body Up: $isUpperBodyUp");

  if (isUpperBodyUp && !isCrunching) {
    isCrunching = true;
  } else if (!isUpperBodyUp && isCrunching) {
    crunchCount++;
    isCrunching = false;

    setState(() {}); // Update UI

    // Debugging output
    print("Crunch Count: $crunchCount");
  }
}


// SitUps
int sitUpCount = 0;
bool isSittingUp = false;

void detectSitUp(Map<PoseLandmarkType, PoseLandmark> landmarks) {
  final leftHip = landmarks[PoseLandmarkType.leftHip];
  final rightHip = landmarks[PoseLandmarkType.rightHip];
  final leftShoulder = landmarks[PoseLandmarkType.leftShoulder];
  final rightShoulder = landmarks[PoseLandmarkType.rightShoulder];

  if (leftHip == null || rightHip == null || leftShoulder == null || rightShoulder == null) {
    return; // Skip detection if key landmarks are missing
  }

  // Calculate the average Y-position of hips and shoulders
  double hipY = (leftHip.y + rightHip.y) / 2;
  double shoulderY = (leftShoulder.y + rightShoulder.y) / 2;

  // Detect if shoulders are lifted above a threshold
  bool isUpperBodyUp = shoulderY < hipY - 50; // Adjust threshold for sensitivity

  // Debugging output
  print("Shoulder Y: $shoulderY, Hip Y: $hipY");
  print("Upper Body Up: $isUpperBodyUp");

  if (isUpperBodyUp && !isSittingUp) {
    isSittingUp = true;
  } else if (!isUpperBodyUp && isSittingUp) {
    sitUpCount++;
    isSittingUp = false;

    setState(() {}); // Update UI

    // Debugging output
    print("Sit-up Count: $sitUpCount");
  }
}

// Dynamic Hip Lift
int hipLiftCount = 0;
bool isLifting = false;

void detectHipLift(Map<PoseLandmarkType, PoseLandmark> landmarks) {
  final leftHip = landmarks[PoseLandmarkType.leftHip];
  final rightHip = landmarks[PoseLandmarkType.rightHip];
  final leftKnee = landmarks[PoseLandmarkType.leftKnee];
  final rightKnee = landmarks[PoseLandmarkType.rightKnee];
  final leftShoulder = landmarks[PoseLandmarkType.leftShoulder];
  final rightShoulder = landmarks[PoseLandmarkType.rightShoulder];

  if (leftHip == null ||
      rightHip == null ||
      leftKnee == null ||
      rightKnee == null ||
      leftShoulder == null ||
      rightShoulder == null) {
    return; // Skip detection if any key landmark is missing
  }

  // Calculate the average Y-position of hips, shoulders, and knees
  double hipY = (leftHip.y + rightHip.y) / 2;
  double shoulderY = (leftShoulder.y + rightShoulder.y) / 2;
  double kneeY = (leftKnee.y + rightKnee.y) / 2;

  // Detect if hips are lifted above a threshold
  bool hipsLifted = hipY < kneeY - 30; // Adjust threshold for sensitivity

  // Debugging output
  print("Hip Y: $hipY, Knee Y: $kneeY, Shoulder Y: $shoulderY");
  print("Hips Lifted: $hipsLifted");

  if (hipsLifted && !isLifting) {
    isLifting = true;
  } else if (!hipsLifted && isLifting) {
    hipLiftCount++;
    isLifting = false;

    setState(() {}); // Update UI

    // Debugging output
    print("Hip Lift Count: $hipLiftCount");
  }
}


// Hip Swing Left
int hipSwingleftCount = 0;
bool isSwingingRight = false;
bool isSwingingLeft = false;

void detectHipSwingLeft(Map<PoseLandmarkType, PoseLandmark> landmarks) {
  final leftHip = landmarks[PoseLandmarkType.leftHip];
  final leftKnee = landmarks[PoseLandmarkType.leftKnee];
  final leftAnkle = landmarks[PoseLandmarkType.leftAnkle];

  if (leftHip == null || leftKnee == null || leftAnkle == null) {
    return; // Skip detection if any key landmark is missing
  }

  // Get left leg X position relative to hip
  double ankleX = leftAnkle.x;
  double hipX = leftHip.x;
  double kneeX = leftKnee.x;

  // Detect if the ankle swings right or left relative to the hip
  bool swingingRight = ankleX > hipX + 30;  // Threshold for right swing
  bool swingingLeft = ankleX < hipX - 30;   // Threshold for left swing

  // Debugging output
  print("Left Ankle X: $ankleX, Hip X: $hipX");
  print("Swinging Right: $swingingRight, Swinging Left: $swingingLeft");

  if (swingingLeft && !isSwingingLeft) {
    isSwingingLeft = true;
    isSwingingRight = false;
  } else if (swingingRight && isSwingingLeft) {
    isSwingingRight = true;
    isSwingingLeft = false;
    hipSwingCount++; // Count only when the leg moves fully right and left
    setState(() {}); // Update UI

    // Debugging output
    print("Hip Swing Count: $hipSwingCount");
  }
}


// Hip Swing Right
int hipSwingCount = 0;
// bool isSwingingRight = false;
// bool isSwingingLeft = false; Because already variable present in before function

void detectHipSwing(Map<PoseLandmarkType, PoseLandmark> landmarks) {
  final rightHip = landmarks[PoseLandmarkType.rightHip];
  final rightKnee = landmarks[PoseLandmarkType.rightKnee];
  final rightAnkle = landmarks[PoseLandmarkType.rightAnkle];

  if (rightHip == null || rightKnee == null || rightAnkle == null) {
    return; // Skip detection if any key landmark is missing
  }

  // Get right leg X position relative to hip
  double ankleX = rightAnkle.x;
  double hipX = rightHip.x;
  double kneeX = rightKnee.x;

  // Detect if the ankle swings right or left relative to the hip
  bool swingingRight = ankleX > hipX + 30;  // Threshold for right swing
  bool swingingLeft = ankleX < hipX - 30;   // Threshold for left swing

  // Debugging output
  print("Right Ankle X: $ankleX, Hip X: $hipX");
  print("Swinging Right: $swingingRight, Swinging Left: $swingingLeft");

  if (swingingRight && !isSwingingRight) {
    isSwingingRight = true;
    isSwingingLeft = false;
  } else if (swingingLeft && isSwingingRight) {
    isSwingingLeft = true;
    isSwingingRight = false;
    hipSwingCount++; // Count only when the leg moves fully left and right
    setState(() {}); // Update UI

    // Debugging output
    print("Hip Swing Count: $hipSwingCount");
  }
}

// Calf Raise
int calfRaiseCount = 0;
bool isOnToes = false;

void detectCalfRaise(Map<PoseLandmarkType, PoseLandmark> landmarks) {
  final leftAnkle = landmarks[PoseLandmarkType.leftAnkle];
  final rightAnkle = landmarks[PoseLandmarkType.rightAnkle];
  final leftToe = landmarks[PoseLandmarkType.leftFootIndex];
  final rightToe = landmarks[PoseLandmarkType.rightFootIndex];

  if (leftAnkle == null || rightAnkle == null || leftToe == null || rightToe == null) {
    return; // Skip detection if any key landmark is missing
  }

  // Calculate vertical distances between ankle and toe
  double leftAnkleToeDiff = leftAnkle.y - leftToe.y;
  double rightAnkleToeDiff = rightAnkle.y - rightToe.y;

  // Define threshold values based on real-time testing
  bool isRaised = leftAnkleToeDiff > 30 && rightAnkleToeDiff > 30; // Ankles move up
  bool isLowered = leftAnkleToeDiff < 15 && rightAnkleToeDiff < 15; // Ankles return down

  // Debugging output
  print("Left Ankle to Toe: $leftAnkleToeDiff, Right Ankle to Toe: $rightAnkleToeDiff");
  print("Raised: $isRaised, Lowered: $isLowered");

  if (isRaised && !isOnToes) {
    isOnToes = true;
  } else if (isLowered && isOnToes) {
    calfRaiseCount++;
    isOnToes = false;

    // Update UI
    setState(() {});

    // Debugging output
    print("Calf Raise Count: $calfRaiseCount");
  }
}

// Shoulder Shrug
int shoulderShrugCount = 0;
bool isShrugged = false;

void detectShoulderShrug(Map<PoseLandmarkType, PoseLandmark> landmarks) {
  final leftShoulder = landmarks[PoseLandmarkType.leftShoulder];
  final rightShoulder = landmarks[PoseLandmarkType.rightShoulder];
  final leftEar = landmarks[PoseLandmarkType.leftEar];
  final rightEar = landmarks[PoseLandmarkType.rightEar];

  if (leftShoulder == null || rightShoulder == null || leftEar == null || rightEar == null) {
    return; // Skip detection if any key landmark is missing
  }

  // Calculate distances between shoulders and ears
  double leftShoulderToEar = (leftShoulder.y - leftEar.y).abs();
  double rightShoulderToEar = (rightShoulder.y - rightEar.y).abs();

  // Set thresholds (adjust based on testing)
  bool shouldersRaised = leftShoulderToEar < 30 && rightShoulderToEar < 30; // Shoulders move up
  bool shouldersRelaxed = leftShoulderToEar > 50 && rightShoulderToEar > 50; // Shoulders move down

  // Debugging outputs (optional)
  print("Left Shoulder to Ear Distance: $leftShoulderToEar");
  print("Right Shoulder to Ear Distance: $rightShoulderToEar");
  print("Shoulders Raised: $shouldersRaised");
  print("Shoulders Relaxed: $shouldersRelaxed");

  if (shouldersRaised && !isShrugged) {
    isShrugged = true;
  } else if (shouldersRelaxed && isShrugged) {
    shoulderShrugCount++;
    isShrugged = false;

    // Update UI
    setState(() {});

    // Debugging output
    print("Shoulder Shrug Count: $shoulderShrugCount");
  }
}


// Leg Straighten Up Down
int legExtendCount = 0;
bool isLegExtended = false;

void detectLyingLegExtend(Map<PoseLandmarkType, PoseLandmark> landmarks) {
  final leftHip = landmarks[PoseLandmarkType.leftHip];
  final rightHip = landmarks[PoseLandmarkType.rightHip];
  final leftKnee = landmarks[PoseLandmarkType.leftKnee];
  final rightKnee = landmarks[PoseLandmarkType.rightKnee];
  final leftAnkle = landmarks[PoseLandmarkType.leftAnkle];
  final rightAnkle = landmarks[PoseLandmarkType.rightAnkle];

  if (leftHip == null ||
      rightHip == null ||
      leftKnee == null ||
      rightKnee == null ||
      leftAnkle == null ||
      rightAnkle == null) {
    return; // Skip detection if any key landmark is missing
  }

  // Measure the distance between ankles
  double ankleDistance = (leftAnkle.x - rightAnkle.x).abs();

  // Measure the hip width as a reference
  double hipDistance = (leftHip.x - rightHip.x).abs();

  // Define thresholds (adjust based on testing)
  bool legsExtended = ankleDistance > hipDistance * 1.5; // Legs are spread apart
  bool legsClosed = ankleDistance < hipDistance * 1.1;   // Legs are back together

  // Debugging outputs (optional)
  print("Ankle Distance: $ankleDistance");
  print("Hip Distance: $hipDistance");
  print("Legs Extended: $legsExtended");
  print("Legs Closed: $legsClosed");

  if (legsExtended && !isLegExtended) {
    isLegExtended = true;
  } else if (legsClosed && isLegExtended) {
    legExtendCount++;
    isLegExtended = false;

    // Update UI
    setState(() {});

    // Debugging output
    print("Leg Extend Count: $legExtendCount");
  }
}


  // Leg Kick Back Left
  int donkeyKickLeftCount = 0;
bool isKickingLeft = false;

void detectDonkeyKickLeft(Map<PoseLandmarkType, PoseLandmark> landmarks) {
  final leftHip = landmarks[PoseLandmarkType.leftHip];
  final leftKnee = landmarks[PoseLandmarkType.leftKnee];
  final leftAnkle = landmarks[PoseLandmarkType.leftAnkle];

  if (leftHip == null || leftKnee == null || leftAnkle == null) {
    return; // Skip detection if any key landmark is missing
  }

  // Calculate the knee extension angle
  double kneeAngle = calculateAngle(leftHip, leftKnee, leftAnkle);

  // Detect kickback: knee extends past a certain angle
  bool legExtended = kneeAngle > 140; // Adjust based on testing
  bool legReturned = kneeAngle < 100; // Ensures the leg returns

  // Debugging outputs (optional)
  print("Knee Angle: $kneeAngle");
  print("Leg Extended: $legExtended");
  print("Leg Returned: $legReturned");

  if (legExtended && !isKickingLeft) {
    isKickingLeft = true;
  } else if (legReturned && isKickingLeft) {
    donkeyKickLeftCount++;
    isKickingLeft = false;

    // Update UI
    setState(() {});

    // Debugging output
    print("Donkey Kick Left Count: $donkeyKickLeftCount");
  }
}

  int pushUpCount = 0;
  bool isLowered = false;
  void detectPushUp(Map<PoseLandmarkType, PoseLandmark> landmarks) {
    final leftShoulder = landmarks[PoseLandmarkType.leftShoulder];
    final rightShoulder = landmarks[PoseLandmarkType.rightShoulder];
    final leftElbow = landmarks[PoseLandmarkType.leftElbow];
    final rightElbow = landmarks[PoseLandmarkType.rightElbow];
    final leftWrist = landmarks[PoseLandmarkType.leftWrist];
    final rightWrist = landmarks[PoseLandmarkType.rightWrist];
    final leftHip = landmarks[PoseLandmarkType.leftHip];
    final rightHip = landmarks[PoseLandmarkType.rightHip];
    final leftKnee = landmarks[PoseLandmarkType.leftKnee];
    final rightKnee = landmarks[PoseLandmarkType.rightKnee];

    if (leftShoulder == null ||
        rightShoulder == null ||
        leftElbow == null ||
        rightElbow == null ||
        leftWrist == null ||
        rightWrist == null ||
        leftHip == null ||
        rightHip == null) {
      return; // Skip if any landmark is missing
    }

    // Calculate elbow angles
    double leftElbowAngle = calculateAngle(leftShoulder, leftElbow, leftWrist);
    double rightElbowAngle = calculateAngle(
      rightShoulder,
      rightElbow,
      rightWrist,
    );
    double avgElbowAngle = (leftElbowAngle + rightElbowAngle) / 2;

    // Calculate torso alignment (ensuring a straight plank)
    double torsoAngle = calculateAngle(
      leftShoulder,
      leftHip,
      leftKnee ?? rightKnee!,
    );
    bool inPlankPosition =
        torsoAngle > 160 && torsoAngle < 180; // Slight flexibility

    if (avgElbowAngle < 90 && inPlankPosition) {
      // User is in the lowered push-up position
      isLowered = true;
    } else if (avgElbowAngle > 160 && isLowered && inPlankPosition) {
      // User returns to the starting position
      pushUpCount++;
      isLowered = false;

      // Update UI
      setState(() {});
    }
  }

  
// Leg Kick Back Right
int donkeyKickRightCount = 0;
bool isKickingRight = false;

void detectDonkeyKickRight(Map<PoseLandmarkType, PoseLandmark> landmarks) {
  final rightHip = landmarks[PoseLandmarkType.rightHip];
  final rightKnee = landmarks[PoseLandmarkType.rightKnee];
  final rightAnkle = landmarks[PoseLandmarkType.rightAnkle];

  if (rightHip == null || rightKnee == null || rightAnkle == null) {
    return; // Skip detection if any key landmark is missing
  }

  // Calculate the knee extension angle
  double kneeAngle = calculateAngle(rightHip, rightKnee, rightAnkle);

  // Detect kickback: knee extends past a certain angle
  bool legExtended = kneeAngle > 140; // Adjust based on testing
  bool legReturned = kneeAngle < 100; // Ensures the leg returns

  // Debugging outputs (optional)
  print("Knee Angle: $kneeAngle");
  print("Leg Extended: $legExtended");
  print("Leg Returned: $legReturned");

  if (legExtended && !isKickingRight) {
    isKickingRight = true;
  } else if (legReturned && isKickingRight) {
    donkeyKickRightCount++;
    isKickingRight = false;

    // Update UI
    setState(() {});

    // Debugging output
    print("Donkey Kick Right Count: $donkeyKickRightCount");
  }
}

//Front Lunge Right
int frontLungeRightCount = 0;
bool isLungingRight = false;

void detectFrontLungeRight(Map<PoseLandmarkType, PoseLandmark> landmarks) {
  final leftHip = landmarks[PoseLandmarkType.leftHip];
  final rightHip = landmarks[PoseLandmarkType.rightHip];
  final leftKnee = landmarks[PoseLandmarkType.leftKnee];
  final rightKnee = landmarks[PoseLandmarkType.rightKnee];
  final leftAnkle = landmarks[PoseLandmarkType.leftAnkle];
  final rightAnkle = landmarks[PoseLandmarkType.rightAnkle];

  if (leftHip == null || rightHip == null || leftKnee == null || rightKnee == null || leftAnkle == null || rightAnkle == null) {
    return; // Skip detection if any key landmark is missing
  }

  // Calculate angles
  double rightKneeAngle = calculateAngle(rightHip, rightKnee, rightAnkle);
  double leftKneeAngle = calculateAngle(leftHip, leftKnee, leftAnkle);

  // Detect step forward (right ankle moves ahead of left ankle)
  bool steppedForward = rightAnkle.x < leftAnkle.x;

  // Detect lunge depth
  bool deepLunge = rightKneeAngle < 100 && leftKneeAngle < 130; // Adjust angles based on testing

  // Debugging outputs (optional)
  print("Right Knee Angle: $rightKneeAngle");
  print("Left Knee Angle: $leftKneeAngle");
  print("Stepped Forward: $steppedForward");
  print("Deep Lunge: $deepLunge");

  if (steppedForward && deepLunge && !isLungingRight) {
    isLungingRight = true;
  } else if (!deepLunge && isLungingRight) {
    frontLungeRightCount++;
    isLungingRight = false;

    // Update UI
    setState(() {});

    // Debugging output
    print("Front Lunge Right Count: $frontLungeRightCount");
  }
}

// Front lunge left
int frontLungeLeftCount = 0;
bool isLungingLeft = false;

void detectFrontLungeLeft(Map<PoseLandmarkType, PoseLandmark> landmarks) {
  final leftHip = landmarks[PoseLandmarkType.leftHip];
  final rightHip = landmarks[PoseLandmarkType.rightHip];
  final leftKnee = landmarks[PoseLandmarkType.leftKnee];
  final rightKnee = landmarks[PoseLandmarkType.rightKnee];
  final leftAnkle = landmarks[PoseLandmarkType.leftAnkle];
  final rightAnkle = landmarks[PoseLandmarkType.rightAnkle];

  if (leftHip == null || rightHip == null || leftKnee == null || rightKnee == null || leftAnkle == null || rightAnkle == null) {
    return; // Skip detection if any key landmark is missing
  }

  // Calculate angles
  double leftKneeAngle = calculateAngle(leftHip, leftKnee, leftAnkle);
  double rightKneeAngle = calculateAngle(rightHip, rightKnee, rightAnkle);

  // Detect step forward (left ankle moves ahead of right ankle)
  bool steppedForward = leftAnkle.x < rightAnkle.x;

  // Detect lunge depth
  bool deepLunge = leftKneeAngle < 100 && rightKneeAngle < 130; // Adjust angles based on testing

  // Debugging outputs (optional)
  print("Left Knee Angle: $leftKneeAngle");
  print("Right Knee Angle: $rightKneeAngle");
  print("Stepped Forward: $steppedForward");
  print("Deep Lunge: $deepLunge");

  if (steppedForward && deepLunge && !isLungingLeft) {
    isLungingLeft = true;
  } else if (!deepLunge && isLungingLeft) {
    frontLungeLeftCount++;
    isLungingLeft = false;

    // Update UI
    setState(() {});

    // Debugging output
    print("Front Lunge Left Count: $frontLungeLeftCount");
  }
}


int twistCount = 0;
bool isTwistingLeft = false;
bool isTwistingRight = false;

void detectRussianTwist(Map<PoseLandmarkType, PoseLandmark> landmarks) {
  final leftHip = landmarks[PoseLandmarkType.leftHip];
  final rightHip = landmarks[PoseLandmarkType.rightHip];
  final leftShoulder = landmarks[PoseLandmarkType.leftShoulder];
  final rightShoulder = landmarks[PoseLandmarkType.rightShoulder];
  final leftHand = landmarks[PoseLandmarkType.leftWrist];
  final rightHand = landmarks[PoseLandmarkType.rightWrist];

  if (leftHip == null ||
      rightHip == null ||
      leftShoulder == null ||
      rightShoulder == null ||
      leftHand == null ||
      rightHand == null) {
    return; // Skip detection if any key landmark is missing
  }

  // Calculate torso rotation angle (shoulder alignment relative to hips)
  double shoulderTwistAngle = calculateAngle(leftShoulder, rightShoulder, rightHip);

  // Calculate horizontal hand movement across the body midline
  double bodyMidX = (leftHip.x + rightHip.x) / 2; 
  bool handCrossesLeft = rightHand.x < bodyMidX; 
  bool handCrossesRight = leftHand.x > bodyMidX; 

  // Adjusted thresholds for low mobility individuals
  bool twistLeft = shoulderTwistAngle > 15 || handCrossesLeft;  
  bool twistRight = shoulderTwistAngle < -15 || handCrossesRight;  

  if (twistLeft && !isTwistingLeft) {
    isTwistingLeft = true;
  } else if (twistRight && isTwistingLeft) {
    twistCount++;
    isTwistingLeft = false;
    isTwistingRight = false;
    setState(() {}); // Update UI
  }

  if (twistRight && !isTwistingRight) {
    isTwistingRight = true;
  } else if (twistLeft && isTwistingRight) {
    twistCount++;
    isTwistingRight = false;
    isTwistingLeft = false;
    setState(() {}); // Update UI
  }
}


  int jumpingJackCount = 0;
  bool isJumping = false;
  bool isJumpingJackOpen = false;
  void detectJumpingJack(Pose pose) {
    final leftAnkle = pose.landmarks[PoseLandmarkType.leftAnkle];
    final rightAnkle = pose.landmarks[PoseLandmarkType.rightAnkle];
    final leftHip = pose.landmarks[PoseLandmarkType.leftHip];
    final rightHip = pose.landmarks[PoseLandmarkType.rightHip];
    final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
    final leftWrist = pose.landmarks[PoseLandmarkType.leftWrist];
    final rightWrist = pose.landmarks[PoseLandmarkType.rightWrist];

    if (leftAnkle == null ||
        rightAnkle == null ||
        leftHip == null ||
        rightHip == null ||
        leftShoulder == null ||
        rightShoulder == null ||
        leftWrist == null ||
        rightWrist == null) {
      return; // Skip detection if any landmark is missing
    }

    // Calculate distances
    double legSpread = (rightAnkle.x - leftAnkle.x).abs();
    double armHeight = (leftWrist.y + rightWrist.y) / 2; // Average wrist height
    double hipHeight = (leftHip.y + rightHip.y) / 2; // Average hip height
    double shoulderWidth = (rightShoulder.x - leftShoulder.x).abs();

    // Define thresholds based on shoulder width
    double legThreshold =
        shoulderWidth * 1.2; // Legs should be ~1.2x shoulder width apart
    double armThreshold =
        hipHeight - shoulderWidth * 0.5; // Arms should be above shoulders

    // Check if arms are raised and legs are spread
    bool armsUp = armHeight < armThreshold;
    bool legsApart = legSpread > legThreshold;

    // Detect full jumping jack cycle
    if (armsUp && legsApart && !isJumpingJackOpen) {
      isJumpingJackOpen = true;
    } else if (!armsUp && !legsApart && isJumpingJackOpen) {
      jumpingJackCount++;
      isJumpingJackOpen = false;

      // Print the count
      print("Jumping Jack Count: $jumpingJackCount");
    }
  }

  // Side leg raise left
int sideLegRaiseCount = 0;
bool isLegRaised = false;

void detectSideLegRaiseLeft(Map<PoseLandmarkType, PoseLandmark> landmarks) {
  final leftHip = landmarks[PoseLandmarkType.leftHip];
  final leftKnee = landmarks[PoseLandmarkType.leftKnee];
  final leftAnkle = landmarks[PoseLandmarkType.leftAnkle];
  final rightAnkle = landmarks[PoseLandmarkType.rightAnkle]; // Reference point

  if (leftHip == null || leftKnee == null || leftAnkle == null || rightAnkle == null) {
    return; // Skip detection if any key landmark is missing
  }

  // Calculate leg raise angle (hip-knee-ankle)
  double legRaiseAngle = calculateAngle(leftHip, leftKnee, leftAnkle);

  // Calculate vertical distance between left and right ankle
  double ankleLift = leftAnkle.y - rightAnkle.y; // Negative = lifted

  // Adjusted thresholds for low mobility users
  bool isRaised = legRaiseAngle > 25 || ankleLift < -15; // At least 25° or visibly raised

  // Debugging outputs (optional)
  print("Leg Raise Angle: $legRaiseAngle");
  print("Ankle Lift Distance: $ankleLift");
  print("Leg Raised: $isRaised");

  if (isRaised && !isLegRaised) {
    isLegRaised = true;
  } else if (!isRaised && isLegRaised) {
    sideLegRaiseCount++;
    isLegRaised = false;

    // Update UI
    setState(() {});
    
    // Debugging output
    print("Side Leg Raise Count: $sideLegRaiseCount");
  }
}

// Side leg raise right
int sideLegRaiseRightCount = 0;
bool isRightLegRaised = false;

void detectSideLegRaiseRight(Map<PoseLandmarkType, PoseLandmark> landmarks) {
  final rightHip = landmarks[PoseLandmarkType.rightHip];
  final rightKnee = landmarks[PoseLandmarkType.rightKnee];
  final rightAnkle = landmarks[PoseLandmarkType.rightAnkle];
  final leftAnkle = landmarks[PoseLandmarkType.leftAnkle]; // Reference point

  if (rightHip == null || rightKnee == null || rightAnkle == null || leftAnkle == null) {
    return; // Skip detection if any key landmark is missing
  }

  // Calculate leg raise angle (hip-knee-ankle)
  double legRaiseAngle = calculateAngle(rightHip, rightKnee, rightAnkle);

  // Calculate vertical distance between right and left ankle
  double ankleLift = rightAnkle.y - leftAnkle.y; // Negative = lifted

  // Adjusted thresholds for low mobility users
  bool isRaised = legRaiseAngle > 25 || ankleLift < -15; // At least 25° or visibly raised

  // Debugging outputs (optional)
  print("Right Leg Raise Angle: $legRaiseAngle");
  print("Ankle Lift Distance: $ankleLift");
  print("Right Leg Raised: $isRaised");

  if (isRaised && !isRightLegRaised) {
    isRightLegRaised = true;
  } else if (!isRaised && isRightLegRaised) {
    sideLegRaiseRightCount++;
    isRightLegRaised = false;

    // Update UI
    setState(() {});

    // Debugging output
    print("Side Leg Raise Right Count: $sideLegRaiseRightCount");
  }
}



  // Function to calculate angle between three points (shoulder, elbow, wrist)
  double calculateAngle(
    PoseLandmark shoulder,
    PoseLandmark elbow,
    PoseLandmark wrist,
  ) {
    double a = distance(elbow, wrist);
    double b = distance(shoulder, elbow);
    double c = distance(shoulder, wrist);

    double angle = acos((b * b + a * a - c * c) / (2 * b * a)) * (180 / pi);
    return angle;
  }

  // Helper function to calculate Euclidean distance
  double distance(PoseLandmark p1, PoseLandmark p2) {
    return sqrt(pow(p1.x - p2.x, 2) + pow(p1.y - p2.y, 2));
  }

  final _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };
  InputImage? _inputImageFromCameraImage() {
    // get image rotation
    // it is used in android to convert the InputImage from Dart to Java
    // `rotation` is not used in iOS to convert the InputImage from Dart to Obj-C
    // in both platforms `rotation` and `camera.lensDirection` can be used to compensate `x` and `y` coordinates on a canvas
    final camera = cameras[0];
    final sensorOrientation = camera.sensorOrientation;
    InputImageRotation? rotation;
    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (Platform.isAndroid) {
      var rotationCompensation =
          _orientations[controller!.value.deviceOrientation];
      if (rotationCompensation == null) return null;
      if (camera.lensDirection == CameraLensDirection.front) {
        // front-facing
        rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
      } else {
        // back-facing
        rotationCompensation =
            (sensorOrientation - rotationCompensation + 360) % 360;
      }
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
    }
    if (rotation == null) return null;

    // get image format
    final format = InputImageFormatValue.fromRawValue(img!.format.raw);
    // validate format depending on platform
    // only supported formats:
    // * nv21 for Android
    // * bgra8888 for iOS
    if (format == null ||
        (Platform.isAndroid && format != InputImageFormat.nv21) ||
        (Platform.isIOS && format != InputImageFormat.bgra8888))
      return null;

    // since format is constraint to nv21 or bgra8888, both only have one plane
    if (img!.planes.length != 1) return null;
    final plane = img!.planes.first;

    // compose InputImage using bytes
    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(img!.width.toDouble(), img!.height.toDouble()),
        rotation: rotation, // used only in Android
        format: format, // used only in iOS
        bytesPerRow: plane.bytesPerRow, // used only in iOS
      ),
    );
  }

  //Show rectangles around detected objects
  Widget buildResult() {
    if (_scanResults == null ||
        controller == null ||
        !controller.value.isInitialized) {
      return Text('');
    }
    final Size imageSize = Size(
      controller.value.previewSize!.height,
      controller.value.previewSize!.width,
    );
    CustomPainter painter = PosePainter(imageSize, _scanResults);
    return CustomPaint(painter: painter);
  }
}
