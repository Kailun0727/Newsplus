import 'package:flutter/material.dart';
import 'package:gym_guide/data/app_state.dart';
import 'package:gym_guide/data/exercise.dart';
import 'package:gym_guide/model/exercise_model.dart';
import 'package:gym_guide/pages/activity_list_page.dart';
import 'package:gym_guide/model/workout_category_model.dart';
import 'package:gym_guide/pages/filter_exercise_page.dart';

class WorkoutCategoryWidget extends StatelessWidget {
  final WorkoutCategoryModel wCategoryModel;

  const WorkoutCategoryWidget({Key? key, required this.wCategoryModel})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<ExerciseModel> list;
    return Column(
      children: [
        InkWell(
          onTap: () {

            //filter the list where the category equal to the wCategoryName
            list = exerciseList
                .where((element) =>
                    element.category == wCategoryModel.categoryName)
                .toList()
                .where(
                    (element) => element.difficulty <= AppState.difficultyLevel)
                .toList();

            //use the current user selected option to filter the list
            if(AppState.selectedEquipment == Equipment.equipment){
              list =  list.where((element) => element.equipment.isNotEmpty).toList();
            }
            else if(AppState.selectedEquipment == Equipment.noEquipment){
              list =  list.where((element) => element.equipment.isEmpty).toList();
            }


            Navigator.of(context).pushNamed(
              ActivityListPage.routeName,
              arguments: {
                'title': wCategoryModel.categoryName,
                //filter the data from exercise.dart
                'exerciseList': list,
              },
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              child: Stack(
                children: [
                  Image.network(
                    wCategoryModel.imageSource,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    bottom: 0,
                    child: Container(
                      height: 40,
                      width: 440,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                        colors: [Colors.black, Colors.transparent],
                      )),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: Text(
                            wCategoryModel.categoryName,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              height: 150,
              width: double.infinity,
            ),
          ),
        ),
        SizedBox(
          height: 20,
        )
      ],
    );
  }
}
