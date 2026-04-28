import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skypeanut/app/common/colors.dart';

import '../../../common/spiral_loader.dart';
import '../controllers/loader_screen_controller.dart';

class LoaderScreenView extends GetView<LoaderScreenController> {
  const LoaderScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Obx(() {
      controller.count.value;
      return Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              gradientPurple1, // Dark purple top
              gradientPurple2,
              gradientPurple3,
              gradientPurple4,
              gradientPurple5, // Deep blue bottom
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SpiralLoader(),
            const SizedBox(height: 40),
            const Text(
              'Loading',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      );
    }));
  }
}
