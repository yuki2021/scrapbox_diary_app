import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scrapbox_diary_app/image_picker_utils/upload_image_to_gyazo.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class ImageNotifier extends StateNotifier<XFile?> {
  
  final Ref ref;
  final imagePicker = ImagePicker();

  ImageNotifier(this.ref) : super(null);
  
  Future<String> pickImage() async {
    final pickedFile = await imagePicker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      state = XFile(pickedFile.path);
      final urlString = uploadImageToGyazo(File(pickedFile.path), ref);
      return urlString;
    } else {
      throw Exception('Failed to pick image');
    }
  }

  Future<List<String>> pickImages(BuildContext context) async {
    final List<AssetEntity>? assetList = await AssetPicker.pickAssets(
      context,
      pickerConfig: const AssetPickerConfig(
        maxAssets: 5, // Change this as needed
        pathThumbnailSize: ThumbnailSize(80, 80),
        gridCount: 4,
        pageSize: 320,
        selectedAssets: <AssetEntity>[],
        themeColor: Colors.green,
      ),
    );
    if (assetList == null) {
      throw Exception('No images selected');
    } else {
      final List<String> imageUrlList = [];
      for (final asset in assetList) {
        final File? file = await asset.file;
        if (file != null) {
          final urlString = await uploadImageToGyazo(file, ref);
          imageUrlList.add(urlString);
        }
      }
      return imageUrlList;
    }
  }
}
