import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:intl/intl.dart';

import '../../../routes/app_pages.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shimmer/shimmer.dart';

import '../../../common/colors.dart';
import '../../../common/common_widgets.dart';
import '../../../data/apis/api_models/get_upcomming_weather_hourly.dart';
import '../../../data/apis/api_models/get_weekly_upcomming_forecast_model.dart';
import '../../../data/constants/icons_constant.dart';
import '../controllers/up_comming_forcast_screem_controller.dart';

enum SortType { hourly, weekly, monthly }

class UpCommingForcastScreemView
    extends GetView<UpCommingForcastScreemController> {
  const UpCommingForcastScreemView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.lazyPut<UpCommingForcastScreemController>(
      () => UpCommingForcastScreemController(),
    );

    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Container(
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
                _Header(),
                Expanded(child: _Body()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Header
// ═══════════════════════════════════════════════════════════════════════════════

class _Header extends GetView<UpCommingForcastScreemController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      controller.count.value;
      return Padding(
        padding: EdgeInsets.only(top: 12.px, bottom: 4.px),
        child: SizedBox(
          height: controller.isSearchVisible.value ? 160 : 110,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // ── Normal header (hidden while search is open) ───────────────
              AnimatedOpacity(
                opacity: controller.isSearchVisible.value ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: IgnorePointer(
                  ignoring: controller.isSearchVisible.value,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.px),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Back
                            InkWell(
                              onTap: () => Get.back(),
                              borderRadius: BorderRadius.circular(20),
                              child: CommonWidgets.appIconsSvg(
                                assetName: IconConstants.icBackRound,
                                height: 31.px,
                                width: 31.px,
                              ),
                            ),
                            SizedBox(width: 10.px),
                            // Title + address
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _titleText(controller.selectedLabel.value),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 17.px,
                                      color: textColorLite,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    controller.address.value.isEmpty
                                        ? 'Fetching location…'
                                        : controller.address.value,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 11.px,
                                      color: textColorLite.withOpacity(0.75),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Action icons
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Sort
                                GestureDetector(
                                  onTap: () => showSortSheet(context),
                                  child: const Icon(Icons.tune,
                                      color: Colors.white, size: 25),
                                ),
                                SizedBox(width: 10.px),
                                // AI chat
                                InkWell(
                                  onTap: () =>
                                      Get.toNamed(Routes.AI_CHAT_SCREEN),
                                  borderRadius: BorderRadius.circular(12),
                                  child: CommonWidgets.appIconsSvg(
                                    assetName: IconConstants.icAiSetting,
                                      height: 32.px,
                                      width: 32.px,
                                      color: primary3Color
                                  ),
                                ),
                                SizedBox(width: 10.px),
                                // Search toggle
                                InkWell(
                                  onTap: () => controller.openSearch(),
                                  borderRadius: BorderRadius.circular(12),
                                  child: CommonWidgets.appIcons(
                                    assetName: IconConstants.icSearchMenu,
                                    height: 24.px,
                                    width: 24.px,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Settings gear
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.px),
                        child: Row(
                          children: [
                            const Spacer(),
                            InkWell(
                              onTap: () {
                                Get.toNamed(Routes.WEATHER_SETTINGS_SCREEN)
                                    ?.then((_) {
                                  controller
                                      .changeSort(controller.sortType.value);
                                });
                              },
                              borderRadius: BorderRadius.circular(20),
                              child: CommonWidgets.appIconsSvg(
                                assetName: IconConstants.icMenuSettingColor,
                                height: 25.px,
                                width: 25.px,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Search Section ────────────────────────────────────────────
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                top: controller.isSearchVisible.value ? 0 : -200,
                left: 0,
                right: 0,
                child: AnimatedOpacity(
                  opacity: controller.isSearchVisible.value ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 250),
                  child: _SearchSection(),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  String _titleText(String label) {
    switch (label) {
      case 'weekly':
        return 'Weekly Weather';
      case 'monthly':
        return 'Monthly Weather';
      default:
        return 'Hourly Weather';
    }
  }

  void showSortSheet(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => CupertinoActionSheet(
        actions: controller.items
            .map(
              (e) => CupertinoActionSheetAction(
                onPressed: () {
                  controller.changeSort(e["value"] as SortType);
                  Get.back();
                },
                child: Text(
                  (e["label"] as String).capitalizeFirst ?? '',
                  style: TextStyle(
                    fontSize: 16.px,
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
            .toList(),
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Get.back(),
          child: const Text(
            "Cancel",
            style: TextStyle(
                fontSize: 16, color: Colors.red, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Search Section
// ═══════════════════════════════════════════════════════════════════════════════

class _SearchSection extends GetView<UpCommingForcastScreemController> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.px),
      child: Column(
        children: [
          // Search Input
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.18),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: controller.searchController,
              focusNode: controller.focusNodeLocation,
              style: TextStyle(
                color: Colors.black87,
                fontSize: 14.px,
              ),
              decoration: InputDecoration(
                hintText: controller.searchMode.value == SearchMode.airport
                    ? "Search airports (ICAO, name, city)..."
                    : "Search cities or locations...",
                hintStyle: TextStyle(color: greyColor, fontSize: 14.px),
                prefixIcon: InkWell(
                  onTap: () => controller.closeSearchBack(),
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.black54,
                    size: 20.px,
                  ),
                ),
                suffixIcon: Obx(() {
                  controller.count.value;
                  if (controller.isSearchLoading.value) {
                    return Padding(
                      padding: const EdgeInsets.all(12),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: primaryColor,
                        ),
                      ),
                    );
                  }
                  return controller.searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () => controller.clearSearch(),
                        )
                      : const SizedBox.shrink();
                }),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Search Mode Toggle
          _SearchModeToggle(),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Search Mode Toggle
// ═══════════════════════════════════════════════════════════════════════════════

class _SearchModeToggle extends GetView<UpCommingForcastScreemController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Airport Search
            Expanded(
              child: GestureDetector(
                onTap: () => controller.toggleSearchMode(SearchMode.airport),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: controller.searchMode.value == SearchMode.airport
                        ? primaryColor
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.flight,
                        size: 18,
                        color: controller.searchMode.value == SearchMode.airport
                            ? Colors.white
                            : Colors.white70,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "Airports",
                        style: TextStyle(
                          fontSize: 13.px,
                          fontWeight: FontWeight.w600,
                          color:
                              controller.searchMode.value == SearchMode.airport
                                  ? Colors.white
                                  : Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(width: 4),

            // Location Search
            Expanded(
              child: GestureDetector(
                onTap: () => controller.toggleSearchMode(SearchMode.location),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: controller.searchMode.value == SearchMode.location
                        ? primaryColor
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_city,
                        size: 18,
                        color:
                            controller.searchMode.value == SearchMode.location
                                ? Colors.white
                                : Colors.white70,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "Locations",
                        style: TextStyle(
                          fontSize: 13.px,
                          fontWeight: FontWeight.w600,
                          color:
                              controller.searchMode.value == SearchMode.location
                                  ? Colors.white
                                  : Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Body
// ═══════════════════════════════════════════════════════════════════════════════

class _Body extends GetView<UpCommingForcastScreemController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Search results - show if search is visible
      if (controller.isSearchVisible.value) {
        return _SearchResults();
      }

      // Loading shimmer
      if (controller.inAsyncCall.value) {
        return _ShimmerList();
      }

      // Error state
      if (controller.hasError.value) {
        return _ErrorWidget(message: controller.errorMessage.value);
      }

      // Data
      final isHourly = controller.selectedLabel.value == "hourly";
      if (isHourly) {
        return controller.forecastListNeww.isEmpty
            ? _EmptyWidget()
            : _HourlyList();
      } else {
        return controller.forecastListWeekly.isEmpty
            ? _EmptyWidget()
            : _WeeklyList();
      }
    });
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Search Results
// ═══════════════════════════════════════════════════════════════════════════════

class _SearchResults extends GetView<UpCommingForcastScreemController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isAirportMode = controller.searchMode.value == SearchMode.airport;
      final hasText = controller.searchController.text.isNotEmpty;
      final isLoading = controller.isSearchLoading.value;

      // Show loading
      if (isLoading && hasText) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: CircularProgressIndicator(color: primaryColor),
          ),
        );
      }

      // Airport results
      if (isAirportMode) {
        if (controller.airportSuggestions.isEmpty) {
          return _EmptySearchState(
            icon: Icons.flight,
            message: hasText
                ? 'No airports found for "${controller.searchController.text}"'
                : 'Search by ICAO code, airport name, or city',
            hint: hasText
                ? 'Try a different search term'
                : 'Example: VRDA, JFK, Mumbai',
          );
        }

        return _AirportResultsList();
      }

      // Location results
      if (controller.locationSuggestions.isEmpty) {
        return _EmptySearchState(
          icon: Icons.location_city,
          message: hasText
              ? 'No locations found for "${controller.searchController.text}"'
              : 'Search for cities or places',
          hint: hasText
              ? 'Try a different search term'
              : 'Example: New York, London, Tokyo',
        );
      }

      return _LocationResultsList();
    });
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Airport Results List
// ═══════════════════════════════════════════════════════════════════════════════

class _AirportResultsList extends GetView<UpCommingForcastScreemController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() => ListView.separated(
          padding: EdgeInsets.symmetric(horizontal: 16.px, vertical: 8.px),
          itemCount: controller.airportSuggestions.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final airport = controller.airportSuggestions[index];
            return _AirportResultCard(airport: airport);
          },
        ));
  }
}

class _AirportResultCard extends GetView<UpCommingForcastScreemController> {
  final AirportResult airport;

  const _AirportResultCard({required this.airport});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => controller.selectAirport(airport),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            // Airport Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor, primaryColor2],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.flight,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),

            // Airport Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(
                    airport.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.px,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // City, Country
                  Text(
                    "${airport.city}, ${airport.country}",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12.px,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  // Codes & Coordinates
                  Row(
                    children: [
                      _CodeBadge(
                        label: "ICAO",
                        value: airport.icaoCode,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 8),
                      _CodeBadge(
                        label: "IATA",
                        value: airport.airportCode,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "${airport.latitude.toStringAsFixed(4)}°, ${airport.longitude.toStringAsFixed(4)}°",
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 10.px,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Arrow
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white38,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

class _CodeBadge extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _CodeBadge({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "$label: ",
            style: TextStyle(
              color: color.withOpacity(0.8),
              fontSize: 9,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Location Results List
// ═══════════════════════════════════════════════════════════════════════════════

class _LocationResultsList extends GetView<UpCommingForcastScreemController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() => ListView.separated(
          padding: EdgeInsets.symmetric(horizontal: 16.px, vertical: 8.px),
          itemCount: controller.locationSuggestions.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final location = controller.locationSuggestions[index];
            return _LocationResultCard(location: location);
          },
        ));
  }
}

class _LocationResultCard extends GetView<UpCommingForcastScreemController> {
  final LocationResult location;

  const _LocationResultCard({required this.location});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLoading = controller.isSearchLoading.value;

      return InkWell(
        onTap: isLoading ? null : () => controller.selectLocation(location),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              // Location Icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange, Colors.deepOrange],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.location_on,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),

              // Location Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Main Text
                    Text(
                      location.mainText.isNotEmpty
                          ? location.mainText
                          : location.description,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.px,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Secondary Text
                    if (location.secondaryText.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        location.secondaryText,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12.px,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              // Arrow
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.white38,
                size: 16,
              ),
            ],
          ),
        ),
      );
    });
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Empty Search State
// ═══════════════════════════════════════════════════════════════════════════════

class _EmptySearchState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String hint;

  const _EmptySearchState({
    required this.icon,
    required this.message,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.white54,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 15.px,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hint,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white54,
                fontSize: 13.px,
              ),
            ),
            const SizedBox(height: 24),
            TextButton.icon(
              onPressed: () =>
                  Get.find<UpCommingForcastScreemController>().closeSearch(),
              icon: const Icon(Icons.close, color: Colors.white70, size: 18),
              label: Text(
                'Cancel Search',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14.px,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Shimmer List
// ═══════════════════════════════════════════════════════════════════════════════

class _ShimmerList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 4,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: const Color(0xffaaa5a5b2).withOpacity(0.5),
        highlightColor: Colors.white.withOpacity(0.4),
        child: Container(
          height: 160,
          margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: primary3Color,
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Error Widget
// ═══════════════════════════════════════════════════════════════════════════════

class _ErrorWidget extends StatelessWidget {
  final String message;

  const _ErrorWidget({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded,
                color: Colors.white54, size: 56),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white70,
                  fontSize: 15.px,
                  fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: () {
                final c = Get.find<UpCommingForcastScreemController>();
                c.changeSort(c.sortType.value);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry',
                  style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Empty Widget
// ═══════════════════════════════════════════════════════════════════════════════

class _EmptyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Center(child: CommonWidgets.dataNotFound());
}

// ═══════════════════════════════════════════════════════════════════════════════
// Hourly List (Keep existing implementation)
// ═══════════════════════════════════════════════════════════════════════════════

class _HourlyList extends GetView<UpCommingForcastScreemController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() => ListView.builder(
          padding: const EdgeInsets.only(bottom: 16),
          itemCount: controller.forecastListNeww.length,
          itemBuilder: (_, i) =>
              _HourlyCard(data: controller.forecastListNeww[i]),
        ));
  }
}

class _HourlyCard extends GetView<UpCommingForcastScreemController> {
  final HourlyForecast data;

  const _HourlyCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final date = DateTime.fromMillisecondsSinceEpoch(
      ((data.timestamp ?? 0) as num).toInt() * 1000,
      isUtc: true,
    ).toLocal();

    final condition = data.condition?.toString() ?? '';
    final emoji = controller.extractEmoji(condition);
    final condText = controller.extractCondition(condition);
    final tempUnit = controller.temperatureUnit.value;
    final pressUnit = controller.pressureUnit.value;
    final windUnitStr = controller.windUnit.value;

    return Neumorphic(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      style: NeumorphicStyle(
        depth: 8,
        intensity: 0.7,
        surfaceIntensity: 0.3,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(20)),
        lightSource: LightSource.topLeft,
        color: Colors.transparent,
        shadowDarkColor: Colors.white.withOpacity(0.3),
        shadowLightColor: Colors.red.withOpacity(0.05),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 40, 16, 14),
        decoration: BoxDecoration(
          color: const Color(0xffaaa5a5b2).withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              right: 0,
              top: -34,
              child: _DateBadge(date: date),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        condText,
                        style: TextStyle(
                          fontSize: 15.px,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      _InfoRow(
                          label: "Description",
                          value: data.description?.toString() ?? '--'),
                      _InfoRow(
                        label: "Wind",
                        value: data.windSpeed != null
                            ? "${controller.fmt(data.windSpeed)} $windUnitStr"
                            : '--',
                      ),
                      _InfoRow(
                        label: "Humidity",
                        value: data.humidity != null
                            ? "${controller.fmt(data.humidity)}%"
                            : '--',
                      ),
                      _InfoRow(
                        label: "Pressure",
                        value: data.pressure != null
                            ? "${controller.fmt(data.pressure)} $pressUnit"
                            : '--',
                      ),
                      _InfoRow(
                        label: "Feels Like",
                        value: data.feelsLike != null
                            ? "${controller.fmt(data.feelsLike)} $tempUnit"
                            : '--',
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      emoji.isEmpty ? '🌡️' : emoji,
                      style: TextStyle(fontSize: 52.px),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          controller.fmt(data.temperature),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 34.px,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            tempUnit,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.px,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Weekly List (Keep existing implementation)
// ═══════════════════════════════════════════════════════════════════════════════

class _WeeklyList extends GetView<UpCommingForcastScreemController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() => ListView.builder(
          padding: const EdgeInsets.only(bottom: 16),
          itemCount: controller.forecastListWeekly.length,
          itemBuilder: (_, i) =>
              _WeeklyCard(data: controller.forecastListWeekly[i]),
        ));
  }
}

class _WeeklyCard extends GetView<UpCommingForcastScreemController> {
  final WeeklyForecast data;

  const _WeeklyCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final DateTime date;
    if (data.timestamp != null && (data.timestamp as num).toInt() > 0) {
      date = DateTime.fromMillisecondsSinceEpoch(
        (data.timestamp as num).toInt() * 1000,
        isUtc: true,
      ).toLocal();
    } else if (data.date != null && data.date!.isNotEmpty) {
      date = DateTime.tryParse(data.date!) ?? DateTime(0);
    } else {
      date = DateTime(0);
    }

    final condition = data.condition?.toString() ?? '';
    final emoji = controller.extractEmoji(condition);
    final condText = controller.extractCondition(condition);
    final isMonthly = controller.selectedLabel.value == "monthly";
    final isWeekly = controller.selectedLabel.value == "weekly";

    final tempUnit = controller.temperatureUnit.value;
    final pressUnit = controller.pressureUnit.value;
    final windUnitStr = controller.windUnit.value;

    return Neumorphic(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      style: NeumorphicStyle(
        depth: 8,
        intensity: 0.7,
        surfaceIntensity: 0.3,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(20)),
        lightSource: LightSource.topLeft,
        color: Colors.transparent,
        shadowDarkColor: Colors.white.withOpacity(0.3),
        shadowLightColor: Colors.red.withOpacity(0.05),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 40, 16, 14),
        decoration: BoxDecoration(
          color: const Color(0xffaaa5a5b2).withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              right: 0,
              top: -34,
              // Pass both isMonthly and isWeekly flags
              child: _DateBadge(
                date: date,
                isMonthly: isMonthly,
                isWeekly: isWeekly,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            condText,
                            style: TextStyle(
                              fontSize: 15.px,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          _InfoRow(
                            label: "Wind",
                            value: data.windSpeed != null
                                ? "${controller.fmt(data.windSpeed)} $windUnitStr"
                                : '--',
                          ),
                          if (!isMonthly) ...[
                            _InfoRow(
                              label: "Humidity",
                              value: data.humidity != null
                                  ? "${controller.fmt(data.humidity)}%"
                                  : '--',
                            ),
                            _InfoRow(
                              label: "Pressure",
                              value: data.pressure != null
                                  ? "${controller.fmt(data.pressure)} $pressUnit"
                                  : '--',
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        emoji.isEmpty ? '🌡️' : emoji,
                        style: TextStyle(fontSize: 52.px),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                IntrinsicHeight(
                  child: Row(
                    children: [
                      Expanded(
                        child: _TempColumn(
                          icon: IconConstants.icMin,
                          label: "Min",
                          value: controller.fmt(data.temperature?.min),
                          unit: tempUnit,
                          showDivider: true,
                        ),
                      ),
                      Expanded(
                        child: _TempColumn(
                          icon: IconConstants.icMax,
                          label: "Max",
                          value: controller.fmt(data.temperature?.max),
                          unit: tempUnit,
                          showDivider: true,
                        ),
                      ),
                      Expanded(
                        child: _TempColumn(
                          icon: IconConstants.icDay,
                          label: "Day",
                          value: controller.fmt(data.temperature?.day),
                          unit: tempUnit,
                          showDivider: false,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Shared Widgets
// ═══════════════════════════════════════════════════════════════════════════════

class _DateBadge extends StatelessWidget {
  final DateTime date;
  final bool isMonthly;
  final bool isWeekly;

  const _DateBadge({
    required this.date,
    this.isMonthly = false,
    this.isWeekly = false,
  });

  @override
  Widget build(BuildContext context) {
    String label;

    if (date.year == 0) {
      label = '--';
    } else if (isMonthly) {
      // Monthly: Show only "Apr 2026"
      label = DateFormat("MMM yyyy").format(date);
    } else if (isWeekly) {
      // Weekly: Show only "Mon, 7 Apr" (no time)
      label = DateFormat("EEE, d MMM").format(date);
    } else {
      // Hourly: Show date with time "7 Apr, 2:30 PM"
      label = DateFormat("d MMM, h:mm a").format(date);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: const BoxDecoration(
        color: gradientPurple5,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
          bottomLeft: Radius.circular(10),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: primary3Color,
          fontSize: 12.px,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label : ",
            style: TextStyle(
              fontSize: 13.px,
              fontWeight: FontWeight.w700,
              color: yellowColor,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13.px,
                fontWeight: FontWeight.w600,
                color: primary3Color,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}

class _TempColumn extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final String unit;
  final bool showDivider;

  const _TempColumn({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    required this.showDivider,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: showDivider
          ? BoxDecoration(
              border: Border(
                right:
                    BorderSide(color: Colors.white.withOpacity(0.35), width: 1),
              ),
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "$label Temp",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 11.px,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CommonWidgets.appIcons(assetName: icon, height: 14, width: 14),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  value,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.px,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                unit,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11.px,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
