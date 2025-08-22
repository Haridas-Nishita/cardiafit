import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:cardiafit/ExerciselistScreen.dart' as main_exercises;
import 'package:cardiafit/onboarding_screen.dart';
import 'package:cardiafit/Warmup_exercise_list.dart' as warmup;
import 'package:cardiafit/warmup_animation_screen.dart';
import 'package:cardiafit/coolDown_exercise_list.dart' as cooldown;
import 'package:cardiafit/coolDown_animation_screen.dart';
import 'package:cardiafit/splash_screen.dart';
import 'package:cardiafit/about_screen.dart';
import 'package:cardiafit/Model/ExerciseDataModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:flutter_svg/flutter_svg.dart';

late List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/onboarding': (context) => OnboardingScreen(),
        '/about': (context) => AboutScreen(),
        '/warmup':
            (context) => warmup.WarmupExerciseList(
              userParams:
                  ModalRoute.of(context)!.settings.arguments
                      as Map<String, dynamic>,
            ),
        '/warmup-animation': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>;
          return WarmupAnimationScreen(
            exercises: args['exercises'] as List<ExerciseDataModel>,
            userParams: args['userParams'] as Map<String, dynamic>,
          );
        },
        '/cooldown':
            (context) => cooldown.CoolDownExerciseList(
              userParams:
                  ModalRoute.of(context)!.settings.arguments
                      as Map<String, dynamic>,
            ),
        '/cooldown-animation': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>;
          return CoolDownAnimationScreen(
            exercises: args['exercises'] as List<ExerciseDataModel>,
            userParams: args['userParams'] as Map<String, dynamic>,
          );
        },
        '/workout-plan':
            (context) => main_exercises.ExerciseListingScreen(
              userParams:
                  ModalRoute.of(context)!.settings.arguments
                      as Map<String, dynamic>,
            ),
      },
      theme: ThemeData(
        primaryColor: Color(0xFF3B1E54),
        colorScheme: ColorScheme.light(
          primary: Color(0xFF3B1E54),
          secondary: Color(0xFF9B7EBD),
          background: Color(0xFFF7EFE5),
        ),
      ),
    );
  }
}

class PosePainter extends CustomPainter {
  PosePainter(this.absoluteImageSize, this.poses);

  final Size absoluteImageSize;
  final List<Pose> poses;

  @override
  void paint(Canvas canvas, Size size) {
    final double scaleX = size.width / absoluteImageSize.width;
    final double scaleY = size.height / absoluteImageSize.height;

    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4.0
          ..color = Colors.green;

    final leftPaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0
          ..color = Colors.yellow;

    final rightPaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0
          ..color = Colors.blueAccent;

    for (final pose in poses) {
      pose.landmarks.forEach((_, landmark) {
        canvas.drawCircle(
          Offset(landmark.x * scaleX, landmark.y * scaleY),
          1,
          paint,
        );
      });

      void paintLine(
        PoseLandmarkType type1,
        PoseLandmarkType type2,
        Paint paintType,
      ) {
        final PoseLandmark joint1 = pose.landmarks[type1]!;
        final PoseLandmark joint2 = pose.landmarks[type2]!;
        canvas.drawLine(
          Offset(joint1.x * scaleX, joint1.y * scaleY),
          Offset(joint2.x * scaleX, joint2.y * scaleY),
          paintType,
        );
      }

      //Draw arms
      paintLine(
        PoseLandmarkType.leftShoulder,
        PoseLandmarkType.leftElbow,
        leftPaint,
      );
      paintLine(
        PoseLandmarkType.leftElbow,
        PoseLandmarkType.leftWrist,
        leftPaint,
      );
      paintLine(
        PoseLandmarkType.rightShoulder,
        PoseLandmarkType.rightElbow,
        rightPaint,
      );
      paintLine(
        PoseLandmarkType.rightElbow,
        PoseLandmarkType.rightWrist,
        rightPaint,
      );

      //Draw Body
      paintLine(
        PoseLandmarkType.leftShoulder,
        PoseLandmarkType.leftHip,
        leftPaint,
      );
      paintLine(
        PoseLandmarkType.rightShoulder,
        PoseLandmarkType.rightHip,
        rightPaint,
      );

      //Draw legs
      paintLine(PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee, leftPaint);
      paintLine(
        PoseLandmarkType.leftKnee,
        PoseLandmarkType.leftAnkle,
        leftPaint,
      );
      paintLine(
        PoseLandmarkType.rightHip,
        PoseLandmarkType.rightKnee,
        rightPaint,
      );
      paintLine(
        PoseLandmarkType.rightKnee,
        PoseLandmarkType.rightAnkle,
        rightPaint,
      );
    }
  }

  @override
  bool shouldRepaint(PosePainter oldDelegate) {
    return oldDelegate.absoluteImageSize != absoluteImageSize ||
        oldDelegate.poses != poses;
  }
}
