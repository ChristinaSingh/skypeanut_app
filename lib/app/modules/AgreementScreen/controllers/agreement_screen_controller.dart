import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skypeanut/app/routes/app_pages.dart';

class AgreementScreenController extends GetxController {
  // ─── Observable state ─────────────────────────────────────────────────────
  final isChecked = false.obs;
  final isButtonLoading = false.obs; // 2-second spinner on Agree button
  final isPageLoading = true.obs; // full-screen loader while fetching API
  final hasApiError = false.obs; // show retry UI on network failure

  // ─── API data ─────────────────────────────────────────────────────────────
  final apiTitle = ''.obs;
  final apiContent = ''.obs; // cleaned, UTF-8 safe content

  // ─── Prefs ────────────────────────────────────────────────────────────────
  static const String _kAgreementKey = 'skypeanut_agreement_accepted';
  static const String _kAgreementVersion = '1.0.0'; // bump → force re-show

  // ─── Endpoint ─────────────────────────────────────────────────────────────
  static const String _termsUrl =
      'https://python.aitechnotech.in/skypeanut-api/terms-and-conditions';

  // ─── Lifecycle ────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _init();
  }

  Future<void> _init() async {
    //  final alreadyAccepted = await hasUserAccepted();
    //   if (alreadyAccepted) {
    //     _navigateToHome();
    //     return;
    //   }
    await fetchTerms();
  }

  // ─── Fetch terms ──────────────────────────────────────────────────────────
  Future<void> fetchTerms() async {
    isPageLoading.value = true;
    hasApiError.value = false;

    try {
      final response = await http.get(Uri.parse(_termsUrl), headers: {
        'accept': 'application/json'
      }).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        // ✅ Use utf8.decode on bodyBytes to avoid garbled Unicode characters
        final decoded = utf8.decode(response.bodyBytes);
        final Map<String, dynamic> data = jsonDecode(decoded);

        if (data['status'] == '1') {
          apiTitle.value = _sanitize(data['title'] ?? 'User Agreement');
          apiContent.value = _sanitize(data['content'] ?? '');
        } else {
          hasApiError.value = true;
        }
      } else {
        hasApiError.value = true;
      }
    } catch (_) {
      hasApiError.value = true;
    } finally {
      isPageLoading.value = false;
    }
  }

  // ─── Sanitize special Unicode punctuation ────────────────────────────────
  /// Replaces smart quotes, en/em dashes, ellipsis, and other fancy Unicode
  /// punctuation with plain readable equivalents so Flutter renders them
  /// correctly on all devices without garbled bytes.
  static String _sanitize(String input) {
    return input
        .replaceAll('\u201C', '"') // "  left double quotation mark
        .replaceAll('\u201D', '"') // "  right double quotation mark
        .replaceAll('\u2018', "'") // '  left single quotation mark
        .replaceAll('\u2019', "'") // '  right single quotation mark
        .replaceAll('\u2013', '-') // –  en dash
        .replaceAll('\u2014', '-') // —  em dash
        .replaceAll('\u2026', '...') // …  horizontal ellipsis
        .replaceAll('\u00e2\u0080\u009c', '"') // garbled left double quote
        .replaceAll('\u00e2\u0080\u009d', '"') // garbled right double quote
        .replaceAll('\u00e2\u0080\u0098', "'") // garbled left single quote
        .replaceAll('\u00e2\u0080\u0099', "'") // garbled right single quote
        .replaceAll('\u00e2\u0080\u0093', '-') // garbled en dash
        .replaceAll('\u00e2\u0080\u0094', '-') // garbled em dash
        .replaceAll('\u00e2\u0080\u00a6', '...'); // garbled ellipsis
  }

  // ─── Checkbox ─────────────────────────────────────────────────────────────
  void toggleCheckbox(bool? value) {
    isChecked.value = value ?? false;
  }

  // ─── Agree & Continue — 2-second minimum button loading ───────────────────
  Future<void> onAgreePressed() async {
    if (!isChecked.value || isButtonLoading.value) return;
    isButtonLoading.value = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kAgreementKey, _kAgreementVersion);

      // Guaranteed 2-second visual feedback before navigation
      await Future.delayed(const Duration(seconds: 2));

      _navigateToHome();
    } catch (_) {
      Get.snackbar(
        'Error',
        'Something went wrong. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isButtonLoading.value = false;
    }
  }

  // ─── Decline ──────────────────────────────────────────────────────────────
  void confirmExit() {
    Get.back();
    SystemNavigator.pop();
  }

  // ─── Navigation ───────────────────────────────────────────────────────────
  void _navigateToHome() {
    Get.offAllNamed(Routes.GET_STARTED_PAGE_SCREEN);
  }

  // ─── Static helper for SplashScreen ──────────────────────────────────────
  static Future<bool> hasUserAccepted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kAgreementKey) == _kAgreementVersion;
  }
}
