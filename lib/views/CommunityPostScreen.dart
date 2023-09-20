import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:newsplus/controllers/postController.dart';
import 'package:newsplus/widgets/components.dart';
import 'package:provider/provider.dart';

class CommunityPostScreen extends StatefulWidget {
  final String communityTitle;
  final String communityId;

  const CommunityPostScreen({Key? key, required this.communityTitle, required this.communityId})
      : super(key: key);

  @override
  _CommunityPostScreenState createState() => _CommunityPostScreenState();
}

class _CommunityPostScreenState extends State<CommunityPostScreen> {
  bool isFilterApplied = false;

  bool isFABVisible = false;

  bool isSearchApplied = false;

  final ScrollController _scrollController = ScrollController();

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



    //pass setState to force the page refresh every time when the value of firebase is changed
    await postController.fetchRealtimeCommunityPosts( widget.communityId,  () {setState(() {
    });});

    // await postController.fetchPosts();
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
      body: Consumer<PostController>(builder: (context, newsProvider, child) {
        return loading
            ? Center(child: Container(child: CircularProgressIndicator()))
            : ListView.builder(
                shrinkWrap: true,
                primary: false,
                itemCount: postController.mPostsList.length, // Replace with the actual number of posts
                itemBuilder: (context, index) {
                  // Create and return a PostCard widget for this post
                  return PostCard(
                      post: postController.mPostsList[index] ,
                      controller: postController,
                      onUpdate: () {
                        setState(() {});
                      });
                },
              );
      }),
    );
  }
}
