import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:skypeanut/app/common/colors.dart';

class CommonMethods {
  static const String cur = '\$';

  static void unFocsKeyBoard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  static Widget textViewLinearGradient(
      {String? text,
        bool? value,
        TextStyle? style,
        bool primaryColor = false,
        }) =>
      Center(
        child: GradientWidget(
          text: text,
          style: style ??
              Theme.of(Get.context!)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
          gradient: value ?? true
              ? primaryColor
              ? commonLinearGradientViewPrimary(context: Get.context!)
              : commonLinearGradientView(context: Get.context!)
              : primaryColor
              ? commonLinearGradientViewBlack(context: Get.context!)
              : commonLinearGradientViewGrey(context: Get.context!),
        ),
      );

  static Widget iconLinearGradient(
      {required String assetName,
        double? width,
        double? height,
        bool? value,
        bool primaryColor = false,}) =>
      Center(
        child: GradientWidget(
          gradient: value ?? true
              ? primaryColor
              ? commonLinearGradientViewPrimary(context: Get.context!)
              : commonLinearGradientView(context:  Get.context!)
              : primaryColor
              ? commonLinearGradientViewBlack(context:  Get.context!)
              : commonLinearGradientViewGrey(context:  Get.context!),
          child: appIcons(assetName: assetName, width: width, height: height),
        ),
      );

  static Widget appIcons(
      {required String assetName,
        double? width,
        double? height,
        Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(
          assetName,
          height: height ?? 24.px,
          width: width ?? 24.px,
          color: color,
        ),
      ],
    );
  }


  static LinearGradient commonLinearGradientViewPrimary(
      {required BuildContext context}) =>
      LinearGradient(
        end: Alignment.topCenter,
        begin: Alignment.bottomCenter,
        colors: [
          primaryColor2,
          primaryColor2,
        ],
      );


  static LinearGradient commonLinearGradientView(
      {required BuildContext context}) =>
      LinearGradient(
        end: Alignment.centerLeft,
        begin: Alignment.centerRight,
        colors: [
          Color(0XFF1E88E5),
          Color(0XFF26C6DA),
        ],
      );

  static LinearGradient commonLinearGradientViewBlack(
      {required BuildContext context}) =>
      const LinearGradient(
        end: Alignment.topCenter,
        begin: Alignment.bottomCenter,
        colors: [
          textColorLite,
          textColorLite,
        ],
      );

  static LinearGradient commonLinearGradientViewGrey(
      {required BuildContext context}) =>
      LinearGradient(
        end: Alignment.topCenter,
        begin: Alignment.bottomCenter,
        colors: [
          Theme.of(context).colorScheme.surface,
          Theme.of(context).colorScheme.surface,
        ],
      );



}

class GradientWidget extends StatelessWidget {
  const GradientWidget({
    super.key,
    this.text,
    required this.gradient,
    this.style,
    this.child,
  });

  final String? text;
  final TextStyle? style;
  final Widget? child;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: child ?? Text(text ?? '', style: style),
    );
  }
}
