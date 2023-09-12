import 'package:flutter/material.dart';
import 'package:newsplus/controllers/newsController.dart';
import 'package:newsplus/helper/categoryData.dart';
import 'package:newsplus/helper/newsData.dart';
import 'package:newsplus/models/ArticleModel.dart';
import 'package:newsplus/models/CategoryModel.dart';
import 'package:provider/provider.dart';
import 'package:newsplus/widgets/components.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<CategoryModel> mCategoryList = [];

  // List<ArticleModel> mArticleList = [];

  bool loadingNews = true;

  bool isFilterApplied = false;

  bool isFABVisible = false;
  final ScrollController _scrollController = ScrollController();

  NewsController newsController = NewsController();

  // This controller will store the value of the search bar
  final TextEditingController searchController = TextEditingController();

  final TextEditingController filterController = TextEditingController();

  // selected index of the bottom navigation bar
  int selectedIndex = 0;

  //prefer category to recommend news
  String category='';

  Future<String> getPreferCategory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('prefer_category') ?? 'General'; // default value = General if not found
  }

// To set the 'category' variable, you need to await the result of the Future.
  Future<void> getCategory() async {
    category = await getPreferCategory();
    print("getCategory call first : " + category);
  }





  void _scrollToTop() {
    _scrollController.animateTo(
      0.0,
      duration:
          const Duration(milliseconds: 500), // Adjust the duration as needed
      curve: Curves.easeInOut,
    );
  }

  void _openFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filter News'),
          content: TextField(
            controller: filterController,
            decoration: const InputDecoration(
              hintText: 'Enter keyword to filter news',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Apply the filter based on the keyword entered
                String keyword = filterController.text;
                if (keyword.isEmpty) {
                  // Show an error message if the text is empty
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a keyword to filter news.'),
                    ),
                  );
                } else {
                  // Call a method to apply the filter based on the keyword
                  _applyFilter(keyword);
                  Navigator.pop(context);
                }
              },
              child: const Text('Apply'),
            ),
            TextButton(
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
                    const SnackBar(
                      content: Text('No filter to clear.'),
                    ),
                  );
                }
              },
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );
  }

  void _applyFilter(String keyword) {
    // Call the applyFilter method of NewsController
    newsController.applyFilter(keyword);

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

  void _searchNews(String keyword) async {
    setState(() {
      loadingNews =
          true; // Set loadingNews to true while fetching search results
    });

    // Perform the search
    await newsController.searchNews(keyword);

    setState(() {
      loadingNews =
          false; // Set loadingNews to false when the search results are available
    });
  }

  @override
  void initState() {
    super.initState();
    mCategoryList = getCategories();

    recommendNews();

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

  Future<void> recommendNews() async {
    // Call getCategory and wait for it to complete
    await getCategory();

    print("In Recommend News function , category :"+category.toString());

    // Now you can call initializeNews with the category obtained from getCategory
    initializeNews(category.toString());
  }


  initializeNews(String categoryTitle) async {
    // News defaultNews = News();
    // await defaultNews.getNewsData();
    // mArticleList = defaultNews.newsList;



    await newsController
        .fetchNewsData(categoryTitle); // Use the NewsController to fetch news data


    if(mounted){
      setState(() {
        loadingNews = false;
      });
    }

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
                        Expanded(
                            child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Container(
                            height: 60,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: TextField(
                              controller: searchController,
                              decoration: InputDecoration(
                                hintText: 'Search News',
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () => searchController.clear(),
                                ),
                                prefixIcon: IconButton(
                                  icon: const Icon(Icons.search),
                                  onPressed: () async {
                                    final keyword =
                                        searchController.text.toString();
                                    if (keyword.isNotEmpty) {
                                      // Perform the search when the keyword is not empty
                                      _searchNews(keyword);
                                    } else {
                                      // Show an error message if the keyword is empty
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Please enter a keyword to search.'),
                                        ),
                                      );
                                    }
                                  },
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                              ),
                            ),
                          ),
                        )),
                        Container(
                          width: 40.0, // Set the width to your desired size
                          height: 40.0, // Set the height to your desired size
                          decoration: BoxDecoration(
                            color: Colors.blue, // Set the background color to blue
                            borderRadius: BorderRadius.circular(20), // Optional: Add rounded corners
                          ),
                          child: IconButton(
                            icon: Icon(Icons.filter_list, color: Colors.white), // Set the icon color to white
                            onPressed: () {
                              // Open a filter dialog or screen when the filter button is pressed
                              _openFilterDialog(context);
                            },
                          ),
                        )
                      ],
                    ),

                    const SizedBox(
                      height: 20,
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Text(
                        "All Category :",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(
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

                    Padding(
                      padding: const EdgeInsets.only(left:8.0),
                      child: Text(
                        (isFilterApplied
                            ? " Filter Results : "+ newsController.filteredNewsList.length
                            .toString()
                            :  "Total Result : " + newsController.newsList.length.toString())

                           ,
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                      ),
                    ),




                    //News Card
                    Container(
                      child: ListView.builder(
                        shrinkWrap: true,
                        primary: false,

                        itemCount: isFilterApplied
                            ? newsController.filteredNewsList.length
                            : newsController.newsList
                                .length, // Use filteredNewsList if a filter is applied
                        scrollDirection: Axis.vertical,
                        itemBuilder: (context, index) {
                          return NewsCard(
                            // should retrieve prefer category from shared preference, but now i just set to general
                            category: category.toString(),
                            imageUrl: isFilterApplied
                                ? newsController
                                    .filteredNewsList[index].urlToImage
                                : newsController.newsList[index]
                                    .urlToImage, // Use filteredNewsList if a filter is applied
                            title: isFilterApplied
                                ? newsController.filteredNewsList[index].title
                                : newsController.newsList[index]
                                    .title, // Use filteredNewsList if a filter is applied
                            description: isFilterApplied
                                ? newsController
                                    .filteredNewsList[index].description
                                : newsController.newsList[index]
                                    .description, // Use filteredNewsList if a filter is applied
                            publishedAt: isFilterApplied
                                ? newsController
                                    .filteredNewsList[index].publishedAt
                                : newsController.newsList[index]
                                    .publishedAt, // Use filteredNewsList if a filter is applied
                            url: isFilterApplied
                                ? newsController.filteredNewsList[index].url
                                : newsController.newsList[index]
                                    .url, // Use filteredNewsList if a filter is applied
                          );
                        },
                      ),
                    )
                  ],
                ),
              );
      }),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: selectedIndex,
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
