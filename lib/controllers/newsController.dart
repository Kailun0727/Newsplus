import 'package:flutter/foundation.dart';
import 'package:newsplus/models/ArticleModel.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class NewsController extends ChangeNotifier {
  final List<ArticleModel> _newsList = [];
  List<ArticleModel> _filteredNewsList = []; // Declare _filteredNewsList

  bool _loadingNews = true;
  String _filterKeyword = ""; // Store the filter keyword

  List<ArticleModel> get newsList => _newsList;
  List<ArticleModel> get filteredNewsList => _filteredNewsList; // Getter for filteredNewsList
  bool get loadingNews => _loadingNews;

  // Constructor
  NewsController() {}

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

    final apiUrl = Uri.parse("https://newsapi.org/v2/everything?q=$keyword&sortBy=publishedAt&searchIn=title,description&pageSize=50&apiKey=$apiKey");

    final res = await http.get(apiUrl);

    final json = jsonDecode(res.body);

    if (json['status'] == "ok") {
      json['articles'].forEach((data) {
        if (data['urlToImage'] != null && data['description'] != null && data['content'] != null) {

          String inputDateString = data['publishedAt'];

          // Parse the input string into a DateTime object
          DateTime dateTime = DateTime.parse(inputDateString);

          // Format the DateTime object into the desired format (YYYY-MM-dd)
          String formattedDate = "${dateTime.year.toString().padLeft(4, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";

          ArticleModel mArticleModel = ArticleModel(
            author: data['author'],
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


  // Fetch news data and set _newsList and _loadingNews
  Future<void> fetchNewsData() async {
    // Fetch news data from your data source (e.g., API)
    // Update _newsList and _loadingNews accordingly
    _loadingNews = true;

    const apiKey = "2bb4019c07fb4e9ebda44c552cc573ac";
    if (apiKey == null || apiKey.isEmpty) {
      print("API key is missing or empty");
      return; // Return early if the API key is missing or empty
    }

    final apiUrl = Uri.parse("https://newsapi.org/v2/top-headlines?country=us&apiKey=$apiKey");

    final res = await http.get(apiUrl);

    final json = jsonDecode(res.body);

    if (json['status'] == "ok") {
      json['articles'].forEach((data) {
        if (data['urlToImage'] != null && data['description'] != null && data['content'] != null) {

          String inputDateString = data['publishedAt'];

          // Parse the input string into a DateTime object
          DateTime dateTime = DateTime.parse(inputDateString);

          // Format the DateTime object into the desired format (YYYY-MM-dd)
          String formattedDate = "${dateTime.year.toString().padLeft(4, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";

          ArticleModel mArticleModel = ArticleModel(
            author: data['author'],
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

  // Apply filter based on keyword
  void applyFilter(String keyword) {
    _filterKeyword = keyword.toLowerCase(); // Convert to lowercase for case-insensitive filtering

    // Clear the filtered list first to avoid duplicates
    _filteredNewsList.clear();

    // Filter the newsList based on the keyword
    _filteredNewsList = _newsList.where((article) =>
    (article.title?.toLowerCase()?.contains(_filterKeyword) ?? false) ||
        (article.description?.toLowerCase()?.contains(_filterKeyword) ?? false)
    ).toList();

    notifyListeners();
  }


  // Clear the filter
  void clearFilter() {
    _filterKeyword = "";
    _filteredNewsList.clear(); // Clear the filtered list
    notifyListeners();
  }
}
