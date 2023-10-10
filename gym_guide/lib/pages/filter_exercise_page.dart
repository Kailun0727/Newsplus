import 'package:flutter/material.dart';
import 'package:gym_guide/data/app_state.dart';

enum Equipment{noEquipment,equipment,both}

class FilterExercisePage extends StatefulWidget {
  static String routeName = "/filterExercisePage";

  const FilterExercisePage({Key? key}) : super(key: key);

  @override
  State<FilterExercisePage> createState() => _FilterExercisePageState();
}

class _FilterExercisePageState extends State<FilterExercisePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Filter"),
      ),
      body: Column(
        children: [
          ListTile(
            title: Text("Equipment"),
            leading: Icon(
              Icons.fitness_center,
              color: Colors.black,
            ),
          ),
          RadioListTile(
              activeColor: Colors.black,
              value: Equipment.noEquipment,
              title: Text("No Equipment"),
              groupValue: AppState.selectedEquipment,
              onChanged: (value) {
                AppState.selectedEquipment=value!;
                setState(() {

                });
              }
          ),
          RadioListTile(
              activeColor: Colors.black,
              value: Equipment.equipment,
              title: Text("Equipment"),
              groupValue: AppState.selectedEquipment,
              onChanged: (value) {
                AppState.selectedEquipment=value!;
                setState(() {

                });
              }
          ),
          RadioListTile(
              activeColor: Colors.black,
              value: Equipment.both,
              title: Text("Both"),
              groupValue: AppState.selectedEquipment,
              onChanged: (value) {
                AppState.selectedEquipment=value!;
                setState(() {

                });
              }
          ),


          ListTile(
            title: Text("Difficulty level"),
            leading: Icon(
              Icons.work_history,
              color: Colors.black,
            ),
          ),

          Slider(
            label: "Difficulty level",
              activeColor: Colors.blue,
              thumbColor: Colors.black,

              value: AppState.difficultyLevel,
              divisions: 4,

              onChanged: (value){
                AppState.difficultyLevel = value;
                setState(() {

                });
              },
            max: 5,
            min: 1,
          )
        ],
      ),
    );
  }
}
