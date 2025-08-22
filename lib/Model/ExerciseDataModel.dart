import 'dart:ui';

enum ExerciseType{PushUps, Squats, DownwardDogPlank, JumpingJack, RussianTwist, SideLegRaiseLeft, SideLegRaiseRight, FrontLungeLeft, FrontLungeRight, LegKickBackRight, LegKickBackLeft, LegStraightenUpDown, ShoulderShrug, CalfRaise, HipSwingRight, HipSwingLeft, HipLift, SitUps, ReverseCrunches, Lightmarching, WallSit, Punchout, ShoulderStretchLeft, ShoulderStretchRight, ChestStretch, BriskWalk, ThighStretchLeft, ThighStretchRight, PigeonStretchLeft, PigeonStretchRight}
class ExerciseDataModel {
  String title;
  String image;
  Color color;
  ExerciseType type;
  ExerciseDataModel(this.title, this.image, this.color, this.type);
}
