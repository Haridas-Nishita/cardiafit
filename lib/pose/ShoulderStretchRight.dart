import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
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
      home: MyHomePage(title: 'Shoulder Stretch Detection'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late CameraController controller;
  bool isBusy = false;
  late PoseDetector poseDetector;
  CameraImage? img;
  List<Pose>? _scanResults;
  bool isStretching = false;
  String feedbackText = "Perform the stretch";
  Color feedbackColor = Colors.red;
  int stretchDuration = 0;
  DateTime? stretchStartTime;

  @override
  void initState() {
    super.initState();
    initializeCamera();
  }

  void initializeCamera() async {
    final options = PoseDetectorOptions(mode: PoseDetectionMode.stream);
    poseDetector = PoseDetector(options: options);

    controller = CameraController(cameras[0], ResolutionPreset.medium,
        imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.nv21
            : ImageFormatGroup.bgra8888);

    await controller.initialize().then((_) {
      if (!mounted) return;
      controller.startImageStream((image) {
        if (!isBusy) {
          isBusy = true;
          img = image;
          doPoseEstimationOnFrame();
        }
      });
    });
  }

  void doPoseEstimationOnFrame() async {
    var inputImage = _inputImageFromCameraImage();
    if (inputImage != null) {
      final List<Pose> poses = await poseDetector.processImage(inputImage);
      _scanResults = poses;
      if (poses.isNotEmpty) {
        detectShoulderStretch(poses.first.landmarks);
      }
    }
    setState(() {
      isBusy = false;
    });
  }

  void detectShoulderStretch(Map<PoseLandmarkType, PoseLandmark> landmarks) {
    final leftShoulder = landmarks[PoseLandmarkType.leftShoulder];
    final rightShoulder = landmarks[PoseLandmarkType.rightShoulder];
    final leftElbow = landmarks[PoseLandmarkType.leftElbow];
    final rightElbow = landmarks[PoseLandmarkType.rightElbow];
    final leftWrist = landmarks[PoseLandmarkType.leftWrist];
    final rightWrist = landmarks[PoseLandmarkType.rightWrist];

    if ([leftShoulder, rightShoulder, leftElbow, rightElbow, leftWrist, rightWrist]
        .contains(null)) {
      return;
    }

    // Detect cross-chest shoulder stretch
    bool isRightArmStretch = detectCrossChestStretch(
      shoulderLandmark: rightShoulder!, 
      elbowLandmark: rightElbow!, 
      wristLandmark: rightWrist!, 
      assistHandLandmark: leftWrist!
    );

    bool isLeftArmStretch = detectCrossChestStretch(
      shoulderLandmark: leftShoulder!, 
      elbowLandmark: leftElbow!, 
      wristLandmark: leftWrist!, 
      assistHandLandmark: rightWrist!
    );

    if (isRightArmStretch || isLeftArmStretch) {
      if (!isStretching) {
        stretchStartTime = DateTime.now();
      }
      isStretching = true;
      feedbackText = "Stretch is Correct!\nHold Position";
      feedbackColor = Colors.green;

      // Calculate stretch duration
      if (stretchStartTime != null) {
        stretchDuration = DateTime.now().difference(stretchStartTime!).inSeconds;
      }
    } else {
      feedbackText = "Adjust your posture!\nExtend arm across chest";
      feedbackColor = Colors.red;
      isStretching = false;
      stretchStartTime = null;
      stretchDuration = 0;
    }

    setState(() {});
  }

  bool detectCrossChestStretch({
    required PoseLandmark shoulderLandmark,
    required PoseLandmark elbowLandmark,
    required PoseLandmark wristLandmark,
    required PoseLandmark assistHandLandmark
  }) {
    // Check arm extension angle
    double armAngle = calculateAngle(shoulderLandmark, elbowLandmark, wristLandmark);
    bool armExtended = armAngle > 120; // Arm close to straight

    // Check assist hand proximity to elbow
    double handDistance = distance(assistHandLandmark, elbowLandmark);
    bool assistHandNearElbow = handDistance < 80; // Increased from 50 to 80
    bool correctHandPosition = (assistHandLandmark.x - elbowLandmark.x).abs() < 80; // More range


    return armExtended && assistHandNearElbow && correctHandPosition;
  }

  double calculateAngle(PoseLandmark first, PoseLandmark mid, PoseLandmark last) {
    double x1 = first.x - mid.x;
    double y1 = first.y - mid.y;
    double x2 = last.x - mid.x;
    double y2 = last.y - mid.y;

    double dotProduct = x1 * x2 + y1 * y2;
    double mag1 = sqrt(x1 * x1 + y1 * y1);
    double mag2 = sqrt(x2 * x2 + y2 * y2);

    if (mag1 == 0 || mag2 == 0) return 0;

    double cosAngle = dotProduct / (mag1 * mag2);
    cosAngle = cosAngle.clamp(-1.0, 1.0);

    return acos(cosAngle) * (180 / pi);
  }

  double distance(PoseLandmark p1, PoseLandmark p2) {
    return sqrt(pow(p1.x - p2.x, 2) + pow(p1.y - p2.y, 2));
  }

  InputImage? _inputImageFromCameraImage() {
    if (img == null || controller == null) return null;

    final camera = cameras[0];
    final sensorOrientation = camera.sensorOrientation;
    InputImageRotation? rotation;
    
    if (Platform.isIOS) {
      rotation = InputImageRotation.rotation90deg;
    } else if (Platform.isAndroid) {
      rotation = InputImageRotation.rotation90deg;
    }
    
    if (rotation == null) return null;

    final format = InputImageFormat.nv21;

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

  @override
  void dispose() {
    controller.dispose();
    poseDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> stackChildren = [];
    final size = MediaQuery.of(context).size;

    if (controller != null) {
      // Camera Preview
      stackChildren.add(Positioned(
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
      ));

      // Pose Landmarks Overlay
      stackChildren.add(Positioned(
        top: 0.0,
        left: 0.0,
        width: size.width,
        height: size.height,
        child: buildResult(),
      ));

      // Stretch Feedback Container
      stackChildren.add(
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            margin: EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: feedbackColor,
            ),
            width: 250,
            height: 80,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    feedbackText,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (isStretching)
                    Text(
                      'Duration: $stretchDuration sec',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                ],
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
        ),
      ),
    );
  }

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
    CustomPainter painter = PosePainter(imageSize, _scanResults!);
    return CustomPaint(painter: painter);
  }
}

class PosePainter extends CustomPainter {
  final Size absoluteImageSize;
  final List<Pose> poses;

  PosePainter(this.absoluteImageSize, this.poses);

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

      // Draw pose skeleton lines
      paintLine(PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow, leftPaint);
      paintLine(PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist, leftPaint);
      paintLine(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow, rightPaint);
      paintLine(PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist, rightPaint);
      paintLine(PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip, leftPaint);
      paintLine(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip, rightPaint);
    }
  }

  @override
  bool shouldRepaint(PosePainter oldDelegate) {
    return oldDelegate.absoluteImageSize != absoluteImageSize ||
        oldDelegate.poses != poses;
  }
}