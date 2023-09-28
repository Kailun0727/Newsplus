class PostModel {
  final String postId;
  String title;
  String content;
  final String creationDate;
  int likesCount;
  int reportCount;
  bool hidden;
  final String userId;
  final String username;
  final String photoUrl;
  String communityId;

  PostModel({
    required this.postId,
    required this.title,
    required this.content,
    required this.creationDate,
    required this.likesCount,
    required this.reportCount,
    required this.hidden,
    required this.userId,
    required this.username,
    required this.photoUrl,
    required this.communityId
  });


}
