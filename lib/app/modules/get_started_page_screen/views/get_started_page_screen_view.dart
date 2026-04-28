import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:skypeanut/app/common/colors.dart';
import 'package:skypeanut/app/data/constants/image_constants.dart';
import 'package:skypeanut/app/routes/app_pages.dart';

import '../controllers/get_started_page_screen_controller.dart';

class GetStartedPageScreenView extends GetView<GetStartedPageScreenController> {
  const GetStartedPageScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          SizedBox.expand(
            child: Image.asset(
              ImageConstants.imageGetStartedBg,
              // <-- put your image inside assets/images/
              fit: BoxFit.cover,
            ),
          ),

          // Black overlay with opacity
          Container(
            color: Colors.black.withOpacity(0.3), // 30% opacity
          ),

          // Content
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0.px, vertical: 30.px),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Skypeanut",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                // Text(
                //   "AI powered Aviation tool for everyone",
                //   textAlign: TextAlign.center,
                //   style: TextStyle(
                //     fontSize: 16,
                //     color: Colors.white,
                //   ),
                // ),
                Text(
                  "Free for early subscribers now, limited time only! Subscribe now, invite your friends and family",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 32),

                // Get Started Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor2,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      // Navigate to next screen with GetX
                      Get.toNamed(Routes
                          .ON_BOARDING_SCREEN); // Replace 'NextScreen' with your screen
                    },
                    child: const Text(
                      'Get Started',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Dummy Next Screen
class NextScreen extends StatelessWidget {
  const NextScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Next Screen')),
    );
  }
}
