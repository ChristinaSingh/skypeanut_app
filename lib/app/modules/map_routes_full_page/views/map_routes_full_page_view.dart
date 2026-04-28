import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../../common/colors.dart';
import '../../../common/common_widgets.dart';
import '../../../data/constants/icons_constant.dart';
import '../../../routes/app_pages.dart';
import '../controllers/map_routes_full_page_controller.dart';

class MapRoutesFullPageView extends GetView<MapRoutesFullPageController> {
  const MapRoutesFullPageView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<MapRoutesFullPageController>();
    return Scaffold(
      backgroundColor: Colors.black,
      body: _MapWebViewBody(controller: ctrl),
    );
  }
}

class _MapWebViewBody extends StatefulWidget {
  final MapRoutesFullPageController controller;

  const _MapWebViewBody({required this.controller});

  @override
  State<_MapWebViewBody> createState() => _MapWebViewBodyState();
}

class _MapWebViewBodyState extends State<_MapWebViewBody> {
  late InAppWebViewController _webViewController;
  final RxBool _mapReady = false.obs;

  static const _webUrl = "https://globe.adsbexchange.com/";

  // ── Injected on onPageCommitVisible — forces mobile viewport EARLY
  static const String _viewportScript = r"""
  (function() {
    var meta = document.querySelector('meta[name="viewport"]');
    if (!meta) {
      meta = document.createElement('meta');
      meta.name = 'viewport';
      document.head.appendChild(meta);
    }
    meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';
  })();
  """;

  // ── Main cleanup — only hides specific named elements, NEVER touches #map
  static const String _cleanupScript = r"""
  (function() {

    var existing = document.getElementById('__fc__');
    if (existing) existing.remove();

    var style = document.createElement('style');
    style.id = '__fc__';
    style.innerHTML = `
      html, body {
        margin: 0 !important;
        padding: 0 !important;
        width: 100vw !important;
        height: 100vh !important;
        overflow: hidden !important;
        background: #000 !important;
      }

      #map,
      #cesiumContainer,
      .leaflet-container {
        position: fixed !important;
        top: 0 !important;
        left: 0 !important;
        width: 100vw !important;
        height: 100vh !important;
        z-index: 1 !important;
        margin: 0 !important;
        padding: 0 !important;
      }

      #sidebar, #sidebar-toggle, .globeSidebar,
      #searchbar, #search-wrapper, #search_form,
      #toolbar, .top-bar,
      #infoblock, #infoblockBottom,
      #selected_ac_data, #acList, #acListBody, #acList2,
      #routeData, #notam, #statsblock,
      .globeFooter, #globeFooter, #adsb-logo,
      #helppage, #showFlags, #layer-chooser, #range-rings,
      #mapControls, #mapButtons, #planeList, #flightList,
      #bottombar, #bottom-bar, #status-bar,
      #scale, #version, #message_block, .top_message_block,
      .leaflet-control-zoom,
      .leaflet-control-attribution,
      .leaflet-control-layers,
      .leaflet-bar,
      .leaflet-popup,
      .leaflet-popup-pane,
      .scale-line,
      header, footer, nav, iframe {
        display: none !important;
        visibility: hidden !important;
        pointer-events: none !important;
      }

      div[id*="advert"]:not([id*="map"]),
      div[class*="advert"]:not([class*="map"]),
      div[id*="banner"]:not([id*="map"]),
      div[class*="banner"]:not([class*="map"]),
      div[id*="gdpr"], div[class*="gdpr"],
      div[id*="consent"], div[class*="consent"],
      div[id*="cookie"], div[class*="cookie"],
      div[id*="modal"]:not([id*="map"]),
      div[class*="modal"]:not([class*="map"]) {
        display: none !important;
        pointer-events: none !important;
      }
    `;
    document.head.appendChild(style);

    [
      '#sidebar', '#sidebar-toggle', '.globeSidebar',
      '#searchbar', '#search-wrapper',
      '#toolbar', '.top-bar',
      '#infoblock', '#infoblockBottom',
      '#selected_ac_data', '#acList', '#acList2',
      '#routeData', '#notam', '#statsblock',
      '.globeFooter', '#globeFooter', '#adsb-logo',
      '#helppage', '#layer-chooser', '#range-rings',
      '#mapControls', '#mapButtons', '#planeList', '#flightList',
      '#bottombar', '#bottom-bar', '#status-bar',
      '#scale', '.scale-line', '#version',
      '#message_block', '.top_message_block',
      'header', 'footer', 'nav', 'iframe',
    ].forEach(function(sel) {
      document.querySelectorAll(sel).forEach(function(el) { el.remove(); });
    });

    var mapEl = document.getElementById('map')
             || document.querySelector('.leaflet-container')
             || document.getElementById('cesiumContainer');
    if (mapEl) {
      mapEl.style.setProperty('position', 'fixed',  'important');
      mapEl.style.setProperty('top',      '0',      'important');
      mapEl.style.setProperty('left',     '0',      'important');
      mapEl.style.setProperty('width',    '100vw',  'important');
      mapEl.style.setProperty('height',   '100vh',  'important');
      mapEl.style.setProperty('z-index',  '1',      'important');
    }

    setTimeout(function() {
      ['OL','ownMap','map','globeMap','mainMap'].forEach(function(key) {
        try {
          var m = window[key];
          if (m && typeof m.invalidateSize === 'function') {
            m.invalidateSize(true);
          }
        } catch(e) {}
      });
    }, 300);

    if (!window.__fc_obs__) {
      window.__fc_obs__ = new MutationObserver(function(mutations) {
        mutations.forEach(function(m) {
          m.addedNodes.forEach(function(node) {
            if (node.nodeType !== 1) return;
            var id  = (node.id    || '').toLowerCase();
            var cls = (typeof node.className === 'string' ? node.className : '').toLowerCase();
            var bad = ['advert','banner','gdpr','consent','cookie','modal','popup']
              .some(function(kw) {
                return (id.includes(kw) || cls.includes(kw))
                    && !id.includes('map') && !cls.includes('map');
              });
            if (bad || node.tagName === 'IFRAME') node.remove();
          });
        });
        document.querySelectorAll('.leaflet-popup').forEach(function(p) { p.remove(); });
      });
      window.__fc_obs__.observe(document.body, { childList: true, subtree: true });
    }

  })();
  """;

