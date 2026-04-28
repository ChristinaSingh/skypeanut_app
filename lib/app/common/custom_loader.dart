import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../data/constants/icons_constant.dart';
import 'colors.dart';
import 'common_widgets.dart';

class CustomLoader extends StatelessWidget {
  final bool inAsyncCall;
  final Widget? child;
  final double? width;
  final double? height;
  final bool overlapped;
  final Color? backgroundColor;

  const CustomLoader({
    super.key,
    required this.inAsyncCall,
    this.width,
    this.height,
    this.child,
    this.backgroundColor,
    this.overlapped = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        /// Main Content (Blurry when Loading)
        if (child != null)
          child!,

        /// Blur Background Effect
        if (inAsyncCall)
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0), // Blur effect
              child: Container(
                color: backgroundColor?.withOpacity(0.2) ?? Colors.black.withOpacity(0.2),
              ),
            ),
          ),

        /// Circular Loader with Glowing Effect
        if (inAsyncCall)
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                /// Animated Circular Progress Indicator with Glow Effect
                SizedBox(
                  width: 80,
                  height: 80,
                  child: ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return const LinearGradient(
                        colors: [primaryColor, greenColor, Colors.greenAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds);
                    },
                    child: const CircularProgressIndicator(
                      strokeWidth: 6,
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    ),
                  ),
                ),

                /// App Logo in Center
                ClipRRect(
                  borderRadius: BorderRadius.circular(15), // Rounded edges
                  child:  CommonWidgets.appIcons(
                      assetName: IconConstants.icLogo,
                      width: 30.px,
                      height: 30.px,
                      fit: BoxFit.fill)
                ),
              ],
            ),
          ),
      ],
    );
  }
}
