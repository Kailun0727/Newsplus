import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:newsplus/controllers/postController.dart';
import 'package:newsplus/helper/communityData.dart';
import 'package:newsplus/models/CommunityModel.dart';
import 'package:newsplus/widgets/components.dart';
import 'package:provider/provider.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({Key? key}) : super(key: key);

  @override
  _CommunityScreenState createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  List<CommunityModel> communityList = [];

  final ScrollController _scrollController = ScrollController();

  // This controller will store the value of the search bar
  final TextEditingController searchPostController = TextEditingController();

  final TextEditingController filterPostController = TextEditingController();

  final PostController postController = PostController();

  bool loading = true;

  // selected index of the bottom navigation bar
  int selectedIndex = 0;

  bool isFABVisible = false;

  void _scrollToTop() {
    _scrollController.animateTo(
      0.0,
      duration:
          const Duration(milliseconds: 500), // Adjust the duration as needed
      curve: Curves.easeInOut,
    );
  }

  void _showCreatePostDialog() {
    TextEditingController postTextController = TextEditingController();
    TextEditingController titleController = TextEditingController();
    String selectedCategory = '1'; // Default category is 'General'

    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create Post'),
          content: SingleChildScrollView(
            child: Container(
              width: double.maxFinite,
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      onChanged: (value) {
                        setState(() {
                          selectedCategory = value!;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Select Category',
                        border: OutlineInputBorder(),
                        // Customize the label text style
                        labelStyle: TextStyle(
                          color: Colors
                              .blue, // Change the label text color to your preference
                        ),
                      ),
                      // Customize the dropdown button style
                      icon: Icon(Icons
                          .arrow_drop_down), // Change the dropdown icon to your preference
                      iconSize: 24, // Adjust the icon size as needed
                      elevation: 16, // Adjust the elevation of the dropdown
                      style: TextStyle(
                        color: Colors
                            .black, // Change the text color of the selected item
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: '1',
                          child: Text('General'),
                        ),
                        DropdownMenuItem(
                          value: '2',
                          child: Text('Entertainment'),
                        ),
                        DropdownMenuItem(
                          value: '3',
                          child: Text('Business'),
                        ),
                        DropdownMenuItem(
                          value: '4',
                          child: Text('Technology'),
                        ),
                        DropdownMenuItem(
                          value: '5',
                          child: Text('Health'),
                        ),
                        DropdownMenuItem(
                          value: '6',
                          child: Text('Science'),
                        ),
                        DropdownMenuItem(
                          value: '7',
                          child: Text('Sports'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    TextFormField(
                      controller: titleController,
                      maxLines: 1,
                      decoration: const InputDecoration(
                        hintText: 'Enter a descriptive title...',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Title cannot be empty';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8.0),
                    TextFormField(
                      controller: postTextController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'What\'s on your mind?',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Post text cannot be empty';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              String postText =
                                  postTextController.text.toString();
                              String title = titleController.text.toString();

                              final user = FirebaseAuth.instance.currentUser;

                              if (user != null) {
                                final displayName =
                                    user.displayName ?? 'Unknown User';
                                await postController.createPost(
                                  title,
                                  postText,
                                  user.uid,
                                  displayName,
                                  selectedCategory,
                                );
                              }
                              Navigator.pop(context);

                              // Force to refresh page after creating a post
                              setState(() {});
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Colors.blue,
                            elevation: 0,
                            padding: EdgeInsets.symmetric(horizontal: 20.0),
                          ),
                          child: Text(
                            'Create',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  initializePost() async {


    //pass setState to force the page refresh every time when the value of firebase is changed
    await postController.fetchRealtimePosts( () {setState(() {
    });});
    // await postController.fetchPosts();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    initializePost();

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

    // Use then to get the result from the getCommunity function
    getCommunity().then((result) {
      setState(() {
        communityList = result;
      });
    });

    setState(() {
      loading = false;
    });
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
          FloatingActionButton(
            heroTag: "btn_create",
            onPressed: _showCreatePostDialog,
            child: Icon(Icons.add),
          ),
        ],
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
                        Expanded(
                            child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Container(
                            height: 60,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: TextField(
                              controller: searchPostController,
                              decoration: InputDecoration(
                                hintText: 'Search Post here...',
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () => searchPostController.clear(),
                                ),
                                prefixIcon: IconButton(
                                  icon: const Icon(Icons.search),
                                  onPressed: () async {
                                    final keyword =
                                        searchPostController.text.toString();
                                    if (keyword.isNotEmpty) {
                                      // Perform the search when the keyword is not empty
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
                        "Choose Community :",
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      height: 100, // Set a fixed height for the horizontal list
                      child: ListView.builder(
                        itemCount: communityList.length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          return CommunityCard(
                            communityId: communityList[index].communityId,
                            description: communityList[index].description,
                          );
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Text(
                        "Most Popular Post :",
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      primary: false,
                      itemCount: postController.mPostsList
                          .length, // Replace with the actual number of posts
                      itemBuilder: (context, index) {
                        // Create and return a PostCard widget for this post
                        return PostCard(
                          post: postController.mPostsList[index],
                          controller: postController,
                          onUpdate: () {
                            setState(() {

                            });
                          }
                        );
                      },
                    )
                  ],
                ),
              );
      }),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: 1,
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