  Future<void> _runCleanup() async {
    try {
      await _webViewController.evaluateJavascript(source: _cleanupScript);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // ── 1. Full-screen WebView ─────────────────────────────────────────
        Positioned.fill(
          child: InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri(_webUrl)),
            initialOptions: InAppWebViewGroupOptions(
              crossPlatform: InAppWebViewOptions(
                javaScriptEnabled: true,
                mediaPlaybackRequiresUserGesture: false,
                supportZoom: true,
                // ✅ Mobile UA — tells the site to render at phone width
                userAgent:
                    'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) '
                    'AppleWebKit/605.1.15 (KHTML, like Gecko) '
                    'Version/17.0 Mobile/15E148 Safari/604.1',
                contentBlockers: [
                  ContentBlocker(
                    trigger: ContentBlockerTrigger(
                        urlFilter: r".*doubleclick\.net.*"),
                    action: ContentBlockerAction(
                        type: ContentBlockerActionType.BLOCK),
                  ),
                  ContentBlocker(
                    trigger: ContentBlockerTrigger(
                        urlFilter: r".*googlesyndication\.com.*"),
                    action: ContentBlockerAction(
                        type: ContentBlockerActionType.BLOCK),
                  ),
                  ContentBlocker(
                    trigger: ContentBlockerTrigger(
                        urlFilter: r".*googleadservices\.com.*"),
                    action: ContentBlockerAction(
                        type: ContentBlockerActionType.BLOCK),
                  ),
                  ContentBlocker(
                    trigger: ContentBlockerTrigger(
                        urlFilter: r".*amazon-adsystem\.com.*"),
                    action: ContentBlockerAction(
                        type: ContentBlockerActionType.BLOCK),
                  ),
                  ContentBlocker(
                    trigger:
                        ContentBlockerTrigger(urlFilter: r".*adnxs\.com.*"),
                    action: ContentBlockerAction(
                        type: ContentBlockerActionType.BLOCK),
                  ),
                  // ✅ Also block ad domains seen in your logs
                  ContentBlocker(
                    trigger: ContentBlockerTrigger(urlFilter: r".*1rx\.io.*"),
                    action: ContentBlockerAction(
                        type: ContentBlockerActionType.BLOCK),
                  ),
                  ContentBlocker(
                    trigger:
                        ContentBlockerTrigger(urlFilter: r".*crwdcntrl\.net.*"),
                    action: ContentBlockerAction(
                        type: ContentBlockerActionType.BLOCK),
                  ),
                  ContentBlocker(
                    trigger:
                        ContentBlockerTrigger(urlFilter: r".*lijit\.com.*"),
                    action: ContentBlockerAction(
                        type: ContentBlockerActionType.BLOCK),
                  ),
                  ContentBlocker(
                    trigger: ContentBlockerTrigger(urlFilter: r".*agkn\.com.*"),
                    action: ContentBlockerAction(
                        type: ContentBlockerActionType.BLOCK),
                  ),
                  ContentBlocker(
                    trigger:
                        ContentBlockerTrigger(urlFilter: r".*tremorhub\.com.*"),
                    action: ContentBlockerAction(
                        type: ContentBlockerActionType.BLOCK),
                  ),
                ],
              ),
              android: AndroidInAppWebViewOptions(
                useHybridComposition: true,
                useWideViewPort: false, // ✅ prevents 980px desktop layout
                loadWithOverviewMode: false,
              ),
              ios: IOSInAppWebViewOptions(
                allowsInlineMediaPlayback: true,
              ),
            ),
            onWebViewCreated: (wc) {
              _webViewController = wc;
            },
            // ✅ Inject viewport fix as early as possible
            onPageCommitVisible: (wc, url) async {
              await wc.evaluateJavascript(source: _viewportScript);
            },
            onLoadStart: (_, __) {
              widget.controller.isLoading.value = true;
              _mapReady.value = false;
            },
            onLoadStop: (_, __) async {
              widget.controller.isLoading.value = false;
              await _runCleanup();
              // Wait for map tiles to finish rendering before revealing
              await Future.delayed(const Duration(milliseconds: 1200));
              _mapReady.value = true;
              Future.delayed(const Duration(seconds: 2), _runCleanup);
              Future.delayed(const Duration(seconds: 5), _runCleanup);
            },
          ),
        ),

