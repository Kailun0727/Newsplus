class ReplyModel {
  final String replyId;
  final String postId;
  String content;
  final String creationDate;
  int likesCount;
  int reportCount;
  bool hidden;
  final String userId;
  final String username;
  final String photoUrl;

  ReplyModel({
    required this.replyId,
    required this.postId,
    required this.content,
    required this.creationDate,
    required this.likesCount,
    required this.reportCount,
    required this.hidden,
    required this.userId,
    required this.username,
    required this.photoUrl
  });


}
