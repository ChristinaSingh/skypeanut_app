import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'colors.dart';

///
/// Wrap around any widget that makes an async call to show a modal progress
/// indicator while the async call is in progress.
///
/// HUD=Heads Up Display
///
class ProgressBar extends StatelessWidget {
  /// A required [bool]to toggle the loading animation.
  final bool inAsyncCall;
  final bool wantText;

  /// A [double] value which states how opaque the loading overlay should be, defaults to 0.3
  final double opacity;

  /// A [Color] object which is assigned to the loading barrier, defaults to grey
  final Color color;

  /// A [Widget] which is shown at the center of the modal loading barrier,
  /// defaults to the standard android spinny animation.
  Widget? progressIndicator;
  String? textValue;

  /// An [Offset] object which is applied to the [progressIndicator] when specified.
  final Offset? offset;

  /// A [bool] value which sets the `loading screen can be dismissible by tapping on the loading screen` rule.
  final bool dismissible;

  /// A [Widget] which should be the the widget to be shown behind the loading barrier.
  final Widget child;

  /// A [double] value specifying the amount of background blur of the progress.
  final double blur;

  ProgressBar({
    super.key,
    required this.inAsyncCall,
    this.wantText = false,
    this.opacity = .4,
    this.color = Colors.grey,
    this.progressIndicator,
    this.offset,
    this.dismissible = false,
    required this.child,
    this.blur = .8,
  });

  @override
  Widget build(BuildContext context) {
    progressIndicator ??= CupertinoActivityIndicator(
        radius: 20.0, color: primaryColor) ??
        CircularProgressIndicator(
          backgroundColor: const Color(0xff7C7C7C).withOpacity(.2),
          color: Theme.of(context).primaryColor,
          strokeCap: StrokeCap.round,
          strokeWidth: 6,
        );

    if (!inAsyncCall) return child;

    Widget layOutProgressIndicator;
    if (offset == null) {
      layOutProgressIndicator = Center(child: progressIndicator);
    } else {
      layOutProgressIndicator = Positioned(
        left: offset!.dx,
        top: offset!.dy,
        child: progressIndicator!,
      );
    }

    return Stack(
      children: [
        child,
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Opacity(
            opacity: opacity,
            child: ModalBarrier(
                dismissible: dismissible,
                color: Theme.of(context).scaffoldBackgroundColor),
          ),
        ),
        /*Center(
          child: Image.asset(
            ImageConstants.imageLoadingBar,
            height: 64.px,
            width: 64.px,
          ),
        ),*/
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            layOutProgressIndicator,
            if (wantText)
              SizedBox(
                height: 20.px,
              ),
            if (wantText)
              Text(
                  textValue ??
                      'Searching quotes from\nyour local taxi operators…',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium),
          ],
        ),
      ],
    );
  }
}