        // ── 2. Black cover — shown until map is clean ──────────────────────
        Obx(() => _mapReady.value
            ? const SizedBox.shrink()
            : Positioned.fill(
                child: Container(
                  color: Colors.black,
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                        SizedBox(height: 16),
                        Text(
                          "Loading Map...",
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 13,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )),

        // ── 3. App UI — only shown when map is ready ───────────────────────
        Obx(() => _mapReady.value
            ? SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              InkWell(
                                onTap: () => Get.back(),
                                child: CommonWidgets.appIcons(
                                  assetName: IconConstants.icBackPng,
                                  height: 31.px,
                                  width: 31.px,
                                ),
                              ),
                              SizedBox(width: 8.px),
                              CommonWidgets.appIcons(
                                assetName: IconConstants.icLocationLite,
                                height: 31.px,
                                width: 31.px,
                              ),
                              SizedBox(width: 3.px),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Obx(() => Text(
                                        widget.controller.name.value,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 20.px,
                                          shadows: const [
                                            Shadow(
                                              offset: Offset(0, 4),
                                              blurRadius: 10,
                                              color: Colors.black54,
                                            ),
                                          ],
                                        ),
                                      )),
                                  Obx(() => Text(
                                        widget.controller.city.value,
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 16.px,
                                          fontWeight: FontWeight.w400,
                                          shadows: const [
                                            Shadow(
                                              offset: Offset(0, 4),
                                              blurRadius: 10,
                                              color: Colors.black54,
                                            ),
                                          ],
                                        ),
                                      )),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              CommonWidgets.appIcons(
                                assetName: IconConstants.icMenuSetting,
                                height: 32.px,
                                width: 32.px,
                              ),
                              SizedBox(width: 10.px),
                              InkWell(
                                onTap: () => Get.toNamed(Routes.AI_CHAT_SCREEN),
                                child: CommonWidgets.appIconsSvg(
                                  assetName: IconConstants.icAiSetting,
                                    height: 32.px,
                                    width: 32.px,
                                    color: primary3Color
                                ),
                              ),
                              SizedBox(width: 10.px),
                              CommonWidgets.appIcons(
                                assetName: IconConstants.icNotificationTop,
                                height: 26.px,
                                width: 26.px,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 12.px),
                    Row(
                      children: [
                        SizedBox(width: 30.px),
                        Text(
                          "Routes",
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 18.px,
                            color: textColorLite,
                            shadows: const [
                              Shadow(
                                  offset: Offset(0, 2),
                                  blurRadius: 6,
                                  color: Colors.black54),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            CommonWidgets.appIconsSvg(
                              assetName: IconConstants.icMenuSettingColor,
                              height: 28.px,
                              width: 28.px,
                            ),
                            SizedBox(width: 10.px),
                            CommonWidgets.appIcons(
                              assetName: IconConstants.icUploadMenu,
                              height: 32.px,
                              width: 32.px,
                            ),
                            SizedBox(width: 10.px),
                            CommonWidgets.appIconsSvg(
                              assetName: IconConstants.icMenuFullMapIcon,
                              height: 30.px,
                              width: 30.px,
                            ),
                            SizedBox(width: 10.px),
                            CommonWidgets.appIcons(
                              assetName: IconConstants.icSearchMenu,
                              height: 32.px,
                              width: 32.px,
                            ),
                          ],
                        ),
                        SizedBox(width: 30.px),
                      ],
                    ),
                  ],
                ),
              )
            : const SizedBox.shrink()),
      ],
    );
  }
}
