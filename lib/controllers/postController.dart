import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:newsplus/models/PostModel.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class PostController extends ChangeNotifier {


  List<PostModel> mPostsList = []; // Initialize an empty list to store posts
  List<PostModel> mFilterPostsList = []; // Initialize an empty list to store filter posts

  String _filterKeyword = ""; // Store the filter keyword

  String _searchKeyword = "";

  Future<void> searchPost(String keyword) async {
    _searchKeyword = keyword.toLowerCase();

    mFilterPostsList.clear();

    mPostsList = mPostsList
        .where((post) =>
    (post.title?.toLowerCase()?.contains(_searchKeyword) ?? false) ||
        (post.content?.toLowerCase()?.contains(_searchKeyword) ??
            false))
        .toList();

    notifyListeners();
  }

  // Apply filter based on keyword
  void applyFilter(String keyword) {
    _filterKeyword = keyword
        .toLowerCase(); // Convert to lowercase for case-insensitive filtering

    // Clear the filtered list first to avoid duplicates
    mFilterPostsList.clear();

    // Filter the post list based on the keyword
    mFilterPostsList = mPostsList
        .where((post) =>
    (post.title?.toLowerCase()?.contains(_filterKeyword) ?? false) ||
        (post.content?.toLowerCase()?.contains(_filterKeyword) ??
            false))
        .toList();

    notifyListeners();
  }

  // Clear the filter
  void clearFilter() {
    _filterKeyword = "";
    mFilterPostsList.clear(); // Clear the filtered list
    notifyListeners();
  }

  Future<void> fetchRealtimeUserPosts(Function onUpdate, String userId) {
    DatabaseReference ref = FirebaseDatabase.instance.ref().child('post');
    Query query = ref.orderByChild('hidden').equalTo(false);

    // Listen for real-time changes to the data
    query.onValue.listen((event) {
      mPostsList.clear();
      final dynamic postMap = event.snapshot!.value;

      // Check if the retrieved data is a Map
      if (postMap is Map) {
        postMap.forEach((key, postData) {
          // Check if the post's userId matches the specified userId
          if (postData['userId'] == userId) {
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
              photoUrl: postData['photoUrl'],
              communityId: postData['communityId'],
            );
            mPostsList.insert(0, post);
          }
        });
        // Sort the list by likesCount in descending order (highest likesCount first)
        mPostsList.sort((a, b) => b.likesCount.compareTo(a.likesCount));
        notifyListeners();
        onUpdate();
      }
    });
    return Future.value();
  }

  Future<void> fetchRealtimePosts(Function onUpdate) {
    DatabaseReference ref = FirebaseDatabase.instance.ref().child('post');

    Query query = ref.orderByChild('hidden').equalTo(false);

    // Listen for real-time changes to the data
    query.onValue.listen((event) {
      // Clear the list before adding fetched items
      mPostsList.clear();

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
            photoUrl: postData['photoUrl'],
            communityId: postData['communityId'],
          );
          mPostsList.insert(0, post);
        });

        // Sort the list by likesCount in descending order (highest likesCount first)
        mPostsList.sort((a, b) => b.likesCount.compareTo(a.likesCount));
        notifyListeners();
        onUpdate();
      }
    });

    // Return a completed Future since there are no asynchronous operations here.
    return Future.value();
  }

  Future<void> fetchRealtimeCommunityPosts(String communityId, Function onUpdate) {
    mPostsList.clear();
    DatabaseReference ref = FirebaseDatabase.instance.ref().child('post');
    Query query = ref.orderByChild('hidden').equalTo(false);

    // Listen for real-time changes to the data
    query.onValue.listen((event) {
      mPostsList.clear();
      final dynamic postMap = event.snapshot!.value;

      // Check if the retrieved data is a Map
      if (postMap is Map) {
        postMap.forEach((key, postData) {

          // Check if the post's communityId matches the specified communityId
          if (postData['communityId'] == communityId) {
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
              photoUrl: postData['photoUrl'],
              communityId: postData['communityId'],
            );
            mPostsList.insert(0, post);
          }
        });
        // Sort the list by likesCount in descending order (highest likesCount first)
        mPostsList.sort((a, b) => b.likesCount.compareTo(a.likesCount));
        onUpdate();
        notifyListeners();
      }
    });

    // Return a completed Future since there are no asynchronous operations here.
    return Future.value();
  }

  Future<void> createPost(String title, String postText, String userId, String username,String communityId) async {

    final user = FirebaseAuth.instance.currentUser;

    String? photoUrl = "";

    if (user != null) {
      photoUrl = user.photoURL;

      // Generate a unique ID for the post
      final uuid = Uuid();
      final postId = uuid.v4();

      // Create a new post model with initial values
      final post = PostModel(
          postId: postId,
          title: title,
          content: postText,
          creationDate: DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now().add(Duration(hours: 8))),
          likesCount: 0,
          reportCount: 0,
          hidden: false,
          userId: userId,
          username: username,
          photoUrl: photoUrl?? "https://t4.ftcdn.net/jpg/03/32/59/65/360_F_332596535_lAdLhf6KzbW6PWXBWeIFTovTii1drkbT.jpg",
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
        'photoUrl' : post.photoUrl,
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
  }

  Future<void> updateLikesCount(String postId, int likesCount, bool isLiked) async {
    // Define a reference to the Firebase Realtime Database
    DatabaseReference ref = FirebaseDatabase.instance.ref().child('post').child(postId);

    int updatedLikesCount = isLiked ? --likesCount : ++likesCount;

    try {

      // Update the likesCount in Firebase
      await ref.update({'likesCount': updatedLikesCount});


      //Need to update filtered post first, otherwise cannot update ui
      // Find the post in mPostsList and update its likesCount
      final updatedFilteredPostIndex = mFilterPostsList.indexWhere((post) => post.postId == postId);

      if (updatedFilteredPostIndex != -1) {
        final updatedPost = mFilterPostsList[updatedFilteredPostIndex];
        updatedPost.likesCount = updatedLikesCount;
        mFilterPostsList[updatedFilteredPostIndex] = updatedPost;
      }

      // Find the post in mPostsList and update its likesCount
      final updatedPostIndex = mPostsList.indexWhere((post) => post.postId == postId);

      if (updatedPostIndex != -1) {
        final updatedPost = mPostsList[updatedPostIndex];
        updatedPost.likesCount = updatedLikesCount;
        mPostsList[updatedPostIndex] = updatedPost;
      }

      notifyListeners();

    } catch (error) {
      // Handle any errors that occur during the fetching process
      print('Error fetching posts: $error');
      throw error;
    }
  }

  Future<void> updateReportCount(BuildContext context,String postId, int reportCount, bool isReported) async {
    // Define a reference to the Firebase Realtime Database
    DatabaseReference ref = FirebaseDatabase.instance.ref().child('post').child(postId);

    int updatedReportCount = ++reportCount;

    try {
      // Update the reportCount in Firebase
      await ref.update({'reportCount': updatedReportCount});


      //Need to update filtered post first, otherwise cannot update ui
      // Find the post in mPostsList and update its likesCount
      final updatedFilteredPostIndex = mFilterPostsList.indexWhere((post) => post.postId == postId);
      if (updatedFilteredPostIndex != -1) {
        final updatedPost = mFilterPostsList[updatedFilteredPostIndex];
        updatedPost.reportCount = updatedReportCount;
        mFilterPostsList[updatedFilteredPostIndex] = updatedPost;

        // Check if reportCount is equal to 5 and set hidden to true
        if (updatedReportCount == 5) {
          await ref.update({'hidden': true});

          // Show a Snackbar to inform that this post has reached the report limit
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.reachReportLimit),
            ),
          );
        }

      }

      // Find the post in mPostsList and update its reportCount
      final updatedPostIndex = mPostsList.indexWhere((post) => post.postId == postId);
      if (updatedPostIndex != -1) {
        final updatedPost = mPostsList[updatedPostIndex];
        updatedPost.reportCount = updatedReportCount;
        mPostsList[updatedPostIndex] = updatedPost;

        // Check if reportCount is equal to 5 and set hidden to true
        if (updatedReportCount == 5) {
          await ref.update({'hidden': true});

          // Show a Snackbar to inform that this post has reached the report limit
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.reachReportLimit),
            ),
          );
        }

      }
    } catch (error) {
      // Handle any errors that occur during the update process
      print('Error updating report count: $error');
      throw error;
    }
  }

  Future<void> editPost(String postId, String newTitle, String newContent, String newCommunityId) async {
    // Define a reference to the Firebase Realtime Database
    DatabaseReference ref = FirebaseDatabase.instance.ref().child('post').child(postId);

    try {
      // Create a map with the updated title and content
      Map<String, dynamic> updatedData = {
        'title': newTitle,
        'content': newContent,
        'communityId': newCommunityId
      };

      // Update the post in Firebase
      await ref.update(updatedData);

      // Find the post in mPostsList and update its title and content
      final updatedPostIndex = mPostsList.indexWhere((post) => post.postId == postId);

      final updatedFilteredPostIndex = mFilterPostsList.indexWhere((post) => post.postId == postId);

      if (updatedPostIndex != -1) {
        final updatedPost = mPostsList[updatedPostIndex];
        updatedPost.title = newTitle;
        updatedPost.content = newContent;
        updatedPost.communityId = newCommunityId;
        mPostsList[updatedPostIndex] = updatedPost;
      }

      if (updatedFilteredPostIndex != -1) {
        final updatedPost = mFilterPostsList[updatedFilteredPostIndex];
        updatedPost.title = newTitle;
        updatedPost.content = newContent;
        updatedPost.communityId = newCommunityId;
        mFilterPostsList[updatedFilteredPostIndex] = updatedPost;
      }

      notifyListeners();
    } catch (error) {
      // Handle any errors that occur during the editing process
      print('Error editing post: $error');
      throw error;
    }
  }

  Future<void> deletePost(String postId) async {
    // Define a reference to the Firebase Realtime Database
    DatabaseReference ref = FirebaseDatabase.instance.ref().child('post').child(postId);

    try {
      // Delete the post from Firebase
      await ref.remove();

      //Need to delete the filtered post first, otherwise cannot update ui
      // Find and remove the post
      final deletedFilteredPostIndex = mFilterPostsList.indexWhere((post) => post.postId == postId);

      if (deletedFilteredPostIndex != -1) {
        mFilterPostsList.removeAt(deletedFilteredPostIndex);
      }

      // Find and remove the post
      final deletedPostIndex = mPostsList.indexWhere((post) => post.postId == postId);

      print("Index of filter post :"+deletedFilteredPostIndex.toString());

      if (deletedPostIndex != -1) {
        mPostsList.removeAt(deletedPostIndex);
      }

      notifyListeners();

    } catch (error) {
      // Handle any errors that occur during the deletion process
      print('Error deleting post: $error');
      throw error;
    }

  }

}
