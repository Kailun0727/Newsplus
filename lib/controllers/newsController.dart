import 'dart:io';
import 'package:newsplus/helper/languageMapper.dart';
import 'package:path_provider/path_provider.dart';

import 'dart:math';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:newsplus/models/NewsModel.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:newsplus/models/SavedNewsModel.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:translator/translator.dart';



class NewsController extends ChangeNotifier {
  final List<NewsModel> _newsList = [];
  List<NewsModel> _filteredNewsList = []; // Declare _filteredNewsList

  List<SavedNewsModel> _savedNewsList = [];
  List<SavedNewsModel> _filterSavedNewsList = [];


  bool _loadingNews = true;
  String _filterKeyword = ""; // Store the filter keyword

  List<SavedNewsModel> get savedNewsList => _savedNewsList;
  List<SavedNewsModel> get filterSavedNewsList => _filterSavedNewsList;

  List<NewsModel> get newsList => _newsList;
  List<NewsModel> get filteredNewsList =>
      _filteredNewsList; // Getter for filteredNewsList
  bool get loadingNews => _loadingNews;

  // Constructor
  NewsController() {
  }

  static Future<String> extractText(String newsUrl) async {

    final url = Uri.parse('https://magicapi-article-extraction.p.rapidapi.com/extract');
    final headers = {
      'content-type': 'application/json',
      'X-Rapidapi-Key': '91beb912femshe4936b9eb0c9e29p113efajsn9003840a6986',
      'X-Rapidapi-Host': 'magicapi-article-extraction.p.rapidapi.com',
    };

    // Use json to encode the object to json format and send it to server
    final body = json.encode({
      "url": newsUrl,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {


        // Parse the JSON response
        final jsonResponse = json.decode(utf8.decode(response.bodyBytes));

        final extractText = jsonResponse['text'];


        print(extractText);

        return extractText;
      }

      else {
        // Handle errors here, e.g., print an error message
        print('Request failed with status: ${response.statusCode}');
        print('Response: ${response.body}');
        return 'Failed'; // Return a default value or error message
      }
    } catch (e) {
      // Handle exceptions, e.g., network issues
      print('Error: $e');
      return 'Failed'; // Return a default value or error message
    }
  }

  static Future<String> summarizeNews(String extractedText) async {


    final url = Uri.parse('https://text-analysis12.p.rapidapi.com/summarize-text/api/v1.1');
    final headers = {
      'content-type': 'application/json',
      'X-Rapidapi-Key': '91beb912femshe4936b9eb0c9e29p113efajsn9003840a6986',
      'X-Rapidapi-Host': 'text-analysis12.p.rapidapi.com',
    };

    // Use json to encode the object to json format and send it to server
    final body = json.encode({
      "language": 'english',
      "summary_percent": 20,
      "text": extractedText,
    });

      try {
        final response = await http.post(url, headers: headers, body: body);

        if (response.statusCode == 200) {
          // Parse the JSON response
          final jsonResponse = json.decode(response.body);

          print(jsonResponse);

          final summary = jsonResponse['summary'];

          if(summary == null){
            final message = jsonResponse['msg'];
            return message;
          }

          return summary;
        }

        else {
          // Handle errors here, e.g., print an error message
          print('Request failed with status: ${response.statusCode}');
          print('Response: ${response.body}');

          return 'Failed to summarize'; // Return a default value or error message
        }
      } catch (e) {
        // Handle exceptions, e.g., network issues
        print('Error: $e');
        return 'Failed to summarize'; // Return a default value or error message
      }
  }

  static Future<String> translate(String? text, String languageCode) async {
    final translator = GoogleTranslator();
    var translation = await translator.translate(text!, to: languageCode);
    return translation.text;
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

  String convertCategoryTitle(String localizedCategory) {
    switch (localizedCategory) {
      case "Umum":
      case "一般":
        return "General";
      case "Hiburan":
      case "娱乐":
        return "Entertainment";
      case "Perniagaan":
      case "商业":
        return "Business";
      case "Teknologi":
      case "科技":
        return "Technology";
      case "Kesihatan":
      case "健康":
        return "Health";
      case "Sains":
      case "科学":
        return "Science";
      case "Sukan":
      case "体育":
        return "Sports"; // Chinese: 体育
      default:
        return localizedCategory;
    }
  }


  Future<void> searchCategoryNews(String keyword, String categoryTitle) async {
    _newsList.clear();
    _filteredNewsList.clear();

    _loadingNews = true;

    String convertedCategory = convertCategoryTitle(categoryTitle);

    print('Converted cateogry title : '+convertedCategory);

    const apiKey = "2bb4019c07fb4e9ebda44c552cc573ac";
    if (apiKey == null || apiKey.isEmpty) {
      print("API key is missing or empty");
      return; // Return early if the API key is missing or empty
    }

    final apiUrl = Uri.parse(
        "https://newsapi.org/v2/top-headlines?country=us&q=$keyword&category=$convertedCategory&sortBy=publishedAt&searchIn=title,description&pageSize=50&apiKey=$apiKey");

    final res = await http.get(apiUrl);

    final json = jsonDecode(res.body);

    if (json['status'] == "ok") {
      json['articles'].forEach((data) {
        if (data['urlToImage'] != null &&
            data['description'] != null &&
            data['content'] != null) {
          String inputDateString = data['publishedAt'];

          // Parse the input string into a DateTime object
          DateTime dateTime = DateTime.parse(inputDateString);

          // Format the DateTime object into the desired format (YYYY-MM-dd)
          String formattedDate =
              "${dateTime.year.toString().padLeft(4, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";

          NewsModel mArticleModel = NewsModel(
            description: data['description'],
            title: data['title'],
            content: data['content'],
            publishedAt: formattedDate,
            url: data['url'],
            urlToImage: data['urlToImage'],
          );

          _newsList.add(mArticleModel);
        }
      });
    }

    _loadingNews = false;
    notifyListeners();
  }

  Future<void> searchNews(String keyword) async {
    _newsList.clear();
    _filteredNewsList.clear();
    _loadingNews = true;

    const apiKey = "2bb4019c07fb4e9ebda44c552cc573ac";
    if (apiKey == null || apiKey.isEmpty) {
      print("API key is missing or empty");
      return;
    }

    final apiUrl = Uri.parse(
        "https://newsapi.org/v2/everything?q=$keyword&sortBy=publishedAt&searchIn=title,description&pageSize=100&apiKey=$apiKey"
    );

    final res = await http.get(apiUrl);

    final json = jsonDecode(res.body);

    if (json['status'] == "ok") {
      json['articles'].forEach((data) {
        if (data['urlToImage'] != null &&
            data['description'] != null &&
            data['content'] != null) {
          String inputDateString = data['publishedAt'];

          DateTime dateTime = DateTime.parse(inputDateString);

          // Format the DateTime object into the desired format (YYYY-MM-dd)
          String formattedDate =
              "${dateTime.year.toString().padLeft(4, '0')}-${dateTime.month.toString()
              .padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";

          NewsModel mArticleModel = NewsModel(
            description: data['description'],
            title: data['title'],
            content: data['content'],
            publishedAt: formattedDate,
            url: data['url'],
            urlToImage: data['urlToImage'],
          );
          _newsList.insert(0,mArticleModel);
        }
      });
    }
    _loadingNews = false;
    notifyListeners();
  }


  Future<void> fetchCategoryNews(String categoryTitle) async {
    _loadingNews = true;
    String convertedCategory = convertCategoryTitle(categoryTitle);
    newsList.clear(); //clear previous data

    const apiKey = "2bb4019c07fb4e9ebda44c552cc573ac";
    final apiUrl = Uri.parse(
        "https://newsapi.org/v2/top-headlines?pageSize=100&country=us&category=$convertedCategory&apiKey=$apiKey");

    final res = await http.get(apiUrl);
    final json = jsonDecode(res.body);

    if (json['status'] == "ok") {
      for (final data in json['articles']) {
        if (data['urlToImage'] != null &&
            data['description'] != null &&
            data['content'] != null) {
          String inputDateString = data['publishedAt'];
          // Parse the input string into a DateTime object
          DateTime dateTime = DateTime.parse(inputDateString);

          // Format the DateTime object into the desired format (YYYY-MM-dd)
          String formattedDate =
              "${dateTime.year.toString().padLeft(4, '0')}-${dateTime.month.toString()
              .padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";

          NewsModel mArticleModel = NewsModel(
            description: data['description'],
            title: data['title'],
            content: data['content'],
            publishedAt: formattedDate,
            url: data['url'],
            urlToImage: data['urlToImage'],
          );
          _newsList.add(mArticleModel);
        }
      }
    }
    _loadingNews = false;
    notifyListeners();
  }

  // Fetch news data
  Future<void> fetchNewsData(String categoryTitle) async {
    _loadingNews = true;
    const apiKey = "2bb4019c07fb4e9ebda44c552cc573ac";

    final apiUrl = Uri.parse("https://newsapi.org/v2/top-headlines?pageSize=100&country=us&category=$categoryTitle&apiKey=$apiKey");

    final res = await http.get(apiUrl);

    final json = jsonDecode(res.body);

    if (json['status'] == "ok") {
      for (final data in json['articles']) {
        // Check if urlToImage, description, and content are not null
        if ( data['title'] != null &&  data['title'] != '[Removed]' &&data['description'] != null) {
          String inputDateString = data['publishedAt'];

          DateTime dateTime = DateTime.parse(inputDateString);

          String formattedDate = "${dateTime.year.toString()
              .padLeft(4, '0')}-${dateTime.month.toString()
              .padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";

          if(data['urlToImage'] == null){
            NewsModel mArticleModel = NewsModel(
              description: data['description'],
              title: data['title'],
              content: data['content'],
              publishedAt: formattedDate,
              url: data['url'],
              urlToImage: 'http://sagarikaelectronics.com/sagarika_admin/dist/img/no-image.png',
            );
            _newsList.add(mArticleModel);
          }else{
            NewsModel mArticleModel = NewsModel(
              description: data['description'],
              title: data['title'],
              content: data['content'],
              publishedAt: formattedDate,
              url: data['url'],
              urlToImage: data['urlToImage'],
            );
            _newsList.add(mArticleModel);
          }
        }
      }
    }
    _loadingNews = false;
    notifyListeners();
  }

  // Apply filter based on keyword
  void applyFilter(String keyword) {
    _filterKeyword = keyword
        .toLowerCase(); // Convert to lowercase for case-insensitive filtering

    // Clear the filtered list first to avoid duplicates
    _filteredNewsList.clear();

    // Filter the newsList based on the keyword
    _filteredNewsList = _newsList
        .where((article) =>
            (article.title?.toLowerCase()?.contains(_filterKeyword) ?? false) ||
            (article.description?.toLowerCase()?.contains(_filterKeyword) ??
                false))
        .toList();

    notifyListeners();
  }

  // Clear the filter
  void clearFilter() {
    _filterKeyword = "";
    _filteredNewsList.clear(); // Clear the filtered list
    notifyListeners();
  }
}
