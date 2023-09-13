import 'package:intl/intl.dart';

String formatDateString(String dateString) {
  final dateFormat = DateFormat('yyyy-MM-dd');
  final date = dateFormat.parse(dateString);
  final now = DateTime.now();
  final difference = now.difference(date);

  if (difference.inDays == 0) {
    if (difference.inHours == 0) {
      if (difference.inMinutes == 0) {
        return 'Just now';
      } else {
        return '${difference.inMinutes} minutes ago';
      }
    } else {
      return '${difference.inHours} hours ago';
    }
  } else if (difference.inDays == 1) {
    return 'Yesterday';
  } else {
    return '${difference.inDays} days ago';
  }
}

