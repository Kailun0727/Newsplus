import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:newsplus/models/PostModel.dart';
import 'package:intl/intl.dart';

class PostController extends ChangeNotifier{
  final List<PostModel> mPostsList = []; // Initialize an empty list to store posts


  Future<void> fetchPosts() async {
    // Clear the list before adding fetched items
    mPostsList.clear();

    // Define a reference to the Firebase Realtime Database
    DatabaseReference ref = FirebaseDatabase.instance.ref().child('post');

    try {
      // Create a query to filter news items by userId
      Query query = ref.orderByChild('hidden').equalTo(false);

      // Retrieve data once from the database
      DatabaseEvent event = await query.once();

      // Check if the snapshot contains data
      if (event.snapshot != null) {
        // Get the value of the snapshot
        final dynamic postMap = event.snapshot!.value;

        // Check if the retrieved data is a Map
        if (postMap is Map) {


          postMap.forEach((key, postData) {
            // Convert the data to a PostModel
            PostModel post = PostModel(
              postId: postData['postId'],
              content: postData['content'],
              creationDate: postData['creationDate'],
              likesCount: postData['likesCount'],
              reportCount: postData['reportCount'],
              hidden: postData['hidden'],
              userId: postData['userId'],
              username: postData['username'],
              communityId: postData['communityId'],
            );

            // Add the post to the list
            mPostsList.insert(0, post);
          });

          // Print the values in the list
          for (var post in mPostsList) {
            print('Post ID: ${post.postId}');
            print('Content: ${post.content}');
            // Add more fields as needed
          }

          // Notify listeners after adding all items to the list
          notifyListeners();
        }
      }
    } catch (error) {
      // Handle any errors that occur during the fetching process
      print('Error fetching posts: $error');
      throw error;
    }

  }

  Future<void> createPost(String postText, String userId, String username, String communityId) async {
    // Create a new post model with initial values
    final post = PostModel(
      postId: 'unique', // You can generate a unique ID for the post if needed
      content: postText,
      creationDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
      likesCount: 0,
      reportCount: 0,
      hidden: false,
      userId: userId,
      username: username,
      communityId: communityId
    );

    // Convert the post model to a map
    final data = {
      'postId': post.postId, // You can generate a unique ID for the post if needed
      'content': post.content,
      'creationDate': post.creationDate,
      'likesCount': post.likesCount,
      'reportCount': post.reportCount,
      'hidden': post.hidden,
      'userId': post.userId,
      'username': post.username,
      'communityId' : post.communityId
    };

    // Define a reference to the Firebase Realtime Database
    DatabaseReference ref = FirebaseDatabase.instance.ref().child('post');
    DatabaseReference postRef = ref.push(); // Generates a unique key for the news

    try {
      // Save the post data to Firebase
      // Add the post to the list
      mPostsList.add(post);

      // Print the values in the list
      for (var post in mPostsList) {
        print('Post ID: ${post.postId}');
        print('Content: ${post.content}');
        // Add more fields as needed
      }

      // Notify listeners after adding all items to the list
      notifyListeners();

      await postRef.set(data);
    } catch (error) {
      // Handle any errors that occur during the saving process
      print('Error saving news: $error');
      throw error;
    }
  }



}
