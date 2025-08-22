import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

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
      home: MyHomePage(
        title: 'Warrior Pose Detection',
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  dynamic controller;
  bool isBusy = false;
  late Size size;
  late PoseDetector poseDetector;
  dynamic _scanResults;
  CameraImage? img;
  
  // Warrior pose tracking variables
  bool isWarriorPose = false;
  Color statusColor = Colors.red;
  int warriorPoseDuration = 0;
  DateTime? warriorPoseStartTime;

  @override
  void initState() {
    super.initState();
    initializeCamera();
  }

  initializeCamera() async {
    final options = PoseDetectorOptions(mode: PoseDetectionMode.stream);
    poseDetector = PoseDetector(options: options);
    
    controller = CameraController(cameras[0], ResolutionPreset.medium,
      imageFormatGroup: Platform.isAndroid
        ? ImageFormatGroup.nv21
        : ImageFormatGroup.bgra8888,
    );
    await controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      controller.startImageStream((image) => {
        if (!isBusy)
          {isBusy = true, img = image, doPoseEstimationOnFrame()}
      });
    });
  }

  doPoseEstimationOnFrame() async {
    var inputImage = _inputImageFromCameraImage();
    if(inputImage != null){
      final List<Pose> poses = await poseDetector.processImage(inputImage);
      _scanResults = poses;
      if(poses.isNotEmpty) {
        detectWarriorPose(poses.first.landmarks);
      }
    }
    setState(() {
      isBusy = false;
    });
  }

  void detectWarriorPose(Map<PoseLandmarkType, PoseLandmark> landmarks) {
  final rightHip = landmarks[PoseLandmarkType.rightHip];
  final rightKnee = landmarks[PoseLandmarkType.rightKnee];
  final rightAnkle = landmarks[PoseLandmarkType.rightAnkle];
  final leftHip = landmarks[PoseLandmarkType.leftHip];
  final leftKnee = landmarks[PoseLandmarkType.leftKnee];
  final leftAnkle = landmarks[PoseLandmarkType.leftAnkle];

  if ([rightHip, rightKnee, rightAnkle, leftHip, leftKnee, leftAnkle].contains(null)) {
    return;
  }

  // Calculate angles with more flexibility for low mobility users
  double frontKneeAngle = calculateAngle(rightHip!, rightKnee!, rightAnkle!);
  double backLegAngle = calculateAngle(leftHip!, leftKnee!, leftAnkle!);

  // Adjusted angle thresholds for low mobility
  bool correctFrontKnee = frontKneeAngle >= 60 && frontKneeAngle <= 120;
  bool correctBackLeg = backLegAngle >= 140;

  // Determine warrior pose status
  if (correctFrontKnee && correctBackLeg) {
    if (!isWarriorPose) {
      warriorPoseStartTime = DateTime.now();
    }
    isWarriorPose = true;
    statusColor = Colors.green;

    // Calculate warrior pose duration
    if (warriorPoseStartTime != null) {
      warriorPoseDuration = DateTime.now().difference(warriorPoseStartTime!).inSeconds;
    }
  } else {
    isWarriorPose = false;
    statusColor = Colors.red;
    warriorPoseStartTime = null;
    warriorPoseDuration = 0;
  }
  setState(() {});
}

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
      // Camera preview
      stackChildren.add(
        Positioned(
          top: 0.0,
          left: 0.0,
          width: size.width,
          height: size.height,
          child: Container(
            child: (controller.value.isInitialized)
                ? AspectRatio(
              aspectRatio: controller.value.aspectRatio,
              child: CameraPreview(controller),
            )
                : Container(),
          ),
        ),
      );

      // Pose landmarks overlay
      stackChildren.add(
        Positioned(
          top: 0.0,
          left: 0.0,
          width: size.width,
          height: size.height,
          child: buildResult()
        ),
      );

      // Warrior pose status and duration
      stackChildren.add(
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            margin: EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50), 
              color: statusColor,
            ),
            width: 250,
            height: 70,
            child: Center(
              child: Text(
                isWarriorPose 
                  ? "Warrior Pose: $warriorPoseDuration sec" 
                  : "Adjust Warrior Pose\n(Right Foot Forward)",
                style: TextStyle(
                  color: Colors.white, 
                  fontSize: 16,
                  fontWeight: FontWeight.bold
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        margin: const EdgeInsets.only(top: 0),
        color: Colors.black,
        child: Stack(
          children: stackChildren,
        )
      ),
    );
  }

  // Angle calculation helper
  double calculateAngle(
    PoseLandmark first, PoseLandmark mid, PoseLandmark last) {
    // Calculate vectors
    double x1 = first.x - mid.x;
    double y1 = first.y - mid.y;
    double x2 = last.x - mid.x;
    double y2 = last.y - mid.y;

    // Calculate dot product
    double dotProduct = x1 * x2 + y1 * y2;

    // Calculate magnitudes
    double mag1 = sqrt(x1 * x1 + y1 * y1);
    double mag2 = sqrt(x2 * x2 + y2 * y2);

    // Prevent division by zero
    if (mag1 == 0 || mag2 == 0) return 0;

    // Calculate cosine of angle
    double cosAngle = dotProduct / (mag1 * mag2);
    
    // Clamp cosine value to prevent math domain errors
    cosAngle = cosAngle.clamp(-1.0, 1.0);

    // Convert to degrees
    return acos(cosAngle) * (180 / pi);
  }

  // Input image conversion for pose detection
  InputImage? _inputImageFromCameraImage() {
    final camera = cameras[0];
    final sensorOrientation = camera.sensorOrientation;
    InputImageRotation? rotation;
    
    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (Platform.isAndroid) {
      var rotationCompensation = _orientations[controller!.value.deviceOrientation];
      if (rotationCompensation == null) return null;
      
      if (camera.lensDirection == CameraLensDirection.front) {
        rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
      } else {
        rotationCompensation = (sensorOrientation - rotationCompensation + 360) % 360;
      }
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
    }
    
    if (rotation == null) return null;

    final format = InputImageFormatValue.fromRawValue(img!.format.raw);
    if (format == null ||
        (Platform.isAndroid && format != InputImageFormat.nv21) ||
        (Platform.isIOS && format != InputImageFormat.bgra8888)) return null;

    if (img!.planes.length != 1) return null;
    final plane = img!.planes.first;

    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(img!.width.toDouble(), img!.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  // Orientation mapping
  final _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  // Pose landmarks painting
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
    return CustomPaint(
      painter: painter,
    );
  }
}

