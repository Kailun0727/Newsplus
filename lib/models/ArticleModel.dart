class ArticleModel {
  String? author;
  String? url;
  String? urlToImage;
  String? title;
  String? description;
  String? publishedAt;
  String? content;

  ArticleModel(
      {required this.author,
      required this.description,
      required this.publishedAt,
      required this.title,
      required this.content,
      required this.url,
      required this.urlToImage});
}
