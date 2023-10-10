import 'package:flutter/material.dart';
import 'package:gym_guide/data/app_state.dart';
import 'package:gym_guide/data/exercise.dart';
import 'package:gym_guide/model/exercise_model.dart';
import 'package:gym_guide/widget/exercise_card_widget.dart';

class ActivityListPage extends StatelessWidget {
  static String routeName = "MyActivityPage";

  const ActivityListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //assign data that stored in navigator to args
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    String title = args['title'];
    List<ExerciseModel> exerciseList = args['exerciseList'];

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: exerciseList.isEmpty? Center(
        child: Text("No exercise with difficult level : ${AppState.difficultyLevel}, and equipment: ${AppState.selectedEquipment}",
        style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,),
      )
          : ListView.separated(

        physics: BouncingScrollPhysics(),
        //add spacing between each widget
        separatorBuilder: (context, index) => SizedBox(height: 20,),
        itemBuilder: (context, index) =>
            ExerciseCardWidget(exerciseModel: exerciseList[index]),
        itemCount: exerciseList.length,
      ),
    );
  }
}
