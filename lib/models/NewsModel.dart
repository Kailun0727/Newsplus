class NewsModel {

  String? url;
  String? urlToImage;
  String? title;
  String? description;
  String? publishedAt;
  String? content;

  NewsModel(
      {
      this.description,
      required this.publishedAt,
      required this.title,
        this.content,
      required this.url,
      this.urlToImage});
}
