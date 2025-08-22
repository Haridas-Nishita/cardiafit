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
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(
        title: 'screen',
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
    final options = PoseDetectorOptions(
        mode: PoseDetectionMode.stream);
    poseDetector = PoseDetector(options: options);

    controller = CameraController(cameras[0], ResolutionPreset.medium,imageFormatGroup: Platform.isAndroid
    ? ImageFormatGroup.nv21
        : ImageFormatGroup.bgra8888,  );
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

  //TODO pose detection on a frame
  dynamic _scanResults;
  CameraImage? img;
  doPoseEstimationOnFrame() async {
    var inputImage = _inputImageFromCameraImage();
    if(inputImage != null){
      final List<Pose> poses = await poseDetector.processImage(inputImage!);
      print("pose="+poses.length.toString());
      _scanResults = poses;
      if(poses.length>0) {
        detectSquat(poses.first.landmarks);
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
            child: (controller.value.isInitialized)
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
            child: buildResult()
        ),
      );

      stackChildren.add(
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            margin: EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(50), color: Colors.black,),
            child: Center(
              child:Text(
                "$squatCount",
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
          child: Stack(
            children: stackChildren,
          )),
    );
  }

int rightLegStraightenCount = 0;
bool isLegStraightened = false;

void detectRightLegStraighten(Map<PoseLandmarkType, PoseLandmark> landmarks) {
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

  // Calculate knee angle to determine straightening/bending
  double rightKneeAngle = calculateAngle(rightHip, rightKnee, rightAnkle);
  double leftKneeAngle = calculateAngle(leftHip, leftKnee, leftAnkle);

  // Detect if the leg is straightened (knee angle close to 180 degrees)
  bool isRightLegStraightened = rightKneeAngle > 170; // Close to straightened (180 degrees)

  // Detect if the leg is bent (knee angle significantly less than 180)
  bool isRightLegBent = rightKneeAngle < 90; // Significantly bent

  // Check for straightening up
  if (isRightLegStraightened && !isLegStraightened) {
    isLegStraightened = true;
  }
  // Check for bending down
  else if (isRightLegBent && isLegStraightened) {
    rightLegStraightenCount++;
    isLegStraightened = false;

    // Update UI
    setState(() {});
  }
}





// Modify the angle calculation to be more robust
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

  // Convert to degrees and adjust for sign
  double angle = acos(cosAngle) * (180 / pi);
  
  // Determine sign using cross product
  double crossProduct = x1 * y2 - x2 * y1;
  return crossProduct > 0 ? angle : -angle;
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
        (Platform.isIOS && format != InputImageFormat.bgra8888)) return null;

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
    return CustomPaint(
      painter: painter,
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

      //Draw arms
      paintLine(
          PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow, leftPaint);
      paintLine(
          PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist, leftPaint);
      paintLine(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow,
          rightPaint);
      paintLine(
          PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist, rightPaint);

      //Draw Body
      paintLine(
          PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip, leftPaint);
      paintLine(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip,
          rightPaint);

      //Draw legs
      paintLine(PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee, leftPaint);
      paintLine(
          PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle, leftPaint);
      paintLine(
          PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee, rightPaint);
      paintLine(
          PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle, rightPaint);
    }
  }

  @override
  bool shouldRepaint(PosePainter oldDelegate) {
    return oldDelegate.absoluteImageSize != absoluteImageSize ||
        oldDelegate.poses != poses;
  }
}