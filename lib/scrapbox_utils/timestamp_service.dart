// timestamp_service.dart

import 'package:hooks_riverpod/hooks_riverpod.dart';

final timestampServiceProvider = Provider((ref) => TimestampService());

class TimestampService {
  Future<String> getScrapboxUrl(String currentUrl, DateTime now) async {
    final scrapboxProject =
        RegExp(r"scrapbox\.io/([^/.]*)").firstMatch(currentUrl)![1];
    final year = now.year;
    final month = now.month;
    final day = now.day;
    final date =
        '$year/${month.toString().padLeft(2, '0')}/${day.toString().padLeft(2, '0')}';
    final title = Uri.encodeComponent(date);
    final hour = now.hour;
    final minute = now.minute;
    final second = now.second;
    final body = Uri.encodeComponent('\t$date $hour:$minute:$second');
    final scrapboxUrl =
        'https://scrapbox.io/$scrapboxProject/$title?body=$body';

    return scrapboxUrl;
  }
}