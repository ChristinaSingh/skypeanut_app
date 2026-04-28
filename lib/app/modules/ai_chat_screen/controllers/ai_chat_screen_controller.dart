import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart';
import 'package:uuid/uuid.dart'; // ✅ NEW import

class AiChatScreenController extends GetxController {
  final count = 0.obs;
  final isListening = false.obs;
  final isSending = false.obs;
  final recognizedWords = ''.obs;
  final SpeechToText speech = SpeechToText();

  // ✅ Unique sender ID — generated fresh every session
  late final String senderID;

  // Live GPS coordinates
  RxString lat = "".obs;
  RxString long = "".obs;

  var messages = <ChatMessage>[].obs;

  // ── Generate Unique Sender ID ──────────────────
  // Called once in onInit(). Every new session gets a brand-new ID.
  // Format: "user_<short-uuid>"  →  e.g. "user_a3f8b2c1"
  String _generateSenderID() {
    const uuid = Uuid();

    // ✅ Option 1 — Full UUID (guaranteed unique)
    // e.g. "user_550e8400-e29b-41d4-a716-446655440000"
    // return "user_${uuid.v4()}";

    // ✅ Option 2 — Short readable ID (first 8 chars of UUID + timestamp)
    final shortId = uuid.v4().split('-').first; // 8 hex chars
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return "user_${shortId}_$timestamp";

    // Example output: "user_a3f8b2c1_1718456723456"
  }

  // ── Voice Recognition ──────────────────────────
  Future<void> startListening() async {
    if (speech.isListening || isListening.value) {
      print("Already listening");
      return;
    }

    try {
      final available = await speech.initialize(
        onStatus: (status) => print("Speech status: $status"),
        onError: (error) {
          print("Speech error: $error");
          Get.snackbar(
            "Voice Error",
            "Speech recognition failed. Please try again.",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
          );
          stopListening();
        },
      );

      if (!available) {
        Get.snackbar(
          "Not Available",
          "Speech recognition is not available on this device.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
        return;
      }

      isListening.value = true;
      recognizedWords.value = "";

      await speech.listen(
        onResult: (result) => recognizedWords.value = result.recognizedWords,
        localeId: "en_IN",
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        cancelOnError: true,
      );

      Get.dialog(
        _MicDialog(controller: this),
        barrierDismissible: false,
      );
    } catch (e) {
      print("Speech Exception: $e");
      Get.snackbar(
        "Error",
        "Failed to start voice recognition.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      stopListening();
    }
  }

  void stopListening({bool sendMessage = false}) {
    if (speech.isListening) speech.stop();

    if (sendMessage && recognizedWords.value.trim().isNotEmpty) {
      this.sendMessage(recognizedWords.value.trim());
    }

    isListening.value = false;
    recognizedWords.value = "";

    if (Get.isDialogOpen ?? false) Get.back();
  }

  // ── Send Message to Rasa API ───────────────────
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    if (isSending.value) {
      print("Already sending a message, ignoring duplicate call.");
      return;
    }

    isSending.value = true;

    messages.add(ChatMessage(text: text, isUser: true));

    final typingMsg =
    ChatMessage(text: "Typing...", isUser: false, isTyping: true);
    messages.add(typingMsg);

    try {
      final url =
      Uri.parse('https://python.aitechnotech.in/skypeanut/webhooks/rest/webhook');

      final double userLat = double.tryParse(lat.value) ?? 0.0;
      final double userLong = double.tryParse(long.value) ?? 0.0;

      // ✅ Uses the unique senderID instead of hardcoded string
      final requestBody = {
        "sender": senderID,
        "message": text,
        "metadata": {
          "user_latitude": userLat,
          "user_longitude": userLong,
        },
      };

      // Debug prints
      print("------ CHAT REQUEST DEBUG ------");
      print("URL: $url");
      print("Sender ID: $senderID"); // ✅ Log the unique sender
      print("Message: $text");
      print("Latitude  (live): $userLat");
      print("Longitude (live): $userLong");
      print("Request Body: ${jsonEncode(requestBody)}");
      print("--------------------------------");

      final response = await http
          .post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      )
          .timeout(const Duration(seconds: 30));

      print("------ CHAT RESPONSE DEBUG ------");
      print("Status Code: ${response.statusCode}");
      print("Raw Body: ${response.body}");
      print("--------------------------------");

      messages.remove(typingMsg);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        print("Decoded Response: $decoded");

        if (decoded is List && decoded.isNotEmpty) {
          final Set<String> seenTexts = {};

          for (var msg in decoded) {
            print("Bot Message: ${msg['text']}");
            final msgText = msg['text']?.toString().trim() ?? '';

            if (msgText.isNotEmpty && seenTexts.add(msgText)) {
              messages.add(ChatMessage(
                text: msgText,
                isUser: false,
              ));
            } else if (msgText.isNotEmpty) {
              print("Duplicate message skipped: $msgText");
            }
          }
        } else {
          print("Empty bot response");
          messages.add(ChatMessage(
            text:
            "I received your message but couldn't generate a response.",
            isUser: false,
          ));
        }
      } else {
        print("Server Error: ${response.statusCode}");
        messages.add(ChatMessage(
          text: "Sorry, I'm having trouble connecting. "
              "Please try again. (Error: ${response.statusCode})",
          isUser: false,
        ));
      }
    } catch (e, stackTrace) {
      print("------ CHAT ERROR ------");
      print("Error: $e");
      print("StackTrace: $stackTrace");
      print("------------------------");

      messages.remove(typingMsg);

      String errorMsg = "Sorry, I couldn't process your request.";
      if (e.toString().contains('TimeoutException')) {
        errorMsg =
        "Request timed out. Please check your connection and try again.";
      } else if (e.toString().contains('SocketException')) {
        errorMsg = "No internet connection. Please check your network.";
      }

      messages.add(ChatMessage(text: errorMsg, isUser: false));
    } finally {
      isSending.value = false;
    }
  }

  // ── Lifecycle ──────────────────────────────────
  @override
  void onInit() {
    super.onInit();

    // ✅ Generate unique sender ID for this session
    senderID = _generateSenderID();
    print("═══════════════════════════════════════");
    print("  NEW CHAT SESSION");
    print("  Sender ID: $senderID");
    print("═══════════════════════════════════════");

    getCurrentLocation();
    messages.add(ChatMessage(
      text: "Hello! How can I assist with your flight today?",
      isUser: false,
    ));
  }

  @override
  void onClose() {
    if (speech.isListening) speech.stop();
    print("Chat session ended for sender: $senderID");
    super.onClose();
  }

  // ── GPS Location ───────────────────────────────
  Future<void> getCurrentLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      print('Location permission denied');
      return;
    }

    try {
      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      lat.value = position.latitude.toString();
      long.value = position.longitude.toString();

      print("Live location → lat: ${lat.value}, long: ${long.value}");
    } catch (e) {
      print("Location error: $e");
    }
  }

  void increment() => count.value++;
}

