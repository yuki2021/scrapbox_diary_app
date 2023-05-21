import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:scrapbox_diary_app/scrapbox_utils/date_picker.dart';

final datePickerProvider =
    StateNotifierProvider<DatePickerState, DateTime>((ref) {
  return DatePickerState();
});
