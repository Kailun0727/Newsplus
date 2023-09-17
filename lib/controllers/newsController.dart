import 'dart:math';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:newsplus/models/ArticleModel.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:newsplus/models/SavedNewsModel.dart';
import 'package:intl/intl.dart';

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

  // Constructor
  NewsController() {}


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

  Future<String> translateText(String text) async {
    final url = Uri.parse(
        'https://google-translate113.p.rapidapi.com/api/v1/translator/text');
    final headers = {
      'content-type': 'application/x-www-form-urlencoded',
      'X-Rapidapi-Key': '91beb912femshe4936b9eb0c9e29p113efajsn9003840a6986',
      'X-Rapidapi-Host': 'google-translate113.p.rapidapi.com',
    };
    final body = {
      'from': 'auto',
      'to': 'zh-CN',
      'text': text, // The text to translate
    };

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        // Parse the JSON response
        final jsonResponse = json.decode(response.body);

        // Extract the "trans" field from the JSON
        final translation = jsonResponse['trans'];

        // Return the translation
        return translation;
      } else {
        // Handle errors here, e.g., print an error message
        print('Request failed with status: ${response.statusCode}');
        print('Response: ${response.body}');
        return 'Translation failed'; // Return a default value or error message
      }
    } catch (e) {
      // Handle exceptions, e.g., network issues
      print('Error: $e');
      return 'Translation failed'; // Return a default value or error message
    }
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
        } else {
          // If any of the fields is null, assign default values
          String inputDateString = data['publishedAt'];

          DateTime dateTime = DateTime.parse(inputDateString);

          String formattedDate =
              "${dateTime.year.toString().padLeft(4, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";

          ArticleModel mArticleModel = ArticleModel(
            title: data['title'],
            publishedAt: formattedDate,
            url: data['url'],
          );

          if (data['urlToImage'] == null) {
            // If urlToImage is null, assign a default image URL
            mArticleModel.urlToImage =
                'https://upload.wikimedia.org/wikipedia/commons/d/d1/Image_not_available.png';
          } else {
            // If urlToImage is not null, use the original value
            mArticleModel.urlToImage = data['urlToImage'];
          }

          if (data['description'] == null) {
            // If description is null, assign a default description
            mArticleModel.description = 'Click the news for more details.';
          } else {
            // If description is not null, use the original value
            mArticleModel.description = data['description'];
          }

          if (data['content'] == null) {
            // If content is null, assign a default content
            mArticleModel.content = 'Click the news for more details.';
          } else {
            // If content is not null, use the original value
            mArticleModel.content = data['content'];
          }

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

    List<String> countryList = [
      'ae',
      'ar',
      'at',
      'au',
      'be',
      'bg',
      'br',
      'ca',
      'ch',
      'cn',
      'co',
      'cu',
      'cz',
      'de',
      'eg',
      'fr',
      'gb',
      'gr',
      'hk',
      'hu',
      'id',
      'ie',
      'il',
      'in',
      'it',
      'jp',
      'kr',
      'lt',
      'lv',
      'ma',
      'mx',
      'my',
      'ng',
      'nl',
      'no',
      'nz',
      'ph',
      'pl',
      'pt',
      'ro',
      'rs',
      'ru',
      'sa',
      'se',
      'sg',
      'si',
      'sk',
      'th',
      'tr',
      'tw',
      'ua',
      'us',
      've',
      'za'
    ];

    Random random = Random();
    int randomIndex = random.nextInt(countryList.length);
    String selectedCountry = countryList[randomIndex];

    final apiUrl = Uri.parse(
        "https://newsapi.org/v2/top-headlines?country=my&pageSize=100&category=Technology&apiKey=$apiKey");

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
        } else {
          // If any of the fields is null, assign default values
          String inputDateString = data['publishedAt'];

          DateTime dateTime = DateTime.parse(inputDateString);

          String formattedDate =
              "${dateTime.year.toString().padLeft(4, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";

          ArticleModel mArticleModel = ArticleModel(
            title: data['title'],
            publishedAt: formattedDate,
            url: data['url'],
          );

          if (data['urlToImage'] == null) {
            // If urlToImage is null, assign a default image URL
            mArticleModel.urlToImage =
                'https://upload.wikimedia.org/wikipedia/commons/d/d1/Image_not_available.png';
          } else {
            // If urlToImage is not null, use the original value
            mArticleModel.urlToImage = data['urlToImage'];
          }

          if (data['description'] == null) {
            // If description is null, assign a default description
            mArticleModel.description = 'Click the news for more details.';
          } else {
            // If description is not null, use the original value
            mArticleModel.description = data['description'];
          }

          if (data['content'] == null) {
            // If content is null, assign a default content
            mArticleModel.content = 'Click the news for more details.';
          } else {
            // If content is not null, use the original value
            mArticleModel.content = data['content'];
          }

          _newsList.add(mArticleModel);
        }
      }

      // json['articles'].forEach((data) async {
      //   if (data['urlToImage'] != null && data['description'] != null && data['content'] != null) {
      //
      //     String inputDateString = data['publishedAt'];
      //
      //     String translatedText = await translateText(data['title']);
      //
      //
      //     // Parse the input string into a DateTime object
      //     DateTime dateTime = DateTime.parse(inputDateString);
      //
      //     // Format the DateTime object into the desired format (YYYY-MM-dd)
      //     String formattedDate = "${dateTime.year.toString().padLeft(4, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";
      //
      //     ArticleModel mArticleModel = ArticleModel(
      //       author: data['author'],
      //       description: data['description'],
      //       title: data['title'],
      //       content: data['content'],
      //       publishedAt: formattedDate,
      //       url: data['url'],
      //       urlToImage: data['urlToImage'],
      //     );
      //     _newsList.add(mArticleModel);
      //   }
      // });
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
