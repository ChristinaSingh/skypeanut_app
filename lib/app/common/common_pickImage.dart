import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'colors.dart';

Future<File?> getImagePicker(BuildContext context) {
  Completer<File?> completer = Completer<File?>();

  void showAlertDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return MyAlertDialog(
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              child: Text(
                'Camera',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontSize: 10,
                      color: Theme.of(context).primaryColor,
                    ),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                File? image = await getImageFromCamera();
                completer.complete(image);
              },
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              child: Text(
                'Gallery',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontSize: 10,
                      color: Theme.of(context).primaryColor,
                    ),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                File? image = await getImageFromGallery();
                completer.complete(image);
              },
            ),
          ],
          title: Text(
            'Select Image',
            style: Theme.of(context)
                .textTheme
                .displayMedium
                ?.copyWith(fontSize: 18),
          ),
          content: Text(
            'Choose image from the options below',
            style:
                Theme.of(context).textTheme.titleSmall?.copyWith(fontSize: 14),
          ),
        );
      },
    );
  }

  showAlertDialog();

  return completer.future;
}

Future<File?> getImageFromCamera() async {
  final picker = ImagePicker();
  final pickedFile = await picker.pickImage(source: ImageSource.camera);
  if (pickedFile != null) {
    print("Image :-${pickedFile.path}");
    return File(pickedFile.path);
  } else {
    print("Image not picked....");
    return null;
  }
}

Future<File?> getImageFromGallery() async {
  final picker = ImagePicker();
  final pickedFile = await picker.pickImage(source: ImageSource.gallery);
  if (pickedFile != null) {
    print("Image :-${pickedFile.path}");
    return File(pickedFile.path);
  } else {
    print("Image not picked....");
    return null;
  }
}

class MyAlertDialog extends StatelessWidget {
  final Widget? title;
  final Widget? content;
  final List<Widget> actions;

  const MyAlertDialog(
      {super.key, this.title, this.content, required this.actions});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        dialogTheme: DialogThemeData(backgroundColor: primaryColor),
      ),
      child: CupertinoAlertDialog(
        title: title,
        content: content,
        actions: actions,
        insetAnimationDuration: const Duration(seconds: 1),
      ),
    );
  }
}
