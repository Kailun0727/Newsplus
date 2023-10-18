import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:newsplus/controllers/savedNewsController.dart';
import 'package:newsplus/models/SavedNewsModel.dart';
import 'package:newsplus/widgets/components.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SavedNewsScreen extends StatefulWidget {
  const SavedNewsScreen({Key? key}) : super(key: key);

  @override
  State<SavedNewsScreen> createState() => _SavedNewsScreenState();
}

class _SavedNewsScreenState extends State<SavedNewsScreen> {

  List<SavedNewsModel> savedNewsList = [];

  bool isFilterApplied = false;

  bool isFABVisible = false;
  final ScrollController _scrollController = ScrollController();

  SavedNewsController savedNewsController = SavedNewsController();

  bool loadingNews = true;

  // selected index of the bottom navigation bar
  int selectedIndex = 0;

  final TextEditingController filterController = TextEditingController();

  void _scrollToTop() {
    _scrollController.animateTo(
      0.0,
      duration:
          const Duration(milliseconds: 500), // Adjust the duration as needed
      curve: Curves.easeInOut,
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

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
          title: Align(
            alignment: Alignment.center,
            child: Text(
              AppLocalizations.of(context)!.filterTitle,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
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
                    borderRadius: BorderRadius.zero, // Remove border radius
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
                            content: Text(
                                AppLocalizations.of(context)!.keywordFilter),
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
                            content: Text(
                                AppLocalizations.of(context)!.noFilterToClear),
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
    savedNewsController.applySavedNewsFilter(keyword);

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
    savedNewsController.clearFilter();

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

    await savedNewsController
        .fetchSavedNews(); // Use the NewsController to fetch news data

    savedNewsList = savedNewsController.savedNewsList;

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
      body: Consumer<SavedNewsController>(
          builder: (context, savedNewsProvider, child) {
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
                                ? AppLocalizations.of(context)!.filterResults +
                                    " " +
                                    savedNewsController
                                        .filterSavedNewsList.length
                                        .toString()
                                : AppLocalizations.of(context)!.totalSavedNews +
                                    " " +
                                    savedNewsController.savedNewsList.length
                                        .toString()),
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
                      child: savedNewsController.savedNewsList.isEmpty &&
                              !isFilterApplied
                          ? Container(
                              height: 500,
                              child: Center(
                                child: Text(AppLocalizations.of(context)!
                                    .noDataAvailable),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              primary: false,
                              itemCount: isFilterApplied
                                  ? savedNewsController
                                      .filterSavedNewsList.length
                                  : savedNewsController.savedNewsList.length,
                              scrollDirection: Axis.vertical,
                              itemBuilder: (context, index) {
                                return SavedNewsCard(
                                  controller: savedNewsController,
                                  imageUrl: isFilterApplied
                                      ? savedNewsController
                                          .filterSavedNewsList[index].imageUrl
                                      : savedNewsController
                                          .savedNewsList[index].imageUrl,
                                  title: isFilterApplied
                                      ? savedNewsController
                                          .filterSavedNewsList[index].title
                                      : savedNewsController
                                          .savedNewsList[index].title,
                                  description: isFilterApplied
                                      ? savedNewsController
                                          .filterSavedNewsList[index]
                                          .description
                                      : savedNewsController
                                          .savedNewsList[index].description,
                                  creationDate: isFilterApplied
                                      ? AppLocalizations.of(context)!.savedDate + " " +
                                          DateFormat('yyyy-MM-dd HH:mm').format(
                                              savedNewsController
                                                  .filterSavedNewsList[index]
                                                  .creationDate)
                                      : AppLocalizations.of(context)!.savedDate + " " +
                                          DateFormat('yyyy-MM-dd HH:mm').format(
                                              savedNewsController
                                                  .savedNewsList[index]
                                                  .creationDate),
                                  url: isFilterApplied
                                      ? savedNewsController
                                          .filterSavedNewsList[index].url
                                      : savedNewsController
                                          .savedNewsList[index].url,
                                  onRemove: () {
                                    // callback to refresh the screen
                                    setState(() {});
                                  },
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
