import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:skypeanut/app/routes/app_pages.dart';

import '../../../common/colors.dart';
import '../../../common/common_widgets.dart';
import '../../../data/constants/icons_constant.dart';
import '../controllers/ai_chat_screen_controller.dart';

class AiChatScreenView extends GetView<AiChatScreenController> {
  const AiChatScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController messageController = TextEditingController();

    return Scaffold(
      resizeToAvoidBottomInset: true, // FIXED: Proper keyboard handling
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              gradientPurple1,
              gradientPurple2,
              gradientPurple3,
              gradientPurple4,
              gradientPurple5,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header Section
              _buildHeader(),
              SizedBox(height: 10.px),

              // Chat Info Banner
              _buildChatInfo(),
              SizedBox(height: 10.px),

              // Privacy Notice
              _buildPrivacyNotice(),
              SizedBox(height: 10.px),

              // Chat Messages
              Expanded(
                child: Obx(() => ListView.builder(
                      reverse: true,
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.px, vertical: 8.px),
                      itemCount: controller.messages.length,
                      itemBuilder: (context, index) {
                        final msg =
                            controller.messages.reversed.toList()[index];
                        return _buildMessageBubble(msg);
                      },
                    )),
              ),

              // Input Area
              _buildInputArea(messageController),
              SizedBox(
                height: 10,
              )
            ],
          ),
        ),
      ),
    );
  }

  // FIXED: Proper header with all icons
  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.px, vertical: 10.px),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            child: CommonWidgets.appIconsSvg(
              assetName: IconConstants.icBackRound,
              height: 31.px,
              width: 31.px,
            ),
            onTap: () => Get.back(),
          ),
          Row(
            children: [
              // CommonWidgets.appIcons(
              //   assetName: IconConstants.icMenuSetting,
              //   height: 32.px,
              //   width: 32.px,
              // ),
              SizedBox(width: 10.px),
              // InkWell(
              //   onTap: () => Get.toNamed(Routes.AI_CHAT_SCREEN),
              //   child: CommonWidgets.appIcons(
              //     assetName: IconConstants.icAiSetting,
              //     height: 32.px,
              //     width: 32.px,
              //   ),
              // ),
              SizedBox(width: 10.px),
              InkWell(
                onTap: () {
                  Get.toNamed(Routes.NOTIFICATION_SCREEN);
                },
                child: CommonWidgets.appIcons(
                  assetName: IconConstants.icNotificationTop,
                  height: 26.px,
                  width: 26.px,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChatInfo() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.px),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundImage: AssetImage(IconConstants.icChatBot),
          ),
          SizedBox(width: 12.px),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Skypeanut AI Assistant',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Usual Reply Time: 2 Min',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // CommonWidgets.appIconsSvg(
          //   assetName: IconConstants.icMenuSettingColor,
          //   height: 32.px,
          //   width: 32.px,
          // ),
          // SizedBox(width: 10.px),
          // CommonWidgets.appIcons(
          //   assetName: IconConstants.icUploadMenu,
          //   height: 32.px,
          //   width: 32.px,
          // ),
        ],
      ),
    );
  }

  Widget _buildPrivacyNotice() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.px),
      padding: EdgeInsets.all(12.px),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.px),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.lock, color: Colors.white70, size: 16.px),
          SizedBox(width: 8.px),
          Expanded(
            child: Text(
              'End-to-end encrypted. Chat online anytime!',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 11.px,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // IMPROVED: Beautiful message bubbles with better formatting
  Widget _buildMessageBubble(ChatMessage msg) {
    final bool isUser = msg.isUser;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.px),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 16.px,
              backgroundImage: AssetImage(IconConstants.icChatBot),
            ),
            SizedBox(width: 8.px),
          ],
          Flexible(
            child: Container(
              padding: EdgeInsets.all(14.px),
              decoration: BoxDecoration(
                gradient: isUser
                    ? LinearGradient(
                        colors: [darkModeBlack, secondaryColor],
                      )
                    : null,
                color: isUser ? null : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18.px),
                  topRight: Radius.circular(18.px),
                  bottomLeft: Radius.circular(isUser ? 18.px : 4.px),
                  bottomRight: Radius.circular(isUser ? 4.px : 18.px),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: msg.isTyping
                  ? AnimatedTypingDots()
                  : _buildMessageContent(msg),
            ),
          ),
          if (isUser) SizedBox(width: 8.px),
        ],
      ),
    );
  }

  // IMPROVED: Parse and format structured data
  Widget _buildMessageContent(ChatMessage msg) {
    // Check if message contains structured data (weather/METAR)
    if (msg.text.contains('Temperature:') || msg.text.contains('METAR')) {
      return _buildStructuredDataCard(msg.text, msg.isUser);
    }

    return Text(
      msg.text,
      style: TextStyle(
        color: msg.isUser ? Colors.white : Colors.black87,
        fontSize: 14.px,
        fontWeight: FontWeight.w600,
        height: 1.4,
      ),
    );
  }

  // NEW: Beautiful card for weather/METAR data
  Widget _buildStructuredDataCard(String text, bool isUser) {
    final lines =
        text.split('\n').where((line) => line.trim().isNotEmpty).toList();

    // Parse title
    String title = lines.isNotEmpty ? lines[0] : 'Information';
    final dataLines = lines.skip(1).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.px, vertical: 6.px),
          decoration: BoxDecoration(
            color: isUser
                ? Colors.white.withOpacity(0.2)
                : darkModeBlack.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.px),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                title.contains('METAR') ? Icons.flight : Icons.thermostat,
                size: 16.px,
                color: isUser ? Colors.white : primaryColor2,
              ),
              SizedBox(width: 6.px),
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    color: isUser ? Colors.white : primaryColor2,
                    fontSize: 13.px,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10.px),

        // Data items
        ...dataLines.map((line) => _buildDataRow(line, isUser)),
      ],
    );
  }

  Widget _buildDataRow(String line, bool isUser) {
    final parts = line.split(':');
    if (parts.length >= 2) {
      final key = parts[0].trim();
      final value = parts.sublist(1).join(':').trim();

      return Padding(
        padding: EdgeInsets.symmetric(vertical: 4.px),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 4.px,
              height: 4.px,
              margin: EdgeInsets.only(top: 6.px, right: 8.px),
              decoration: BoxDecoration(
                color: isUser ? Colors.white70 : primaryColor2,
                shape: BoxShape.circle,
              ),
            ),
            Expanded(
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '$key: ',
                      style: TextStyle(
                        color: isUser ? Colors.white : Colors.black87,
                        fontSize: 13.px,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextSpan(
                      text: value,
                      style: TextStyle(
                        color: isUser
                            ? Colors.white.withOpacity(0.9)
                            : Colors.black54,
                        fontSize: 13.px,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.px),
      child: Text(
        line,
        style: TextStyle(
          color: isUser ? Colors.white.withOpacity(0.9) : Colors.black54,
          fontSize: 13.px,
        ),
      ),
    );
  }

  // FIXED: Input area with proper keyboard handling
  Widget _buildInputArea(TextEditingController messageController) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            gradientPurple2,
            gradientPurple3,
            gradientPurple4,
            gradientPurple5,
            gradientPurple1,
          ],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.px),
          topRight: Radius.circular(20.px),
        ),
      ),
      padding: EdgeInsets.only(
        left: 16.px,
        right: 16.px,
        top: 12.px,
        bottom: 12.px,
      ),
      child: Row(
        children: [
          // Text Input
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.px),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30.px),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      onSubmitted: (value) {
                        if (value.trim().isNotEmpty) {
                          controller.sendMessage(value.trim());
                          messageController.clear();
                        }
                      },
                      decoration: InputDecoration(
                        hintText: "Type a message...",
                        hintStyle: TextStyle(color: iconButtonColor),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12.px),
                      ),
                      style: TextStyle(fontSize: 15.px),
                    ),
                  ),
                  // FIXED: Mic button with proper padding
                  InkWell(
                    onTap: () => controller.startListening(),
                    child: Container(
                      padding: EdgeInsets.all(8.px),
                      // FIXED: Was EdgeInsetsGeometry
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: iconButtonColor.withOpacity(0.5),
                      ),
                      child: Icon(
                        Icons.mic,
                        color: primaryColor,
                        size: 22.px,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 8.px),

          // Send Button
          InkWell(
            onTap: () {
              final text = messageController.text.trim();
              if (text.isNotEmpty) {
                controller.sendMessage(text);
                messageController.clear();
              }
            },
            child: Container(
              width: 50.px,
              height: 50.px,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor2, primaryColor],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: primaryColor2.withOpacity(0.4),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 22.px,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// IMPROVED: Better typing animation
class AnimatedTypingDots extends StatefulWidget {
  const AnimatedTypingDots({super.key});

  @override
  _AnimatedTypingDotsState createState() => _AnimatedTypingDotsState();
}

class _AnimatedTypingDotsState extends State<AnimatedTypingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _dotAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1200),
    )..repeat();
    _dotAnimation = StepTween(begin: 0, end: 3).animate(_controller);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _dotAnimation,
      builder: (_, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 2.px),
              width: 8.px,
              height: 8.px,
              decoration: BoxDecoration(
                color: index <= _dotAnimation.value
                    ? primaryColor2
                    : Colors.grey[300],
                shape: BoxShape.circle,
              ),
            );
          }),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
