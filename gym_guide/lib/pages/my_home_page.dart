import 'package:flutter/material.dart';
import 'package:gym_guide/data/exercise.dart';
import 'package:gym_guide/data/workout_category_list.dart';
import 'package:gym_guide/pages/BMI_page.dart';
import 'package:gym_guide/pages/filter_exercise_page.dart';
import 'package:gym_guide/widget/exercise_card_widget.dart';
import 'package:gym_guide/widget/workout_category_widget.dart';

class MyHomePage extends StatefulWidget {
  static String routeName = "MyHomePage";

  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Column(
          children: [


            Container(
              height: 100,
              width: double.infinity,
              color: Color(0xFF0E2376),

              child: Padding(
                padding: const EdgeInsets.only(top: 50, left: 20),
                child: Text(
                  "GYMGUIDE",
                  style: TextStyle(
                    fontSize: 25,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            ListTile(
              title: Text("BMI"),
              onTap:(){
                Navigator.of(context).pushNamed(BMIPage.routeName);
              },
            ),
            ListTile(
              title: Text("Filter"),
              onTap:(){
                Navigator.of(context).pushNamed(FilterExercisePage.routeName);
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
          onTap: (value) {
            _index = value;
            setState(() {});
          },
          currentIndex: _index,
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.category), label: "Category"),
            BottomNavigationBarItem(
                icon: Icon(Icons.favorite), label: "Favourite"),
          ]),
      appBar: AppBar(
        backgroundColor: Colors.amberAccent,
        title: const Text(
          "Welcome Jack",
          style: TextStyle(
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 10.0),
            child: CircleAvatar(
              backgroundImage: AssetImage("assets/profile.jpg"),
            ),
          )
          //Image.asset("assets/profile.jpg"),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            _index == 0
                ? Text(
                    "Workout Categories",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic,
                    ),
                  )
                : Text(
                    "Favourite Exercise",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
            Divider(
              color: Colors.black,
            ),

            _index == 0
                ? Expanded(
                    //use list view to create widget with index
                    child: ListView.builder(
                      itemBuilder: (context, index) => WorkoutCategoryWidget(
                          wCategoryModel: workoutCategoryList[index]),
                      itemCount: workoutCategoryList.length,
                    ),
                  )
                : Expanded(
                    //use list view to create widget with index
                    child: ListView.builder(
                      itemBuilder: (context, index) => ExerciseCardWidget(
                        exerciseModel: exerciseList
                            .where((element) => element.isFavourite == true)
                            .toList()[index],
                      ),
                      itemCount: exerciseList
                          .where((element) => element.isFavourite == true)
                          .toList()
                          .length,
                    ),
                  )

            //map function to create widget
            //...workoutCategoryList.map((e) => WorkoutCategoryWidget(mCategoryModel: e)).toList()
          ],
        ),
      ),
    );
  }
}
