
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:newsplus/controllers/postController.dart';
import 'package:newsplus/widgets/components.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class UserPost extends StatefulWidget {
  const UserPost({Key? key}) : super(key: key);

  @override
  _UserPostState createState() => _UserPostState();
}

class _UserPostState extends State<UserPost> {

  final PostController postController = PostController();

  final ScrollController _scrollController = ScrollController();

  final TextEditingController filterPostController = TextEditingController();

  bool isFABVisible = false;

  bool isFilterApplied = false;

  bool loading = true;

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

  initializePost() async {

    final user = FirebaseAuth.instance.currentUser;

    if(user != null){
      String userId = user.uid;
      //pass onUpdate to force the page refresh every time when the value of firebase is changed
      await postController.fetchRealtimeUserPosts(onUpdate, userId);
    }
  }

  void onUpdate() {
    // Check if the widget is still mounted before updating the UI
    if (mounted) {
      // Update the UI using setState()
      setState(() {
        // Update your UI state here
      });
    }
  }

  void _openFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            AppLocalizations.of(context)!.filterPostTitle,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20.0,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: filterPostController,
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
                      String keyword = filterPostController.text;
                      if (keyword.isEmpty) {
                        // Show an error message if the text is empty
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              AppLocalizations.of(context)!.keywordFilter,
                            ),
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
                    child: Text(
                      AppLocalizations.of(context)!.apply,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (isFilterApplied) {
                        // Clear the filter only if isFiltered is true
                        filterPostController.clear();
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
                              AppLocalizations.of(context)!.noFilterToClear,
                            ),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red, // Change the button color
                      onPrimary: Colors.white, // Change the text color
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.clear,
                    ),
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

  void _scrollToTop() {
    _scrollController.animateTo(
      0.0,
      duration:
      const Duration(milliseconds: 500), // Adjust the duration as needed
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Visibility(
            visible: isFABVisible,
            child: FloatingActionButton(
              heroTag: "btn_up",
              onPressed: _scrollToTop,
              child: Icon(Icons.arrow_upward),
            ),
          ),
        ],
      ),


      appBar: AppBar(
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context)!.myPost,
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
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),

        body: Consumer<PostController>(builder: (context, newsProvider, child) {
          return loading
              ? Center(child: Container(child: CircularProgressIndicator()))
              : SingleChildScrollView(
            controller: _scrollController, // Add this line
            padding: const EdgeInsets.symmetric(horizontal: 8),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [

                    Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Text(
                        isFilterApplied
                            ? AppLocalizations.of(context)!.filterResults +
                            " : " +
                            postController.mFilterPostsList.length
                                .toString() : AppLocalizations.of(context)!.totalResults +
                            " : " + postController.mPostsList.length.toString(),

                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                      ),
                    ),

                    Spacer(),

                    Container(
                      width: 40.0, // Set the width to your desired size
                      height: 40.0, // Set the height to your desired size
                      decoration: BoxDecoration(
                        color:
                        Colors.blue, // Set the background color to blue
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

                const SizedBox(
                  height: 20,
                ),

                postController.mPostsList.isEmpty && !isFilterApplied
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
                  itemCount: (isFilterApplied
                      ? postController.mFilterPostsList.length
                      : postController.mPostsList
                      .length), // Replace with the actual number of posts
                  itemBuilder: (context, index) {
                    // Create and return a PostCard widget for this post
                    return EditPostCard(
                        post: (isFilterApplied
                            ? postController.mFilterPostsList[
                        index] // If a filter is applied, display posts from the filtered list
                            : postController.mPostsList[
                        index]  ),
                        controller: postController,
                        onUpdate: () {
                          setState(() {});
                        });
                  })
              ],
            ),
          );
        }),

    );
  }
}
