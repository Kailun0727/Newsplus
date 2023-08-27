import 'package:flutter/material.dart';
import 'package:newsplus/helper/categoryData.dart';
import 'package:newsplus/models/CategoryModel.dart';
import 'package:provider/provider.dart';
import 'package:newsplus/widgets/components.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<CategoryModel> mCategoryList = [];

  @override
  void initState() {
    super.initState();
    mCategoryList = getCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "News",
                    style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    "Plus",
                    style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),

        actions: [
          IconButton(
            icon: Icon(
              Icons.person,
              color: Colors.blue, // Set the color to blue
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/profile'); // Replace with your profile route
            },
          ),
        ],

        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      body: Container(

        height: 100, // Set a fixed height for the horizontal list
        child: ListView.builder(
          itemCount: mCategoryList.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            return CategoryCard(
              imageUrl: mCategoryList[index].imageUrl,
              categoryTitle: mCategoryList[index].categoryTitle,
            );
          },
        ),


      ),




    );
  }
}
