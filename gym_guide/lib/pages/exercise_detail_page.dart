import 'package:flutter/material.dart';
import 'package:gym_guide/model/exercise_model.dart';
import 'package:collection/collection.dart';

class ExerciseDetailPage extends StatelessWidget {
  static String routeName = "/exerciseDetailPage";

  Function() refreshUI;


  ExerciseDetailPage({Key? key, required this.refreshUI}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ExerciseModel exerciseModel =
        ModalRoute.of(context)!.settings.arguments as ExerciseModel;

    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
        child: ListView(
          children: [
            Image.network(
              exerciseModel.imageUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Text(
              exerciseModel.name,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            Divider(
              color: Colors.black,
            ),
            ...exerciseModel.steps
                .mapIndexed((index, e) => ListTile(
                      title: Text(e),
                      leading: CircleAvatar(
                        child: Text((index + 1).toString()),
                      ),
                    ))
                .toList(),
            SizedBox(
              height: 20,
            ),
            Text(
              "Target Muscle",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Row(
              children: exerciseModel.targetMuscles
                  .map((e) => Card(
                        color: Colors.red,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            e,
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
            Text(
              "Equipment",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Row(
              children: exerciseModel.equipment
                  .map((e) => Card(
                        color: Color(0xFF0E237e),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            e,
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.green,
                  child: Icon(
                    Icons.account_tree,
                    color: Colors.white,
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Text(exerciseModel.sets),
                CircleAvatar(
                  backgroundColor: Colors.orange,
                  child: Icon(
                    Icons.fitness_center,
                    color: Colors.white,
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Text(exerciseModel.reps),
                CircleAvatar(
                  backgroundColor: Colors.orange,
                  child: Icon(
                    Icons.fitness_center,
                    color: Colors.white,
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Text(exerciseModel.duration),
              ],
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          exerciseModel.isFavourite = !exerciseModel.isFavourite;
          refreshUI();
        },
        backgroundColor: Colors.white,
        child: Icon(
          exerciseModel.isFavourite?
          Icons.favorite : Icons.favorite_border,
          color: Colors.red,
        ),
      ),
    );
  }
}
