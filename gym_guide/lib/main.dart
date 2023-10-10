import 'package:flutter/material.dart';
import 'package:gym_guide/pages/BMI_page.dart';
import 'package:gym_guide/pages/activity_list_page.dart';
import 'package:gym_guide/pages/exercise_detail_page.dart';
import 'package:gym_guide/pages/filter_exercise_page.dart';
import 'package:gym_guide/pages/my_home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  refresh(){
    setState(() {

    });
  }



  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: MyHomePage.routeName,
      routes: {
        MyHomePage.routeName: (context) => MyHomePage(),
        ActivityListPage.routeName: (context) => ActivityListPage(),
        ExerciseDetailPage.routeName: (context) => ExerciseDetailPage(refreshUI: refresh),
        BMIPage.routeName : (context) => BMIPage(),
        FilterExercisePage.routeName : (context) => FilterExercisePage(),
      },

      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(

        primarySwatch: Colors.blue,
        appBarTheme: AppBarTheme(backgroundColor: Color(0xFF0E2376),),
        bottomAppBarTheme: BottomAppBarTheme(

        )
      ),
      home: const MyHomePage(),
    );
  }
}
