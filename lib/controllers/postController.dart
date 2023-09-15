import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:newsplus/models/PostModel.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class PostController extends ChangeNotifier {
  final List<PostModel> mPostsList = [
  ]; // Initialize an empty list to store posts

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
              title: postData['title'],
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


          // Sort the list by likesCount in descending order (highest likesCount first)
          mPostsList.sort((a, b) => b.likesCount.compareTo(a.likesCount));


          // Notify listeners after adding and sorting all items to the list
          notifyListeners();
        }
      }
    } catch (error) {
      // Handle any errors that occur during the fetching process
      print('Error fetching posts: $error');
      throw error;
    }
  }

  Future<void> createPost(String title, String postText, String userId, String username,
      String communityId) async {

    // Generate a unique ID for the post
    final uuid = Uuid();
    final postId = uuid.v4();

    // Create a new post model with initial values
    final post = PostModel(
        postId: postId,
        title: title,
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
      'postId': post.postId,
      'title' : post.title,
      'content': post.content,
      'creationDate': post.creationDate,
      'likesCount': post.likesCount,
      'reportCount': post.reportCount,
      'hidden': post.hidden,
      'userId': post.userId,
      'username': post.username,
      'communityId': post.communityId
    };

    DatabaseReference ref = FirebaseDatabase.instance.ref().child('post');

    try {
      // Add the post to the list
      mPostsList.insert(0,post);

      // Save the post data to Firebase with the generated ID
      await ref.child(postId).set(data);

      // Notify listeners after adding all items to the list
      notifyListeners();
    } catch (error) {
      // Handle any errors that occur during the saving process
      print('Error saving news: $error');
      throw error;
    }
  }

  Future<void> updateLikesCount(String postId, int likesCount,
      bool isLiked) async {
    // Define a reference to the Firebase Realtime Database
    DatabaseReference ref = FirebaseDatabase.instance.ref().child('post').child(postId);

    int updatedLikesCount = isLiked ? --likesCount : ++likesCount;

    try {

      print('Likes before :' + likesCount.toString());

      // Update the likesCount in Firebase
      await ref.update({'likesCount': updatedLikesCount});

      // Find the post in mPostsList and update its likesCount
      final updatedPostIndex = mPostsList.indexWhere((post) => post.postId == postId);
      if (updatedPostIndex != -1) {
        final updatedPost = mPostsList[updatedPostIndex];
        updatedPost.likesCount = updatedLikesCount;
        mPostsList[updatedPostIndex] = updatedPost;
        // Print the updated likes count for verification
        print('Likes after :' + updatedPost.likesCount.toString());
      }

      print('Likes Count updated');

    } catch (error) {
      // Handle any errors that occur during the fetching process
      print('Error fetching posts: $error');
      throw error;
    }
  }

}
