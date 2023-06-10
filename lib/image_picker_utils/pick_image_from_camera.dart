import 'dart:io';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scrapbox_diary_app/image_picker_utils/upload_image_to_gyazo.dart';

class ImageNotifier extends StateNotifier<XFile?> {
  ImageNotifier() : super(null);
  final imagePicker = ImagePicker();

  Future<String> pickImage() async {
    final pickedFile = await imagePicker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      state = XFile(pickedFile.path);
      final urlString = uploadImageToGyazo(File(pickedFile.path));
      return urlString;
    } else {
      throw Exception('Failed to pick image');
    }
  }
}

