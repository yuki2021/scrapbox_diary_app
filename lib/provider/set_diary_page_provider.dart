import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:scrapbox_diary_app/scrapbox_utils/set_diary_page.dart';

final setDiaryPageProvider = Provider.family<SetDiaryPage, String>(
    (ref, currentUrl) => SetDiaryPage(ref, currentUrl));
