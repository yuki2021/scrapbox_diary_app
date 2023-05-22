import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:scrapbox_diary_app/widget/speed_dial_widget.dart';

final speedDialProvider = Provider<SpeedDialState>((ref) {
  return SpeedDialState(ref);
});
