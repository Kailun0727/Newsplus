import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:newsplus/controllers/newsController.dart';
import 'package:newsplus/controllers/userController.dart';
import 'package:newsplus/models/CategoryModel.dart';
import 'package:provider/provider.dart';
import 'package:newsplus/widgets/components.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<CategoryModel> mCategoryList = [];

  FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  bool loadingNews = true;

  bool isFilterApplied = false;

  bool isFABVisible = false;

  bool isSearch = false;

  final ScrollController _scrollController = ScrollController();

  NewsController newsController = NewsController();

  // This controller will store the value of the search bar
  final TextEditingController searchController = TextEditingController();

  final TextEditingController filterController = TextEditingController();

  final ProfileController profileController = ProfileController();

  // selected index of the bottom navigation bar
  int selectedIndex = 0;

  //prefer category to recommend news
  String category='';

  bool _isInitialized = false;

  Future<String> getPreferCategory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('prefer_category') ?? 'General'; // default value = General if not found
  }

// To set the 'category' variable, you need to await the result of the Future.
  Future<void> getCategory() async {



    category = await getPreferCategory();
    print("getCategory call first : " + category);
  }


  List<CategoryModel> getCategories() {
    List<CategoryModel> myCategories = [];

    myCategories.add(CategoryModel(
      imageUrl: "https://images.unsplash.com/photo-1432821596592-e2c18b78144f?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1770&q=80",
      categoryTitle: AppLocalizations.of(context)!.general,
    ));

    myCategories.add(CategoryModel(
      imageUrl: "https://plus.unsplash.com/premium_photo-1682401101972-5dc0756ece88?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1770&q=80",
      categoryTitle: AppLocalizations.of(context)!.entertainment
    ));

    myCategories.add(CategoryModel(
      imageUrl: "https://images.unsplash.com/photo-1507679799987-c73779587ccf?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=1502&q=80",
      categoryTitle: AppLocalizations.of(context)!.business
    ));

    myCategories.add(CategoryModel(
      imageUrl: "https://images.unsplash.com/photo-1488590528505-98d2b5aba04b?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1770&q=80",
      categoryTitle: AppLocalizations.of(context)!.technology
    ));
    myCategories.add(CategoryModel(
      imageUrl: "https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1770&q=80",
      categoryTitle: AppLocalizations.of(context)!.health
    ));
    myCategories.add(CategoryModel(
      imageUrl: "https://plus.unsplash.com/premium_photo-1676325102583-0839e57d7a1f?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1770&q=80",
      categoryTitle: AppLocalizations.of(context)!.science
    ));

    myCategories.add(CategoryModel(
      imageUrl: "https://images.unsplash.com/photo-1517649763962-0c623066013b?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1770&q=80",
      categoryTitle: AppLocalizations.of(context)!.sports
    ));

    return myCategories;

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
        return Dialog(
          child: Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppLocalizations.of(context)!.filterTitle,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                  ),
                ),
                SizedBox(height: 16.0), // Add some spacing
                TextField(
                  controller: filterController,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.keywordFilter,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(0.0), // Remove border radius
                    ),
                  ),
                ),
                SizedBox(height: 16.0), // Add more spacing
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        String keyword = filterController.text;
                        if (keyword.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(AppLocalizations.of(context)!.keywordFilter),
                            ),
                          );
                        } else {
                          _applyFilter(keyword);
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.blue,
                        onPrimary: Colors.white,
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.apply,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (isFilterApplied) {
                          filterController.clear();
                          _clearFilter();
                          setState(() {
                            isFilterApplied = false;
                          });
                          Navigator.pop(context);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(AppLocalizations.of(context)!.noFilterToClear),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.red,
                        onPrimary: Colors.white,
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.clear,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
      isSearch = true;

      loadingNews =
          true; // Set loadingNews to true while fetching search results
    });

    // Perform the search
    await newsController.searchNews(keyword);

    analytics.setAnalyticsCollectionEnabled(true);

    await analytics.logEvent(
      name: 'search_news',
      parameters: <String, dynamic>{
        'keyword': keyword,
      },
    );

    setState(() {
      loadingNews =
          false; // Set loadingNews to false when the search results are available
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

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
    await initializeNews(category.toString());
  }


  initializeNews(String categoryTitle) async {

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

    mCategoryList = getCategories(); // Initialize mCategoryList here

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
          padding: const EdgeInsets.symmetric(horizontal: 8),
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
                                hintText: AppLocalizations.of(context)!.searchHintText,
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
                                          .showSnackBar(SnackBar(
                                          content: Text(
                                            AppLocalizations.of(context)!.keywordFilter,),
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
                     Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Text(
                        AppLocalizations.of(context)!.allCategory,
                        style: TextStyle(
                            fontSize: 18, color:Colors.black ,fontWeight: FontWeight.bold),
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
                            ? AppLocalizations.of(context)!.filterResults + " : " + newsController.filteredNewsList.length
                            .toString()
                            :

        (!isSearch ? AppLocalizations.of(context)!.recommendedNews + " "+ newsController.newsList.length.toString() :   AppLocalizations.of(context)!.totalResults + " : "+ newsController.newsList.length.toString())


                        )

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
                                ? newsController.filteredNewsList[index].publishedAt
                                : newsController.newsList[index].publishedAt, // Use filteredNewsList if a filter is applied
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
