import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum Gender { male, female }

class BMIPage extends StatefulWidget {
  static String routeName = "/bmiPage";
  const BMIPage({Key? key}) : super(key: key);

  @override
  State<BMIPage> createState() => _BMIPageState();
}

class _BMIPageState extends State<BMIPage> {
  double weight = 50;

  Gender gender = Gender.male;
  TextEditingController heightController = TextEditingController();

  double bmiValue=0;
  String message="";
  calculateBMI() {
    double height = double.parse(heightController.text);
    if (gender == Gender.male) {
      bmiValue = weight / (height * height) * 10000;
    } else {
      bmiValue = weight / (height * height) * 10000 * 0.9;
    }
    if (bmiValue < 18.5) {
      message = 'You are underweight';
    } else if (bmiValue >= 18.5 && bmiValue < 25) {
      message = 'You have a normal weight';
    } else if (bmiValue >= 25 && bmiValue < 30) {
      message = 'You are overweight';
    } else {
      message = 'You are obese';
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Calculate your BMI"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: 150,
                color: Colors.grey[100],
                child: Column(
                  children: [
                    const Text(
                      'Weight (Kg)',
                    ),
                    Text(
                      "${weight.toStringAsFixed(0)} kg",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    Slider(
                      value: weight,
                      onChanged: (value) {
                        weight = value;
                        setState(() {});
                      },
                      min: 1,
                      max: 150,
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              TextField(
                controller: heightController,
                decoration: const InputDecoration(labelText: 'Height (cm)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                      gender = Gender.male;
                      setState(() {});
                    },
                    child: Card(
                      color: gender == Gender.male
                          ? Colors.blue.shade50
                          : Colors.grey.shade50,
                      child: SizedBox(
                        height: 150,
                        width: 150,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Male",
                              style: TextStyle(
                                  fontSize: 25, fontWeight: FontWeight.bold),
                            ),
                            Icon(
                              Icons.check_circle,
                              color: gender == Gender.male
                                  ? Colors.green
                                  : Colors.grey.shade50,
                              size: 30,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      gender = Gender.female;
                      setState(() {});
                    },
                    child: Card(
                      color: gender == Gender.female
                          ? Colors.pink.shade50
                          : Colors.grey.shade50,
                      child: SizedBox(
                        height: 150,
                        width: 150,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Female",
                              style: TextStyle(
                                  fontSize: 25, fontWeight: FontWeight.bold),
                            ),
                            Icon(
                              Icons.check_circle,
                              color: gender == Gender.female
                                  ? Colors.green
                                  : Colors.grey.shade50,
                              size: 30,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              MaterialButton(
                onPressed: () {calculateBMI();},
                color: Color(0xFF0E2376),
                height: 60,
                minWidth: double.infinity,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: const Text(
                  'Calculate BMI',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                'Your BMI is ${bmiValue.toStringAsFixed(2)}\n$message ',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0E2376),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
