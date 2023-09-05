import 'package:flutter/material.dart';
import 'package:newsplus/helper/categoryData.dart';
import 'package:newsplus/helper/newsData.dart';
import 'package:newsplus/models/ArticleModel.dart';
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

  List<ArticleModel> mArticleList = [];

  bool loadingNews = true;


  bool isFABVisible = false;
  ScrollController _scrollController = ScrollController();


  // This controller will store the value of the search bar
  final TextEditingController searchController = TextEditingController();

  // selected index of the bottom navigation bar
  int selectedIndex = 0;


  void _scrollToTop() {
    _scrollController.animateTo(
      0.0,
      duration: Duration(milliseconds: 500), // Adjust the duration as needed
      curve: Curves.easeInOut,
    );
  }



  @override
  void initState() {
    super.initState();
    mCategoryList = getCategories();


    initializeNews();

    _scrollController.addListener(() {
      // Check if the user has scrolled to the top
      if (_scrollController.offset <= 0) {
        setState(() {
          // Hide the FAB when at the top
          isFABVisible = false;
        });
      } else {
        setState(() {
          // Show the FAB when not at the top
          isFABVisible = true;
        });
      }
    });

  }

  initializeNews() async {
    News defaultNews = News();
    await defaultNews.getNewsData();
    mArticleList = defaultNews.newsList;

    setState(() {
      loadingNews = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      floatingActionButton: Visibility(
        visible: isFABVisible,
        child: FloatingActionButton(
          onPressed: _scrollToTop,
          child: Icon(Icons.arrow_upward),
        ),
      ),


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
                    style: TextStyle(
                        color: Colors.blue, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    "Plus",
                    style: TextStyle(
                        color: Colors.grey, fontWeight: FontWeight.w600),
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
              Navigator.pushNamed(
                  context, '/profile'); // Replace with your profile route
            },
          ),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      body: loadingNews
          ? Center(child: Container(child: CircularProgressIndicator()))
          : SingleChildScrollView(
            controller: _scrollController, // Add this line
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child:

            Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SearchBar(
                    controller: searchController,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      "All Category :",
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),

                  //Category Card
                  Container(
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

                  //Article Card
                  Container(
                    child: ListView.builder(
                      shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: mArticleList.length,
                        scrollDirection: Axis.vertical,
                        itemBuilder: (context, index) {

                          return NewsCard(
                              imageUrl: mArticleList[index].urlToImage,
                              title: mArticleList[index].title,
                              description: mArticleList[index].description,
                              url: mArticleList[index].url,
                          );

                        }),
                  )
                ],
              ),
          ),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: selectedIndex,
        onItemSelected: (index) {
          setState(() {
            selectedIndex = index;
            print("Current index: " + selectedIndex.toString());
            // Implement navigation based on the selected index here
          });
        },
      ),
    );
  }
}
