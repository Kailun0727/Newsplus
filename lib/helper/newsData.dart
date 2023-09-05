import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:newsplus/models/ArticleModel.dart';

class News {
  List<ArticleModel> newsList = [];

  Future<void> getNewsData() async {
    final apiKey = "2bb4019c07fb4e9ebda44c552cc573ac"; // Replace with your actual API key
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


          ArticleModel mArticleModel = ArticleModel(
            author: data['author'],
            description: data['description'],
            title: data['title'],
            content: data['content'],
            url: data['url'],
            urlToImage: data['urlToImage'],
          );



          newsList.add(mArticleModel);

        }
      });
    }
  }
}
