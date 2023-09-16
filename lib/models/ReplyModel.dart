class ReplyModel {
  final String replyId;
  final String postId;
  final String content;
  final String creationDate;
  int likesCount;
  int reportCount;
  bool hidden;
  final String userId;
  final String username;

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
  });


}
