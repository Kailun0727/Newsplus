import 'dart:io';
import 'package:newsplus/helper/languageMapper.dart';
import 'package:path_provider/path_provider.dart';

import 'dart:math';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:newsplus/models/ArticleModel.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:newsplus/models/SavedNewsModel.dart';
import 'package:intl/intl.dart';
import 'package:translator/translator.dart';



class NewsController extends ChangeNotifier {
  final List<ArticleModel> _newsList = [];
  List<ArticleModel> _filteredNewsList = []; // Declare _filteredNewsList

  List<SavedNewsModel> _savedNewsList = [];
  List<SavedNewsModel> _filterSavedNewsList = [];


  bool _loadingNews = true;
  String _filterKeyword = ""; // Store the filter keyword

  List<SavedNewsModel> get savedNewsList => _savedNewsList;
  List<SavedNewsModel> get filterSavedNewsList => _filterSavedNewsList;

  List<ArticleModel> get newsList => _newsList;
  List<ArticleModel> get filteredNewsList =>
      _filteredNewsList; // Getter for filteredNewsList
  bool get loadingNews => _loadingNews;

  static final logger = Logger();


  // Constructor
  NewsController() {
  }

  // static Future<String> extractTextAPI(String newsUrl) async{
  //   final url = Uri.parse('https://textapis.p.rapidapi.com/text?url='+newsUrl);
  //   final headers = {
  //     'content-type': 'application/x-www-form-urlencoded',
  //     'X-Rapidapi-Key': '91beb912femshe4936b9eb0c9e29p113efajsn9003840a6986',
  //     'X-Rapidapi-Host': 'textapis.p.rapidapi.com',
  //   };
  //
  //   try {
  //     final response = await http.get(url, headers: headers);
  //
  //     if (response.statusCode == 200) {
  //       // Parse the JSON response
  //       final jsonResponse = json.decode(response.body);
  //
  //       print(jsonResponse);
  //
  //       final extractedText = jsonResponse['text'];
  //
  //       print(extractedText);
  //
  //       // Return the translation
  //       return extractedText;
  //     } else {
  //       // Handle errors here, e.g., print an error message
  //       print('Request failed with status: ${response.statusCode}');
  //       print('Response: ${response.body}');
  //       return 'Extract failed'; // Return a default value or error message
  //     }
  //   } catch (e) {
  //     // Handle exceptions, e.g., network issues
  //     print('Error: $e');
  //     return 'Extract failed'; // Return a default value or error message
  //   }
  // }

