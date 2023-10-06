import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:newsplus/models/ReplyModel.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class ReplyController extends ChangeNotifier {

  List<ReplyModel> _mReplyList = [];

  List<ReplyModel> get mReplyList => _mReplyList;


  // Fetch replies for a specific post by postId
  Future<void> fetchRealTimeRepliesByPostId(String postId, Function onUpdate) {
    // Define a reference to the Firebase Realtime Database for replies
    DatabaseReference ref = FirebaseDatabase.instance.ref().child('reply');

    // Create a query to filter replies by postId
    Query query = ref.orderByChild('postId').equalTo(postId);

    // Listen for real-time changes to the data
    query.onValue.listen((event) {
      // Clear the list before adding fetched replies
      _mReplyList.clear();

      // Get the value of the snapshot
      final dynamic replyMap = event.snapshot!.value;

      // Check if the retrieved data is a Map
      if (replyMap is Map) {
        replyMap.forEach((key, replyData) {
          // Convert the data to a ReplyModel
          if(replyData['hidden'] != true){
            ReplyModel reply = ReplyModel(
              replyId: replyData['replyId'],
              postId: replyData['postId'],
              content: replyData['content'],
              creationDate: replyData['creationDate'],
              likesCount: replyData['likesCount'],
              reportCount: replyData['reportCount'],
              hidden: replyData['hidden'],
              userId: replyData['userId'],
              username: replyData['username'],
              photoUrl:  replyData['photoUrl'],
            );
            // Add the reply to the list
            _mReplyList.insert(0, reply);
          }
        });

        // Sort the list by likesCount in descending order (highest likesCount first)
        _mReplyList.sort((a, b) => b.likesCount.compareTo(a.likesCount));

        // Notify listeners after adding and sorting all items to the list
        notifyListeners();

        // Call the onUpdate callback to signal that updates are complete
        onUpdate();
      }
    });

    // Return a completed Future since there are no asynchronous operations here.
    return Future.value();
  }

  // Future<void> fetchRepliesByPostId(String postId) async {
  //   // Clear the list before adding fetched items
  //   _mReplyList.clear();
  //
  //   // Define a reference to the Firebase Realtime Database
  //   DatabaseReference ref = FirebaseDatabase.instance.ref().child('reply');
  //
  //   try {
  //     Query query = ref.orderByChild('postId').equalTo(postId);
  //
  //     // Retrieve data once from the database
  //     DatabaseEvent event = await query.once();
  //
  //     // Check if the snapshot contains data
  //     if (event.snapshot != null) {
  //       // Get the value of the snapshot
  //       final dynamic replyMap = event.snapshot!.value;
  //
  //       // Check if the retrieved data is a Map
  //       if (replyMap is Map) {
  //         replyMap.forEach((key, replyData) {
  //           // Convert the data to a ReplyModel
  //           ReplyModel reply = ReplyModel(
  //             replyId: replyData['replyId'],
  //             postId: replyData['postId'],
  //             content: replyData['content'],
  //             creationDate: replyData['creationDate'],
  //             likesCount: replyData['likesCount'],
  //             reportCount: replyData['reportCount'],
  //             hidden: replyData['hidden'],
  //             userId: replyData['userId'],
  //             username: replyData['username']
  //           );
  //
  //           // Add the reply to the list
  //           _mReplyList.insert(0, reply);
  //         });
  //
  //         for (var reply in _mReplyList) {
  //           print('replyId: ${reply.replyId}');
  //         }
  //
  //
  //         // Sort the list by likesCount in descending order (highest likesCount first)
  //         _mReplyList.sort((a, b) => b.likesCount.compareTo(a.likesCount));
  //
  //         // Notify listeners after adding and sorting all items to the list
  //         notifyListeners();
  //       }
  //     }
  //   } catch (error) {
  //     // Handle any errors that occur during the fetching process
  //     print('Error fetching reply:: $error');
  //     throw error;
  //   }
  // }

  // Add a new reply

  Future<void> addReply(String postId, String userId, String username, String content, String photoUrl) async {

    // Generate a unique ID for the reply
    final uuid = Uuid();
    final replyId = uuid.v4();

    // Create a new reply model with initial values
    final reply = ReplyModel(
        replyId: replyId,
        postId: postId,
        content: content,
        creationDate: DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now().add(Duration(hours: 8))),
        likesCount: 0,
        reportCount: 0,
        hidden: false,
        userId: userId,
        username: username,
        photoUrl: photoUrl
    );

    // Convert the reply model to a map
    final data = {
      'replyId' : reply.replyId,
      'postId': reply.postId,
      'content': reply.content,
      'creationDate': reply.creationDate,
      'likesCount': reply.likesCount,
      'reportCount' : reply.reportCount,
      'hidden' : reply.hidden,
      'userId': reply.userId,
      'username': reply.username,
      "photoUrl" : reply.photoUrl
    };

    DatabaseReference ref = FirebaseDatabase.instance.ref().child('reply');

    try {
      // Add the reply to the list
      _mReplyList.add(reply);

      // Save the reply data to Firebase with the generated ID
      await ref.child(replyId).set(data);

      // Notify listeners after adding all items to the list
      notifyListeners();
    } catch (error) {
      // Handle any errors that occur during the saving process
      print('Error saving news: $error');
      throw error;
    }
  }

  // Update likes count for a reply
  Future<void> updateLikesCount(String replyId, int likesCount, bool isLiked) async {

    DatabaseReference ref = FirebaseDatabase.instance.ref().child('reply').child(replyId);

    int updatedLikesCount = isLiked ? --likesCount : ++likesCount;

    try {
      // Update the likesCount in Firebase
      await ref.update({'likesCount': updatedLikesCount});

      final updatedReplyIndex = mReplyList.indexWhere((reply) => reply.replyId == replyId);

      if (updatedReplyIndex != -1) {
        final updatedReply = mReplyList[updatedReplyIndex];
        updatedReply.likesCount = updatedLikesCount;
        mReplyList[updatedReplyIndex] = updatedReply;
        // Print the updated likes count for verification
        print('Reply Likes after :' + updatedReply.likesCount.toString());
      }

    } catch (error) {
      // Handle any errors that occur during the fetching process
      print('Error fetching posts: $error');
      throw error;
    }
  }

  Future<void> updateReplyReportCount(BuildContext context, String postId, String replyId, int reportCount, bool isReported) async {
    // Define a reference to the Firebase Realtime Database for replies
    DatabaseReference ref = FirebaseDatabase.instance.ref().child('reply').child(replyId);

    int updatedReportCount = ++reportCount;

    try {
      // Update the reply reportCount in Firebase
      await ref.update({'reportCount': updatedReportCount});

      // Find the reply in mRepliesList and update its reportCount
      final updatedReplyIndex = _mReplyList.indexWhere((reply) => reply.replyId == replyId);
      if (updatedReplyIndex != -1) {
        final updatedReply = _mReplyList[updatedReplyIndex];
        updatedReply.reportCount = updatedReportCount;
        _mReplyList[updatedReplyIndex] = updatedReply;

        // Check if reportCount is equal to 5 and set hidden to true
        if (updatedReportCount == 5) {
          await ref.update({'hidden': true});

          // Show a Snackbar to inform that this reply has reached the report limit
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.reachReplyReportLimit),
            ),
          );
        }
      }
    } catch (error) {
      // Handle any errors that occur during the update process
      print('Error updating reply report count: $error');
      throw error;
    }
  }


}
