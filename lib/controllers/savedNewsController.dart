import 'dart:math';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:newsplus/models/ArticleModel.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:newsplus/models/SavedNewsModel.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class SavedNewsController extends ChangeNotifier {


  final List<SavedNewsModel> _savedNewsList = [];
   List<SavedNewsModel> _filterSavedNewsList = [];

  bool _loadingNews = true;
  String _filterKeyword = ""; // Store the filter keyword

  List<SavedNewsModel> get savedNewsList => _savedNewsList;
  List<SavedNewsModel> get filterSavedNewsList => _filterSavedNewsList;

  bool get loadingNews => _loadingNews;

  // Constructor
  SavedNewsController() {}

  Future<void> fetchSavedNews() async {
    final DatabaseReference newsRef =
    FirebaseDatabase.instance.ref().child("news");
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String userId = user.uid;

      try {
        // Create a query to filter news items by userId
        Query query = newsRef.orderByChild("userId").equalTo(userId);

        // Retrieve data once from the database
        DatabaseEvent event = await query.once();

        // Check if the snapshot contains data
        if (event.snapshot != null) {
          // Get the value of the snapshot
          final dynamic newsMap = event.snapshot!.value;

          // Check if the retrieved data is a Map
          if (newsMap is Map) {
            // Clear the list before adding fetched items
            _savedNewsList.clear();

            // Iterate through each key-value pair in the Map
            newsMap.forEach((key, newsData) {
              // Convert the data to a SavedNewsModel
              SavedNewsModel savedNews = SavedNewsModel(
                title: newsData['title'],
                description: newsData['description'],
                imageUrl: newsData['imageUrl'],
                url: newsData['url'],
                creationDate: DateTime.parse(newsData['creationDate']),
                userId: newsData['userId'],
              );


              // Add the converted SavedNewsModel to the _savedNewsList
              _savedNewsList.insert(0, savedNews);
            });

            // Sort the _savedNewsList by creationDate in ascending order
            _savedNewsList.sort((a, b) => a.creationDate.compareTo(b.creationDate));

            // Notify listeners after adding all items to the list
            notifyListeners();
          }
        }
      } catch (error) {
        // Handle any errors that occur during the process
        print('Error fetching saved news: $error');
        throw error;
      }
    }
  }

  // Apply filter based on keyword
  void applySavedNewsFilter(String keyword) {
    _filterKeyword = keyword
        .toLowerCase(); // Convert to lowercase for case-insensitive filtering

    // Clear the filtered list first to avoid duplicates
    _filterSavedNewsList.clear();

    // Filter the newsList based on the keyword
    _filterSavedNewsList = _savedNewsList
        .where((article) =>
    (article.title?.toLowerCase()?.contains(_filterKeyword) ?? false) ||
        (article.description?.toLowerCase()?.contains(_filterKeyword) ??
            false))
        .toList();

    notifyListeners();
  }

  void clearFilter() {
    _filterKeyword = "";
    _filterSavedNewsList.clear(); // Clear the filtered list
    notifyListeners();
  }


  Future<void> removeSavedNews(BuildContext context, String title) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String userId = user.uid;
      DatabaseReference newsRef = FirebaseDatabase.instance.ref().child("news");

      try {
        // Find the index of the item to remove in _savedNewsList
        int savedNewsListIndex = _savedNewsList.indexWhere((item) => item.title == title);
        int filterSavedNewsListIndex = _filterSavedNewsList.indexWhere((item) => item.title == title);


        if (savedNewsListIndex != -1) {
          // Find and remove the news item from Firebase using userId and title
          Query query = newsRef.orderByChild("userId").equalTo(userId);
          DatabaseEvent event = await query.once();

          if (event.snapshot != null) {
            final dynamic newsMap = event.snapshot!.value;

            if (newsMap is Map) {
              newsMap.forEach((key, newsData) async {
                if (newsData['title'] == title) {
                  // If the title matches, remove the news item from Firebase
                  await newsRef.child(key).remove();
                }
              });
            }
          }

          // Removal successful, show a success message
          ScaffoldMessenger.of(context).showSnackBar( SnackBar(
            content: Text(AppLocalizations.of(context)!.removeNewsSuccess),
            duration: Duration(seconds: 2), // You can adjust the duration as needed
          ));

          // Remove the item from both lists
          _savedNewsList.removeAt(savedNewsListIndex);

          if (filterSavedNewsListIndex != -1) {
            _filterSavedNewsList.removeAt(filterSavedNewsListIndex);
          }

          notifyListeners();
          print("Updated UI");

        } else {
          // No matching item found in _savedNewsList
          print('No matching item found');
        }
      } catch (error) {
        // Handle any errors that occur during the removal process
        print('Error removing saved news: $error');
        throw error;
      }
    }
  }




  static Future<void> saveNews(SavedNewsModel model) async {
    final formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(model.creationDate);
    final formattedDateString = formattedDate.toString();

    final data = {
      'title': model.title,
      'description': model.description,
      'imageUrl': model.imageUrl,
      'url': model.url,
      'creationDate': formattedDateString, // Extract only the date part
      'userId': model.userId,
    };

    DatabaseReference ref = FirebaseDatabase.instance.ref().child("news");
    DatabaseReference newNewsRef =
    ref.push(); // Generates a unique key for the news

    try {
      await newNewsRef.set(data);
    } catch (error) {
      // Handle any errors that occur during the saving process
      print('Error saving news: $error');
      throw error;
    }
  }


}