  static Future<String> extractText(String newsUrl) async{
    final url = Uri.parse('https://text-extract7.p.rapidapi.com/?url='+newsUrl);
    final headers = {
      'content-type': 'application/x-www-form-urlencoded',
      'X-Rapidapi-Key': '91beb912femshe4936b9eb0c9e29p113efajsn9003840a6986',
      'X-Rapidapi-Host': 'text-extract7.p.rapidapi.com',
    };

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        // Parse the JSON response
        final jsonResponse = json.decode(response.body);

        // Extract the "trans" field from the JSON
        final extractedText = jsonResponse['raw_text'];

        // Return the translation
        return extractedText;
      } else {
        // Handle errors here, e.g., print an error message
        print('Request failed with status: ${response.statusCode}');
        print('Response: ${response.body}');
        return 'Extract failed'; // Return a default value or error message
      }
    } catch (e) {
      // Handle exceptions, e.g., network issues
      print('Error: $e');
      return 'Extract failed'; // Return a default value or error message
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
      "language": "english",
      "summary_percent": 10,
      "text": extractedText
    });

      try {
        final response = await http.post(url, headers: headers, body: body);

        if (response.statusCode == 200) {
          // Parse the JSON response
          final jsonResponse = json.decode(response.body);

          // Extract the "trans" field from the JSON
          final summary = jsonResponse['summary'];

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
    print(translation);
    return translation.text;
  }

  // static Future<String> translateText(String text, String languageCode) async {
  //   final url = Uri.parse(
  //       'https://google-translate113.p.rapidapi.com/api/v1/translator/text');
  //   final headers = {
  //     'content-type': 'application/x-www-form-urlencoded',
  //     'X-Rapidapi-Key': '91beb912femshe4936b9eb0c9e29p113efajsn9003840a6986',
  //     'X-Rapidapi-Host': 'google-translate113.p.rapidapi.com',
  //   };
  //   final body = {
  //     'from': 'auto',
  //     'to': languageCode,
  //     'text': text, // The text to translate
  //   };
  //
  //   try {
  //     final response = await http.post(url, headers: headers, body: body);
  //
  //     if (response.statusCode == 200) {
  //       // Parse the JSON response
  //       final jsonResponse = json.decode(response.body);
  //
  //       // Extract the "trans" field from the JSON
  //       final translation = jsonResponse['trans'];
  //
  //       // Return the translation
  //       return translation;
  //     } else {
  //       // Handle errors here, e.g., print an error message
  //       print('Request failed with status: ${response.statusCode}');
  //       print('Response: ${response.body}');
  //       print('Translation failed');
  //       return 'Translation failed'; // Return a default value or error message
  //     }
  //   } catch (e) {
  //     // Handle exceptions, e.g., network issues
  //     print('Error: $e');
  //     return 'Translation failed'; // Return a default value or error message
  //   }
  // }


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

          ArticleModel mArticleModel = ArticleModel(
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

    // Fetch news data from your data source (e.g., API)
    // Update _newsList and _loadingNews accordingly
    _loadingNews = true;

    const apiKey = "2bb4019c07fb4e9ebda44c552cc573ac";
    if (apiKey == null || apiKey.isEmpty) {
      print("API key is missing or empty");
      return; // Return early if the API key is missing or empty
    }

    final apiUrl = Uri.parse(
        "https://newsapi.org/v2/everything?q=$keyword&sortBy=publishedAt&searchIn=title,description&pageSize=50&apiKey=$apiKey");

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

          ArticleModel mArticleModel = ArticleModel(
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


  // Fetch news data and set _newsList and _loadingNews
  Future<void> fetchCategoryNews(String categoryTitle) async {
    // Fetch news data from your data source (e.g., API)
    // Update _newsList and _loadingNews accordingly
    _loadingNews = true;

    String convertedCategory = convertCategoryTitle(categoryTitle);

    newsList.clear(); //clear previous data

    const apiKey = "2bb4019c07fb4e9ebda44c552cc573ac";
    if (apiKey == null || apiKey.isEmpty) {
      print("API key is missing or empty");
      return; // Return early if the API key is missing or empty
    }

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

          // String translatedText = await translateText(data['title']);

          // Parse the input string into a DateTime object
          DateTime dateTime = DateTime.parse(inputDateString);

          // Format the DateTime object into the desired format (YYYY-MM-dd)
          String formattedDate =
              "${dateTime.year.toString().padLeft(4, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";

          ArticleModel mArticleModel = ArticleModel(
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

  // Fetch news data and set _newsList and _loadingNews
  Future<void> fetchNewsData(String categoryTitle) async {
    // Fetch news data from your data source (e.g., API)
    // Update _newsList and _loadingNews accordingly
    _loadingNews = true;

    const apiKey = "2bb4019c07fb4e9ebda44c552cc573ac";
    if (apiKey == null || apiKey.isEmpty) {
      print("API key is missing or empty");
      return; // Return early if the API key is missing or empty
    }

    final apiUrl = Uri.parse(
        "https://newsapi.org/v2/top-headlines?country=us&pageSize=100&category=$categoryTitle&apiKey=$apiKey");

    final res = await http.get(apiUrl);

    final json = jsonDecode(res.body);

    if (json['status'] == "ok") {
      for (final data in json['articles']) {
        // Check if urlToImage, description, and content are not null
        if (data['urlToImage'] != null &&
            data['description'] != null &&
            data['content'] != null) {
          // If all fields are not null, use the original values
          String inputDateString = data['publishedAt'];

          DateTime dateTime = DateTime.parse(inputDateString);

          String formattedDate =
              "${dateTime.year.toString().padLeft(4, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";

          ArticleModel mArticleModel = ArticleModel(
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
