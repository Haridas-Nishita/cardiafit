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
    'None',
  ];
  final List<String> currentDiagnoses = [
    'Arrhythmia',
    'Coronary Artery Disease',
    'Heart Failure',
    'Other',
  ];

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // Navigate to the warmup screen with parameters
      Navigator.pushNamed(
        context,
        '/warmup',
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
        leading: IconButton(
          icon: Icon(Icons.info_outline, color: Colors.white),
          onPressed: () {
            Navigator.pushNamed(context, '/about');
          },
        ),
        title: Text('Onboarding Screen', style: TextStyle(color: Colors.white)),
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
                    labelStyle: TextStyle(color: Color(0xFF674188)),
                    filled: true,
                    fillColor: Color(0xFFEEEEEE),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    helperText: 'Must be between 25 and 75 years',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your age';
                    }
                    final age = int.tryParse(value);
                    if (age == null) {
                      return 'Age must be a whole number';
                    }
                    if (age < 25 || age > 75) {
                      return 'Age must be between 25 and 75';
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
                    labelStyle: TextStyle(
                      color: Color(0xFF674188),
                    ), // Medium purple
                    filled: true,
                    fillColor: Color(0xFFEEEEEE), // Light gray
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  value: gender,
                  items:
                      genders.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: TextStyle(
                              color: Color(0xFF3B1E54),
                            ), // Dark purple
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
                    labelStyle: TextStyle(
                      color: Color(0xFF674188),
                    ), // Medium purple
                    filled: true,
                    fillColor: Color(0xFFEEEEEE), // Light gray
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  value: medicalHistory,
                  items:
                      medicalHistories.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: TextStyle(
                              color: Color(0xFF3B1E54),
                            ), // Dark purple
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
                    labelStyle: TextStyle(
                      color: Color(0xFF674188),
                    ), // Medium purple
                    filled: true,
                    fillColor: Color(0xFFEEEEEE), // Light gray
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  value: currentDiagnosis,
                  items:
                      currentDiagnoses.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: TextStyle(
                              color: Color(0xFF3B1E54),
                            ), // Dark purple
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
                    labelStyle: TextStyle(color: Color(0xFF674188)),
                    filled: true,
                    fillColor: Color(0xFFEEEEEE),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    helperText: 'Must be between 50 and 120 bpm',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your resting heart rate';
                    }
                    final heartRate = int.tryParse(value);
                    if (heartRate == null) {
                      return 'Heart rate must be a whole number';
                    }
                    if (heartRate < 50 || heartRate > 120) {
                      return 'Heart rate must be between 50 and 120 bpm';
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
                    hintText: 'e.g., 120/80',
                    labelStyle: TextStyle(color: Color(0xFF674188)),
                    filled: true,
                    fillColor: Color(0xFFEEEEEE),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    helperText: 'Format: XXX/XX (e.g., 120/80)',
                  ),
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your blood pressure';
                    }
                    final RegExp bpPattern = RegExp(r'^\d{2,3}/\d{2}$');
                    if (!bpPattern.hasMatch(value)) {
                      return 'Please enter in format XXX/XX (e.g., 120/80)';
                    }
                    final parts = value.split('/');
                    final systolic = int.tryParse(parts[0]);
                    final diastolic = int.tryParse(parts[1]);

                    if (systolic == null || diastolic == null) {
                      return 'Invalid blood pressure values';
                    }

                    if (systolic < 70 || systolic > 250) {
                      return 'Systolic must be between 70 and 250 mmHg';
                    }

                    if (diastolic < 40 || diastolic > 150) {
                      return 'Diastolic must be between 40 and 150 mmHg';
                    }

                    if (systolic <= diastolic) {
                      return 'Systolic must be greater than diastolic';
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
                    hintText: 'e.g., 25.5',
                    labelStyle: TextStyle(color: Color(0xFF674188)),
                    filled: true,
                    fillColor: Color(0xFFEEEEEE),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    helperText:
                        'BMI = weight (kg) / height (m)²\nMust be between 10.0 and 50.0 (1 decimal place)',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your BMI';
                    }
                    final bmi = double.tryParse(value);
                    if (bmi == null) {
                      return 'BMI must be a valid number';
                    }
                    if (bmi < 10 || bmi > 50) {
                      return 'BMI must be between 10 and 50';
                    }
                    if (!value.contains('.') ||
                        value.split('.')[1].length != 1) {
                      return 'BMI must have exactly 1 decimal place';
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
