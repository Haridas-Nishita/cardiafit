import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  int? age;
  String? gender;
  String? medicalHistory;
  String? currentDiagnosis;
  int? restingHeartRate;
  String? bloodPressure;
  double? bmi;

  final List<String> genders = ['Male', 'Female'];
  final List<String> medicalHistories = [
    'Bypass Surgery',
    'Previous Heart Attack',
    'None'
  ];
  final List<String> currentDiagnoses = [
    'Arrhythmia',
    'Coronary Artery Disease',
    'Heart Failure',
    'Other'
  ];

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // Navigate to the workout plan screen with parameters
      Navigator.pushNamed(
        context,
        '/workout-plan',
        arguments: {
          'age': age,
          'gender': gender,
          'medicalHistory': medicalHistory,
          'currentDiagnosis': currentDiagnosis,
          'restingHeartRate': restingHeartRate,
          'bloodPressure': bloodPressure,
          'bmi': bmi,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Onboarding Screen',
          style: TextStyle(color: Color(0xFFEEEEEE)), // Light gray text
        ),
        backgroundColor: Color(0xFF3B1E54), // Dark purple for app bar
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF7EFE5), // Light background
              Color(0xFFD4BEE4), // Light purple
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                // Age Field
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Age',
                    labelStyle:
                        TextStyle(color: Color(0xFF674188)), // Medium purple
                    filled: true,
                    fillColor: Color(0xFFEEEEEE), // Light gray
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your age';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    age = int.tryParse(value!);
                  },
                ),
                SizedBox(height: 20),

                // Gender Dropdown
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Gender',
                    labelStyle:
                        TextStyle(color: Color(0xFF674188)), // Medium purple
                    filled: true,
                    fillColor: Color(0xFFEEEEEE), // Light gray
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  value: gender,
                  items: genders.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style:
                            TextStyle(color: Color(0xFF3B1E54)), // Dark purple
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      gender = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select your gender';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),

                // Medical History Dropdown
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Medical History',
                    labelStyle:
                        TextStyle(color: Color(0xFF674188)), // Medium purple
                    filled: true,
                    fillColor: Color(0xFFEEEEEE), // Light gray
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  value: medicalHistory,
                  items: medicalHistories.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style:
                            TextStyle(color: Color(0xFF3B1E54)), // Dark purple
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      medicalHistory = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select your medical history';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),

                // Current Diagnosis Dropdown
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Current Diagnosis',
                    labelStyle:
                        TextStyle(color: Color(0xFF674188)), // Medium purple
                    filled: true,
                    fillColor: Color(0xFFEEEEEE), // Light gray
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  value: currentDiagnosis,
                  items: currentDiagnoses.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style:
                            TextStyle(color: Color(0xFF3B1E54)), // Dark purple
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      currentDiagnosis = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select your current diagnosis';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),

                // Resting Heart Rate Field
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Resting Heart Rate (bpm)',
                    labelStyle:
                        TextStyle(color: Color(0xFF674188)), // Medium purple
                    filled: true,
                    fillColor: Color(0xFFEEEEEE), // Light gray
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your resting heart rate';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    restingHeartRate = int.tryParse(value!);
                  },
                ),
                SizedBox(height: 20),

                // Blood Pressure Field
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Blood Pressure',
                    hintText: 'e.g., 113/80',
                    labelStyle:
                        TextStyle(color: Color(0xFF674188)), // Medium purple
                    filled: true,
                    fillColor: Color(0xFFEEEEEE), // Light gray
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your blood pressure';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    bloodPressure = value;
                  },
                ),
                SizedBox(height: 20),

                // BMI Field
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Body Mass Index (BMI)',
                    labelStyle:
                        TextStyle(color: Color(0xFF674188)), // Medium purple
                    filled: true,
                    fillColor: Color(0xFFEEEEEE), // Light gray
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your BMI';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    bmi = double.tryParse(value!);
                  },
                ),
                SizedBox(height: 20),

                // Submit Button
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF9B7EBD), // Medium purple
                    foregroundColor: Color(0xFFEEEEEE), // Light gray text
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