// Custom painter for pose landmarks
class PosePainter extends CustomPainter {
  PosePainter(this.absoluteImageSize, this.poses);

  final Size absoluteImageSize;
  final List<Pose> poses;

  @override
  void paint(Canvas canvas, Size size) {
    final double scaleX = size.width / absoluteImageSize.width;
    final double scaleY = size.height / absoluteImageSize.height;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..color = Colors.green;

    final leftPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.yellow;

    final rightPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.blueAccent;

    for (final pose in poses) {
      pose.landmarks.forEach((_, landmark) {
        canvas.drawCircle(
            Offset(landmark.x * scaleX, landmark.y * scaleY), 1, paint);
      });

      void paintLine(
          PoseLandmarkType type1, PoseLandmarkType type2, Paint paintType) {
        final PoseLandmark joint1 = pose.landmarks[type1]!;
        final PoseLandmark joint2 = pose.landmarks[type2]!;
        canvas.drawLine(Offset(joint1.x * scaleX, joint1.y * scaleY),
            Offset(joint2.x * scaleX, joint2.y * scaleY), paintType);
      }

      // Draw pose skeleton
      paintLine(PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow, leftPaint);
      paintLine(PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist, leftPaint);
      paintLine(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow, rightPaint);
      paintLine(PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist, rightPaint);
      paintLine(PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip, leftPaint);
      paintLine(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip, rightPaint);
      paintLine(PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee, leftPaint);
      paintLine(PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle, leftPaint);
      paintLine(PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee, rightPaint);
      paintLine(PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle, rightPaint);
    }
  }

  @override
  bool shouldRepaint(PosePainter oldDelegate) {
    return oldDelegate.absoluteImageSize != absoluteImageSize ||
        oldDelegate.poses != poses;
  }
}
