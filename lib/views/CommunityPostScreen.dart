import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:newsplus/controllers/postController.dart';
import 'package:newsplus/widgets/components.dart';
import 'package:provider/provider.dart';

class CommunityPostScreen extends StatefulWidget {
  final String communityTitle;
  final String communityId;

  const CommunityPostScreen(
      {Key? key, required this.communityTitle, required this.communityId})
      : super(key: key);

  @override
  _CommunityPostScreenState createState() => _CommunityPostScreenState();
}

class _CommunityPostScreenState extends State<CommunityPostScreen> {
  bool isFilterApplied = false;

  bool isFABVisible = false;

  final ScrollController _scrollController = ScrollController();

  final TextEditingController filterPostController = TextEditingController();

  PostController postController = PostController();

  bool loading = true;

  void _scrollToTop() {
    _scrollController.animateTo(
      0.0,
      duration:
          const Duration(milliseconds: 500), // Adjust the duration as needed
      curve: Curves.easeInOut,
    );
  }

  initializePost() async {
    if (mounted) {
      // Check if the widget is still mounted
      //pass setState to force the page refresh every time when the value of firebase is changed
      await postController.fetchRealtimeCommunityPosts(widget.communityId, () {
        if (mounted) {
          // Check again in case it was disposed while awaiting
          setState(() {});
        }
      });
    }
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
                  AppLocalizations.of(context)!.filterPostTitle,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                  ),
                ),
                SizedBox(height: 16.0), // Add some spacing
                TextField(
                  controller: filterPostController,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.keywordFilter,
                  ),
                ),
                SizedBox(height: 16.0), // Add more spacing
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        String keyword = filterPostController.text;
                        if (keyword.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                AppLocalizations.of(context)!.keywordFilter,
                              ),
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
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0.0), // Remove border radius
                        ),
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
                          filterPostController.clear();
                          _clearFilter();
                          setState(() {
                            isFilterApplied = false;
                          });
                          Navigator.pop(context);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                AppLocalizations.of(context)!.noFilterToClear,
                              ),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.red,
                        onPrimary: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0.0), // Remove border radius
                        ),
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
    postController.applyFilter(keyword);

    setState(() {
      // Update loadingNews to false only if a filter is not applied
      if (!isFilterApplied) {
        loading = false;
      }
      isFilterApplied = true; // Set the filter applied flag
    });
  }

  void _clearFilter() {
    // Call the clearFilter method of NewsController
    postController.clearFilter();

    setState(() {
      // Update loadingNews to true only if a filter is not applied
      if (!isFilterApplied) {
        loading = true;
      }
      isFilterApplied = false; // Clear the filter applied flag
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    setState(() {
      loading = true;
    });

    initializePost();

    setState(() {
      loading = false;
    });

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
          widget.communityTitle,
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
      body: Consumer<PostController>(builder: (context, postProvider, child) {
        return loading
            ? Center(child: Container(child: CircularProgressIndicator()))
            : postController.mPostsList.isEmpty && !isFilterApplied
                ? Container(
                    height: 500,
                    child: Center(
                      child:
                          Text(AppLocalizations.of(context)!.noDataAvailable),
                    ),
                  )
                : SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 8.0),
                              child: Text(
                                isFilterApplied
                                    ? AppLocalizations.of(context)!
                                            .filterResults +
                                        " : " +
                                        postController.mFilterPostsList.length
                                            .toString()
                                    : AppLocalizations.of(context)!
                                            .totalResults +
                                        " : " +
                                        postController.mPostsList.length
                                            .toString(),
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Spacer(),
                            Container(
                              width: 40.0, // Set the width to your desired size
                              height:
                                  40.0, // Set the height to your desired size
                              decoration: BoxDecoration(
                                color: Colors
                                    .blue, // Set the background color to blue
                                borderRadius: BorderRadius.circular(
                                    20), // Optional: Add rounded corners
                              ),
                              child: IconButton(
                                icon: Icon(Icons.filter_list,
                                    color: Colors
                                        .white), // Set the icon color to white
                                onPressed: () {
                                  // Open a filter dialog or screen when the filter button is pressed
                                  _openFilterDialog(context);
                                },
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 10,),

                        ListView.builder(
                          shrinkWrap: true,
                          primary: false,
                          itemCount: isFilterApplied
                              ? postController.mFilterPostsList.length
                              : postController.mPostsList
                                  .length, // Replace with the actual number of posts
                          itemBuilder: (context, index) {
                            // Create and return a PostCard widget for this post
                            return PostCard(
                                post: isFilterApplied
                                    ? postController.mFilterPostsList[index]
                                    : postController.mPostsList[index],
                                controller: postController,
                                onUpdate: () {
                                  setState(() {});
                                });
                          },
                        ),
                      ],
                    ),
                  );
      }),
    );
  }
}
