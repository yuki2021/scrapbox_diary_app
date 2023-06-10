import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scrapbox_diary_app/image_picker_utils/pick_image_from_camera.dart';

final imageNotifierProvider =
    StateNotifierProvider<ImageNotifier, XFile?>((ref) => ImageNotifier());
