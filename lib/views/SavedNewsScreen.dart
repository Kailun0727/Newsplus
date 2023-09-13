import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:newsplus/controllers/newsController.dart';
import 'package:newsplus/models/ArticleModel.dart';
import 'package:newsplus/models/SavedNewsModel.dart';
import 'package:newsplus/widgets/components.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class SavedNewsScreen extends StatefulWidget {


  const SavedNewsScreen({Key? key})
      : super(key: key);

  @override
  State<SavedNewsScreen> createState() => _SavedNewsScreenState();
}

class _SavedNewsScreenState extends State<SavedNewsScreen> {

  // Initialize Firebase Analytics
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;

// Log an event
  Future<void> logEvent() async {
    await analytics.logEvent(
      name: 'button_click',
      parameters: <String, dynamic>{
        'button_id': 'example_button',
      },
    );
  }

  List<SavedNewsModel> savedNewsList = [];

  bool isFilterApplied = false;


  bool isFABVisible = false;
  final ScrollController _scrollController = ScrollController();

  NewsController newsController = NewsController();

  bool loadingNews = true;

  // selected index of the bottom navigation bar
  int selectedIndex = 0;

  // This controller will store the value of the search bar
  final TextEditingController searchController = TextEditingController();

  final TextEditingController filterController = TextEditingController();

  void _scrollToTop() {
    _scrollController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 500), // Adjust the duration as needed
      curve: Curves.easeInOut,
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    logEvent();

    getSavedNews();

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


  void _openFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Filter News',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20.0,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: filterController,
                decoration: InputDecoration(
                  hintText: 'Enter keyword to filter news',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
              ),
              SizedBox(height: 16.0), // Add some spacing
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Apply the filter based on the keyword entered
                      String keyword = filterController.text;
                      if (keyword.isEmpty) {
                        // Show an error message if the text is empty
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Please enter a keyword to filter news.'),
                          ),
                        );
                      } else {
                        // Call a method to apply the filter based on the keyword
                        _applyFilter(keyword);
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.blue, // Change the button color
                      onPrimary: Colors.white, // Change the text color
                    ),
                    child: Text('Apply'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (isFilterApplied) {
                        // Clear the filter only if isFiltered is true
                        filterController.clear();
                        _clearFilter();
                        setState(() {
                          isFilterApplied = false; // Set isFiltered to false
                        });
                        Navigator.pop(context);
                      } else {
                        // Show an error message if the filter is not applied
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('No filter to clear.'),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red, // Change the button color
                      onPrimary: Colors.white, // Change the text color
                    ),
                    child: Text('Clear'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _applyFilter(String keyword) {
    // Call the applyFilter method of NewsController
    newsController.applySavedNewsFilter(keyword);

    setState(() {
      // Update loadingNews to false only if a filter is not applied
      if (!isFilterApplied) {
        loadingNews = false;
      }
      isFilterApplied = true; // Set the filter applied flag
    });
  }

  void _clearFilter() {
    // Call the clearFilter method of NewsController
    newsController.clearFilter();

    setState(() {
      // Update loadingNews to true only if a filter is not applied
      if (!isFilterApplied) {
        loadingNews = true;
      }
      isFilterApplied = false; // Clear the filter applied flag
    });
  }


  getSavedNews() async {

    // News defaultNews = News();
    // await defaultNews.getNewsData();
    // mArticleList = defaultNews.newsList;

    await newsController.fetchSavedNews(); // Use the NewsController to fetch news data

    savedNewsList = newsController.savedNewsList;

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
          child: const Icon(Icons.arrow_upward),
        ),
      ),

      appBar: AppBar(
        centerTitle: true,
        title: Row(
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
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
            icon: const Icon(
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

      body: Consumer<NewsController>(builder: (context, newsProvider, child) {

        return loadingNews
            ? Center(child: Container(child: CircularProgressIndicator()))
            : SingleChildScrollView(
          controller: _scrollController, // Add this line
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      (isFilterApplied
                          ? " Filter Results : " +
                          newsController.filterSavedNewsList.length.toString()
                          : "Total Saved News : " +
                          newsController.savedNewsList.length.toString()),
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Spacer(), // This will push the Container to the right
                  Container(
                    width: 40.0,
                    height: 40.0,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.filter_list, color: Colors.white),
                      onPressed: () {
                        // Open a filter dialog or screen when the filter button is pressed
                        _openFilterDialog(context);
                      },
                    ),
                  ),
                ],
              ),


              //News Card
              Container(
                child: ListView.builder(
                  shrinkWrap: true,
                  primary: false,

                  itemCount: isFilterApplied
                      ? newsController.filterSavedNewsList.length
                      : newsController.savedNewsList.length, // Use filteredNewsList if a filter is applied
                  scrollDirection: Axis.vertical,
                  itemBuilder: (context, index) {
                      return SavedNewsCard(
                        controller: newsController,
                          imageUrl: isFilterApplied
                              ? newsController.filterSavedNewsList[index].imageUrl
                              : newsController.savedNewsList[index].imageUrl,
                          title: isFilterApplied
                              ? newsController.filterSavedNewsList[index].title
                              : newsController.savedNewsList[index].title,
                          description: isFilterApplied
                              ? newsController.filterSavedNewsList[index].description
                              : newsController.savedNewsList[index].description,
                          creationDate:  isFilterApplied
                              ? "Saved Date : " + DateFormat('yyyy-MM-dd HH:mm').format(newsController.filterSavedNewsList[index].creationDate)
                              : "Saved Date : " + DateFormat('yyyy-MM-dd HH:mm').format(newsController.savedNewsList[index].creationDate),
                          url:  isFilterApplied
                              ? newsController.filterSavedNewsList[index].url
                              : newsController.savedNewsList[index].url,
                      );
                  },
                ),
              )
            ],
          ),
        );
      }),


      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: 2,
        onItemSelected: (index) {
          setState(() {
            selectedIndex = index;
            // Implement navigation based on the selected index here
          });
        },
      ),

    );
  }
}
