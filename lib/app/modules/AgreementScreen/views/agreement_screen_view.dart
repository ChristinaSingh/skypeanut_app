import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../controllers/agreement_screen_controller.dart';

// ─── Colour palette ───────────────────────────────────────────────────────────
const _primaryGreen = Color(0xff23F8A1);
const _primaryBlue  = Color(0xff2AB1FB);
const _gradPurple1  = Color(0xff391A49);
const _gradPurple2  = Color(0xff301D5C);
const _gradPurple3  = Color(0xff262171);
const _gradPurple6  = Color(0xff1F1A5A);
const _textLight    = Color(0xffEBECF1);
const _textGrey     = Color(0xff7D848D);
const _yellowColor  = Color(0xFFEBC240);
const _liteGreen    = Color(0xff2DC587);

// ─── Section icon + color mapping (1-indexed, matching API sections) ──────────
const _sectionMeta = [
  (Icons.check_circle_outline_rounded, _primaryGreen),  // 1. Acceptance of Terms
  (Icons.stars_rounded,                _primaryBlue),   // 2. Purpose of the App
  (Icons.person_pin_circle_outlined,   _primaryBlue),   // 3. User Responsibility
  (Icons.shield_outlined,              _yellowColor),   // 4. Limitation of Liability
  (Icons.handshake_outlined,           _liteGreen),     // 5. Indemnity
  (Icons.verified_outlined,            _primaryGreen),  // 6. No Warranty
  (Icons.gavel_rounded,                _primaryBlue),   // 7. Governing Law
  (Icons.edit_note_rounded,            _liteGreen),     // 8. Amendments
];

