import 'package:flutter/material.dart';
import 'package:newsplus/controllers/newsController.dart';
import 'package:newsplus/models/NewsModel.dart';
import 'package:newsplus/widgets/components.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CategoryNewsScreen extends StatefulWidget {
  final String categoryTitle;



  const CategoryNewsScreen({Key? key, required this.categoryTitle})
      : super(key: key);

  @override
  State<CategoryNewsScreen> createState() => _CategoryNewsScreenState();
}

class _CategoryNewsScreenState extends State<CategoryNewsScreen> {

  List<NewsModel> newsList = [];

  bool isFilterApplied = false;


  bool isFABVisible = false;
  final ScrollController _scrollController = ScrollController();

  NewsController newsController = NewsController();

  bool loadingNews = true;


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

    getCategoryNews();

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
            AppLocalizations.of(context)!.filterTitle,
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
                  hintText: AppLocalizations.of(context)!.keywordFilter,
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
                            content: Text(AppLocalizations.of(context)!.keywordFilter),
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
                    child: Text(AppLocalizations.of(context)!.apply),
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
                            content: Text(AppLocalizations.of(context)!.noFilterToClear),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red, // Change the button color
                      onPrimary: Colors.white, // Change the text color
                    ),
                    child: Text(AppLocalizations.of(context)!.clear),
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
      loadingNews = true; // Set loadingNews to true while fetching search results
    });

    // Perform the search
    await newsController.searchCategoryNews(keyword,widget.categoryTitle);

    setState(() {
      loadingNews = false; // Set loadingNews to false when the search results are available
    });
  }





  getCategoryNews() async {

    // News defaultNews = News();
    // await defaultNews.getNewsData();
    // mArticleList = defaultNews.newsList;

    await newsController.fetchCategoryNews(widget.categoryTitle); // Use the NewsController to fetch news data

    newsList = newsController.newsList;

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
        title: Text(
          widget.categoryTitle,
          style: TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back, // Use the back arrow icon
            color: Colors.blue, // Set the color to blue
          ),
          onPressed: () {
            Navigator.pop(
                context); // Navigate back when the back button is pressed
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.person,
              color: Colors.blue,
            ),
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/profile',
              );
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
                          ? AppLocalizations.of(context)!.filterResults + " " +
                      newsController.filteredNewsList.length.toString()
                          : AppLocalizations.of(context)!.totalResults + " " + widget.categoryTitle + " : "+
                          newsController.newsList.length.toString()),
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
                      ? newsController.filteredNewsList.length
                      : newsController.newsList.length, // Use filteredNewsList if a filter is applied
                  scrollDirection: Axis.vertical,
                  itemBuilder: (context, index) {
                    return NewsCard(
                      category: widget.categoryTitle,

                      imageUrl: isFilterApplied
                          ? newsController.filteredNewsList[index].urlToImage
                          : newsController.newsList[index].urlToImage, // Use filteredNewsList if a filter is applied
                      title: isFilterApplied
                          ? newsController.filteredNewsList[index].title
                          : newsController.newsList[index].title, // Use filteredNewsList if a filter is applied
                      description: isFilterApplied
                          ? newsController.filteredNewsList[index].description
                          : newsController.newsList[index].description, // Use filteredNewsList if a filter is applied
                      publishedAt: isFilterApplied
                          ? newsController.filteredNewsList[index].publishedAt
                          : newsController.newsList[index].publishedAt, // Use filteredNewsList if a filter is applied
                      url: isFilterApplied
                          ? newsController.filteredNewsList[index].url
                          : newsController.newsList[index].url, // Use filteredNewsList if a filter is applied
                    );
                  },
                ),
              )
            ],
          ),
        );
      }),




    );
  }
}
