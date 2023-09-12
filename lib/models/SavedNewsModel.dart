class SavedNewsModel {

  final String title;
  final String description;
  final String imageUrl;
  final String url;
  final DateTime creationDate;
  final String userId;

  SavedNewsModel({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.url,
    required this.creationDate,
    required this.userId,
  });
}
