import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skypeanut/app/common/text_styles.dart';

import '../data/constants/string_constants.dart';

class ImagePickerAndCropper {
  static Future<File?> pickImage({
    bool wantCropper = false,
    required BuildContext context,
    Color color = Colors.lightGreenAccent,
    required Color textColor,
    required Color dialogBackgroundColor,
  }) async {
    // ── Step 1: Ask user to pick source ──────────────────────────────────────
    // Return the SOURCE from the dialog, not the image itself.
    // This way showDialog completes cleanly before we call ImagePicker.
    final ImageSource? source = await showDialog<ImageSource>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext ctx) {
        return CupertinoAlertDialog(
          title: Text(
            StringConstants.selectImage,
            style: MyTextStyle.titleStyle18bbbb,
          ),
          content: Text(
            StringConstants.chooseImageFromTheOptionsBelow,
            style: MyTextStyle.titleStyle14bbbb,
          ),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              // No async here — just pop with the result
              onPressed: () => Navigator.of(ctx).pop(ImageSource.camera),
              child: Text(
                StringConstants.camera,
                style: MyTextStyle.titleStyle12bbbb,
              ),
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              // No async here — just pop with the result
              onPressed: () => Navigator.of(ctx).pop(ImageSource.gallery),
              child: Text(
                StringConstants.gallery,
                style: MyTextStyle.titleStyle12bbbb,
              ),
            ),
          ],
        );
      },
    );

    // User dismissed dialog without choosing
    if (source == null) {
      debugPrint('[ImagePicker] User cancelled source selection');
      return null;
    }

    // ── Step 2: Pick image from chosen source ─────────────────────────────────
    XFile? pickedFile;
    try {
      pickedFile = await ImagePicker().pickImage(
        source: source,
        imageQuality: 90,
        maxWidth: 1080,
        maxHeight: 1080,
      );
    } catch (e) {
      debugPrint('[ImagePicker] Pick error: $e');
      return null;
    }

    if (pickedFile == null) {
      debugPrint('[ImagePicker] User cancelled image pick');
      return null;
    }

    debugPrint('[ImagePicker] Picked: ${pickedFile.path}');

    // ── Step 3: Optional crop ─────────────────────────────────────────────────
    if (wantCropper) {
      final CroppedFile? cropped = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        compressQuality: 80,
        uiSettings: [
          AndroidUiSettings(
            toolbarColor: color,
            toolbarTitle: 'Crop Image',
            activeControlsWidgetColor: color,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: false,
            aspectRatioPresets: [
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9,
            ],
          ),
          IOSUiSettings(
            title: 'Crop Image',
            aspectRatioLockEnabled: false,
          ),
        ],
      );

      if (cropped == null) {
        debugPrint('[ImagePicker] User cancelled cropper');
        return null;
      }

      debugPrint('[ImagePicker] Cropped: ${cropped.path}');
      return File(cropped.path);
    }

    // No cropper — return raw file
    return File(pickedFile.path);
  }
}