class AgreementScreenView extends GetView<AgreementScreenController> {
  const AgreementScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _gradPurple3,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _gradPurple1, _gradPurple2, _gradPurple3,
                _gradPurple6, _gradPurple2, _gradPurple1,
              ],
              stops: [0.0, 0.2, 0.4, 0.6, 0.8, 1.0],
            ),
          ),
          child: SafeArea(
            child: Obx(() {
              if (controller.isPageLoading.value) return _buildPageLoader();
              if (controller.hasApiError.value)   return _buildErrorState();
              return Column(
                children: [
                  _buildHeader(),
                  Expanded(child: _buildScrollableCard()),
                  _buildActionBar(context),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // FULL-SCREEN LOADER
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildPageLoader() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [_primaryGreen, _primaryBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: _primaryGreen.withOpacity(0.40),
                  blurRadius: 32,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  color: Colors.black,
                  strokeWidth: 3,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Loading Agreement...',
            style: TextStyle(
              color: _textLight,
              fontSize: 15,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Please wait a moment',
            style: TextStyle(
              color: _textGrey.withOpacity(0.7),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ERROR / RETRY
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.wifi_off_rounded,
                  color: Colors.redAccent, size: 34),
            ),
            const SizedBox(height: 20),
            const Text('Could not load agreement',
                style: TextStyle(
                    color: Colors.white, fontSize: 18,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(
              'Please check your internet connection and try again.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: _textLight.withOpacity(0.7),
                  fontSize: 13.5, height: 1.5),
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 50, width: 180,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [_primaryGreen, _primaryBlue]),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ElevatedButton.icon(
                  onPressed: controller.fetchTerms,
                  icon: const Icon(Icons.refresh_rounded,
                      color: Colors.black, size: 18),
                  label: const Text('Try Again',
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                          fontSize: 14)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // HEADER
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 10),
      child: Column(
        children: [
          // Logo glow circle
          const SizedBox(height: 14),

          // App name — gradient shimmer
          ShaderMask(
            shaderCallback: (b) => const LinearGradient(
              colors: [_primaryGreen, _primaryBlue],
            ).createShader(b),
            child: const Text('Skypeanut',
                style: TextStyle(
                    color: Colors.white, fontSize: 24,
                    fontWeight: FontWeight.w800, letterSpacing: 0.5)),
          ),
          const SizedBox(height: 6),

          // Dynamic title from API
          Obx(() => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              controller.apiTitle.value.isNotEmpty
                  ? controller.apiTitle.value
                  : 'Disclaimer & User Agreement',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _textLight,
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.2,
              ),
            ),
          )),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SCROLLABLE TERMS CARD
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildScrollableCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
              color: Colors.white.withOpacity(0.10), width: 1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Obx(() => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildIntroBanner(),
                const SizedBox(height: 20),
                ..._parseSections(controller.apiContent.value),
                const SizedBox(height: 20),
                _buildFooterHint(),
              ],
            )),
          ),
        ),
      ),
    );
  }

  // ─── Intro banner ────────────────────────────────────────────────────────
  Widget _buildIntroBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          _primaryGreen.withOpacity(0.15),
          _primaryBlue.withOpacity(0.08),
        ]),
        borderRadius: BorderRadius.circular(12),
        border:
        Border.all(color: _primaryGreen.withOpacity(0.25), width: 1),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline_rounded, color: _primaryGreen, size: 18),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'By continuing, you acknowledge and agree to the following terms:',
              style: TextStyle(
                  color: _textLight,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Footer hint ─────────────────────────────────────────────────────────
  Widget _buildFooterHint() {
    return Row(
      children: [
        const Icon(Icons.touch_app_rounded, color: _primaryGreen, size: 16),
        const SizedBox(width: 8),
        Text(
          "Tap 'Agree & Continue' to proceed.",
          style: TextStyle(
            color: _primaryGreen.withOpacity(0.85),
            fontSize: 13,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // CONTENT PARSER
  // Handles the exact API format:
  //   "1. Section Title\n   Prose text\n   • bullet\n   • bullet\n\n2. ..."
  // ─────────────────────────────────────────────────────────────────────────
  List<Widget> _parseSections(String raw) {
    if (raw.isEmpty) return [];

    final List<Widget> widgets = [];

    // Split on blank lines between sections, then find numbered headings
    // Regex: match "  1. " at start of a trimmed block
    final RegExp sectionSplitter =
    RegExp(r'\n\s*\n(?=\s*\d+\.\s)', multiLine: true);

    final blocks = raw.split(sectionSplitter);

    for (int i = 0; i < blocks.length; i++) {
      final block = blocks[i].trim();
      if (block.isEmpty) continue;

      // Split block into lines
      final lines =
      block.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
      if (lines.isEmpty) continue;

      // First line = "N. Title"
      final firstLine = lines[0];
      final titleMatch = RegExp(r'^\d+\.\s+(.+)$').firstMatch(firstLine);
      final title = titleMatch != null ? titleMatch.group(1)!.trim() : firstLine;

      // Remaining lines = prose OR bullet (starts with •)
      final bodyLines = lines.skip(1).toList();
      final List<String> prose = [];
      final List<String> bullets = [];

      for (final line in bodyLines) {
        if (line.startsWith('•')) {
          bullets.add(line.substring(1).trim()); // strip the • character
        } else {
          prose.add(line);
        }
      }

      final proseText = prose.join(' ').trim();
      final isLast = i == blocks.length - 1;

      // Pick icon/color — fall back cyclically if more than 8 sections
      final meta = _sectionMeta[i % _sectionMeta.length];

      widgets.add(
        _buildSectionCard(
          icon: meta.$1,
          iconColor: meta.$2,
          title: title,
          prose: proseText,
          bullets: bullets,
          isLast: isLast,
        ),
      );
    }

    return widgets;
  }

  // ─── Section card ─────────────────────────────────────────────────────────
  Widget _buildSectionCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String prose,
    required List<String> bullets,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon chip
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.13),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 19),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section title (bold white)
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.15,
                    height: 1.3,
                  ),
                ),

                // Prose paragraph
                if (prose.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    prose,
                    style: const TextStyle(
                      color: _textLight,
                      fontSize: 13,
                      height: 1.65,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],

                // Bullet list
                if (bullets.isNotEmpty) ...[
                  const SizedBox(height: 7),
                  ...bullets.map(
                        (b) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Dot
                          Padding(
                            padding: const EdgeInsets.only(top: 7),
                            child: Container(
                              width: 5, height: 5,
                              decoration: BoxDecoration(
                                color: iconColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          const SizedBox(width: 9),
                          Expanded(
                            child: Text(
                              b,
                              style: const TextStyle(
                                color: _textLight,
                                fontSize: 13,
                                height: 1.60,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BOTTOM ACTION BAR
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildActionBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.08), width: 1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Checkbox ──────────────────────────────────────────────────────
          Obx(() => GestureDetector(
            onTap: () => controller
                .toggleCheckbox(!controller.isChecked.value),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 24, height: 24,
                  decoration: BoxDecoration(
                    color: controller.isChecked.value
                        ? _primaryGreen
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: controller.isChecked.value
                          ? _primaryGreen
                          : _textLight.withOpacity(0.45),
                      width: 2,
                    ),
                  ),
                  child: controller.isChecked.value
                      ? const Icon(Icons.check,
                      color: Colors.black, size: 16)
                      : null,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'I have read and agree to the Terms & Conditions',
                    style: TextStyle(
                      color: _textLight,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          )),

          const SizedBox(height: 14),

          // ── Agree & Continue button ────────────────────────────────────────
          Obx(() {
            final checked = controller.isChecked.value;
            final loading = controller.isButtonLoading.value;

            return SizedBox(
              width: double.infinity,
              height: 52,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: checked ? 1.0 : 0.38,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: checked
                        ? const LinearGradient(
                      colors: [_primaryGreen, _primaryBlue],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    )
                        : const LinearGradient(
                      colors: [Color(0xFF4A4A6A), Color(0xFF3A3A5A)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: checked
                        ? [
                      BoxShadow(
                        color: _primaryGreen.withOpacity(0.32),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ]
                        : [],
                  ),
                  child: ElevatedButton(
                    onPressed: (checked && !loading)
                        ? controller.onAgreePressed
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      disabledBackgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    // ── Button content ──────────────────────────────────────
                    child: loading
                        ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.black,
                            strokeWidth: 2.5,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Processing...',
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.75),
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    )
                        : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Agree & Continue',
                          style: TextStyle(
                            color: checked
                                ? Colors.black
                                : _textLight.withOpacity(0.45),
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.arrow_forward_rounded,
                            color: checked
                                ? Colors.black
                                : _textLight.withOpacity(0.45),
                            size: 18),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),

          const SizedBox(height: 10),

          // ── Decline & Exit ─────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 46,
            child: TextButton(
              onPressed: () => _showDeclineDialog(context),
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(
                      color: Colors.white.withOpacity(0.12), width: 1),
                ),
              ),
              child: const Text(
                'Decline & Exit',
                style: TextStyle(
                  color: _textGrey,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // DECLINE DIALOG
  // ─────────────────────────────────────────────────────────────────────────
  void _showDeclineDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xff2A1C4A),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Leave Skypeanut?',
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 18),
        ),
        content: const Text(
          'You must accept the Terms & Conditions to use Skypeanut. '
              'Declining will close the app.',
          style: TextStyle(color: _textLight, fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Go Back',
                style: TextStyle(
                    color: _primaryGreen,
                    fontWeight: FontWeight.w600)),
          ),
          TextButton(
            onPressed: controller.confirmExit,
            child: const Text('Exit App',
                style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}