// ─────────────────────────────────────────────
//  CHAT MESSAGE MODEL
// ─────────────────────────────────────────────

class ChatMessage {
  final String text;
  final bool isUser;
  final bool isTyping;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.isTyping = false,
  }) : timestamp = DateTime.now();
}

// ─────────────────────────────────────────────
//  MIC DIALOG
// ─────────────────────────────────────────────

class _MicDialog extends StatelessWidget {
  final AiChatScreenController controller;
  const _MicDialog({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(() => Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: controller.isListening.value
                      ? [Colors.deepPurple, Colors.purpleAccent]
                      : [Colors.grey, Colors.grey[400]!],
                ),
                boxShadow: controller.isListening.value
                    ? [
                  BoxShadow(
                    color: Colors.deepPurple.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ]
                    : [],
              ),
              child:
              const Icon(Icons.mic, size: 40, color: Colors.white),
            )),
            const SizedBox(height: 24),
            Obx(() => Text(
              controller.isListening.value ? "Listening..." : "Stopped",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            )),
            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 120),
              child: SingleChildScrollView(
                child: Obx(() => Text(
                  controller.recognizedWords.value.isEmpty
                      ? "Speak now..."
                      : controller.recognizedWords.value,
                  style:
                  TextStyle(fontSize: 16, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                )),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () =>
                      controller.stopListening(sendMessage: false),
                  icon: const Icon(Icons.close, size: 18),
                  label: const Text("Cancel"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                Obx(() => ElevatedButton.icon(
                  onPressed:
                  controller.recognizedWords.value.trim().isEmpty
                      ? null
                      : () => controller.stopListening(
                      sendMessage: true),
                  icon: const Icon(Icons.send, size: 18),
                  label: const Text("Send"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    disabledBackgroundColor: Colors.grey[300],
                  ),
                )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}