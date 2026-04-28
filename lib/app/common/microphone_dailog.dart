import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:skypeanut/app/common/common_widgets.dart';
import 'package:skypeanut/app/data/constants/icons_constant.dart';

import 'colors.dart';

class LocationPermissionDialog extends StatelessWidget {
  final VoidCallback onAllow;
  final VoidCallback onCancel;

  const LocationPermissionDialog({
    super.key,
    required this.onAllow,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 12,
      backgroundColor: darkModeBlack,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            CommonWidgets.appIcons(
                assetName: IconConstants.icLocationPermission,
                height: 140.px,
                width: 140.px),
            const SizedBox(height: 30),
            Text(
              "Location permission needed",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 20.px,
                  color: textColorLite,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 30),
            Text(
              "Please enable location permission to get more accurate weather information",
              style: TextStyle(
                  color: textColorLite,
                  fontSize: 14.px,
                  fontWeight: FontWeight.w400),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor2,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: onAllow,
              child: Text(
                "Allow location",
                style: TextStyle(
                    color: allowColor,
                    fontSize: 16.px,
                    fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
