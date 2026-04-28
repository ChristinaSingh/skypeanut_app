import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../../common/colors.dart';
import '../../../common/common_widgets.dart';
import '../../../data/constants/icons_constant.dart';
import '../controllers/air_quility_controller.dart';

class AirQuilityView extends GetView<AirQuilityController> {
  const AirQuilityView({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
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
            child: Obx(() {
              controller.count.value;
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.px),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Top bar ─────────────────────────────────────────
                      _TopBar(),

                      SizedBox(height: 20.px),

                      // ── Hero AQI card ───────────────────────────────────
                      _HeroAqiCard(),

                      SizedBox(height: 16.px),

                      // ── AQI scale ───────────────────────────────────────
                      _AqiScaleCard(),

                      SizedBox(height: 16.px),

                      // ── Pollutant details ───────────────────────────────
                      _PollutantCard(),

                      SizedBox(height: 16.px),

                      // ── Description card ────────────────────────────────
                      _InfoCard(
                        title: 'What does this mean?',
                        icon: Icons.info_outline_rounded,
                        body: controller.aqiDescription,
                      ),

                      SizedBox(height: 12.px),

                      // ── Health advice ───────────────────────────────────
                      _InfoCard(
                        title: 'Health Advice',
                        icon: Icons.health_and_safety_outlined,
                        body: controller.healthAdvice,
                      ),

                      SizedBox(height: 12.px),

                      // ── Aviation impact ─────────────────────────────────
                      _InfoCard(
                        title: 'Aviation Impact',
                        icon: Icons.flight_outlined,
                        body: controller.aviationImpact,
                      ),

                      SizedBox(height: 16.px),

                      // ── Current conditions ──────────────────────────────
                      _CurrentConditionsCard(),

                      SizedBox(height: 30.px),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ─── Top Bar ──────────────────────────────────────────────────────────────────
class _TopBar extends GetView<AirQuilityController> {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.px),
      child: Row(
        children: [
          InkWell(
            onTap: () => Get.back(),
            borderRadius: BorderRadius.circular(20),
            child: CommonWidgets.appIconsSvg(
              assetName: IconConstants.icBackRound,
              height: 31.px,
              width: 31.px,
            ),
          ),
          SizedBox(width: 12.px),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Air Quality Index',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.px,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Obx(() => Text(
                  controller.city.value.isNotEmpty
                      ? controller.city.value
                      : 'Current Location',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12.px,
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Hero AQI Card ────────────────────────────────────────────────────────────
class _HeroAqiCard extends GetView<AirQuilityController> {
  const _HeroAqiCard();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final aqi = controller.aqiUs.value;
      final color = _aqiColor(aqi);
      final moodIcon = _moodIcon(aqi);

      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.px),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.25),
              color.withOpacity(0.08),
            ],
          ),
          border: Border.all(color: color.withOpacity(0.4), width: 1.5),
        ),
        child: Column(
          children: [
            // Big AQI number + icon
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 24.px, vertical: 16.px),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: color.withOpacity(0.5)),
                  ),
                  child: Text(
                    '$aqi',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 48.px,
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                  ),
                ),
                SizedBox(width: 20.px),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(moodIcon, color: color, size: 40),
                    SizedBox(height: 6.px),
                    Text(
                      'US AQI',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13.px,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: 16.px),

            // Level label
            Container(
              padding: EdgeInsets.symmetric(
                  horizontal: 20.px, vertical: 8.px),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: color.withOpacity(0.5)),
              ),
              child: Text(
                controller.aqiLevel,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.px,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ),

            SizedBox(height: 16.px),

            // Progress bar
            _AqiProgressBar(aqi: aqi, color: color),

            SizedBox(height: 8.px),

            // Range labels
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('0',
                    style: TextStyle(
                        color: Colors.white38, fontSize: 10.px)),
                Text('Good',
                    style: TextStyle(
                        color: const Color(0xFF00E676), fontSize: 10.px)),
                Text('Moderate',
                    style: TextStyle(
                        color: const Color(0xFFFFEB3B), fontSize: 10.px)),
                Text('Unhealthy',
                    style: TextStyle(
                        color: const Color(0xFFFF5252), fontSize: 10.px)),
                Text('500',
                    style: TextStyle(
                        color: Colors.white38, fontSize: 10.px)),
              ],
            ),
          ],
        ),
      );
    });
  }
}

// ─── AQI Progress Bar ─────────────────────────────────────────────────────────
class _AqiProgressBar extends StatelessWidget {
  final int aqi;
  final Color color;

  const _AqiProgressBar({required this.aqi, required this.color});

  @override
  Widget build(BuildContext context) {
    final progress = (aqi / 500).clamp(0.0, 1.0);

    return Stack(
      children: [
        // Background gradient bar
        Container(
          height: 12,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            gradient: const LinearGradient(
              colors: [
                Color(0xFF00E676),
                Color(0xFFFFEB3B),
                Color(0xFFFF9800),
                Color(0xFFFF5252),
                Color(0xFF9C27B0),
                Color(0xFF880E4F),
              ],
            ),
          ),
        ),
        // Indicator
        AnimatedPositioned(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
          left: (MediaQuery.of(context).size.width - 80) * progress,
          top: -2,
          child: Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 3),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.5),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── AQI Scale Card ───────────────────────────────────────────────────────────
class _AqiScaleCard extends GetView<AirQuilityController> {
  const _AqiScaleCard();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currentIdx = controller.currentScaleIndex;

      return _CardWrapper(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader(
              icon: Icons.analytics_outlined,
              title: 'AQI Scale',
            ),
            SizedBox(height: 12.px),
            ...controller.aqiScale.asMap().entries.map((entry) {
              final i = entry.key;
              final item = entry.value;
              final isCurrent = i == currentIdx;

              return Container(
                margin: EdgeInsets.only(bottom: 6.px),
                padding: EdgeInsets.symmetric(
                    horizontal: 12.px, vertical: 10.px),
                decoration: BoxDecoration(
                  color: isCurrent
                      ? item.color.withOpacity(0.2)
                      : Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(12),
                  border: isCurrent
                      ? Border.all(color: item.color.withOpacity(0.6))
                      : null,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: item.color,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    SizedBox(width: 10.px),
                    Text(
                      '${item.min} – ${item.max}',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12.px,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'monospace',
                      ),
                    ),
                    SizedBox(width: 12.px),
                    Expanded(
                      child: Text(
                        item.label,
                        style: TextStyle(
                          color: isCurrent ? Colors.white : Colors.white54,
                          fontSize: 13.px,
                          fontWeight:
                          isCurrent ? FontWeight.w700 : FontWeight.w400,
                        ),
                      ),
                    ),
                    if (isCurrent)
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.px, vertical: 3.px),
                        decoration: BoxDecoration(
                          color: item.color.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'NOW',
                          style: TextStyle(
                            color: item.color,
                            fontSize: 9.px,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ],
        ),
      );
    });
  }
}

// ─── Pollutant Details ────────────────────────────────────────────────────────
class _PollutantCard extends GetView<AirQuilityController> {
  const _PollutantCard();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return _CardWrapper(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader(
              icon: Icons.blur_on_rounded,
              title: 'Pollutant Levels',
            ),
            SizedBox(height: 14.px),
            Row(
              children: [
                Expanded(
                  child: _PollutantTile(
                    name: 'PM2.5',
                    value: controller.aqiPm25.value,
                    unit: 'μg/m³',
                    maxSafe: 12.0,
                    description: 'Fine particles that penetrate deep into lungs',
                  ),
                ),
                SizedBox(width: 12.px),
                Expanded(
                  child: _PollutantTile(
                    name: 'PM10',
                    value: controller.aqiPm10.value,
                    unit: 'μg/m³',
                    maxSafe: 54.0,
                    description: 'Coarse particles from dust & pollen',
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

class _PollutantTile extends StatelessWidget {
  final String name;
  final double value;
  final String unit;
  final double maxSafe;
  final String description;

  const _PollutantTile({
    required this.name,
    required this.value,
    required this.unit,
    required this.maxSafe,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = (value / (maxSafe * 5)).clamp(0.0, 1.0);
    final isAboveSafe = value > maxSafe;
    final barColor =
    isAboveSafe ? const Color(0xFFFF5252) : const Color(0xFF00E676);

    return Container(
      padding: EdgeInsets.all(14.px),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: barColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                name,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.px,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              if (isAboveSafe)
                Icon(Icons.warning_rounded, color: barColor, size: 14),
            ],
          ),
          SizedBox(height: 6.px),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value.toStringAsFixed(1),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22.px,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                TextSpan(
                  text: ' $unit',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11.px,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8.px),
          // Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Stack(
              children: [
                Container(
                  height: 6,
                  color: Colors.white.withOpacity(0.08),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  height: 6,
                  width: MediaQuery.of(context).size.width * 0.3 * ratio,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        barColor.withOpacity(0.5),
                        barColor,
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 6.px),
          Text(
            'Safe: <${maxSafe.toStringAsFixed(0)} $unit',
            style: TextStyle(
              color: Colors.white,
              fontSize: 9.px,
            ),
          ),
          SizedBox(height: 4.px),
          Text(
            description,
            style: TextStyle(
              color: Colors.white,
              fontSize: 9.px,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Info Card ────────────────────────────────────────────────────────────────
class _InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String body;

  const _InfoCard({
    required this.title,
    required this.icon,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return _CardWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(icon: icon, title: title),
          SizedBox(height: 10.px),
          Text(
            body,
            style: TextStyle(
              color: Colors.white.withOpacity(0.75),
              fontSize: 13.px,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Current Conditions ───────────────────────────────────────────────────────
class _CurrentConditionsCard extends GetView<AirQuilityController> {
  const _CurrentConditionsCard();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final cond = controller.condition.value;
      final temp = controller.temperature.value;
      final hum = controller.humidity.value;
      final ws = controller.windSpeed.value;
      final wd = controller.windDirection.value;

      // Don't show if no weather data
      if (cond.isEmpty && temp.isEmpty) return const SizedBox.shrink();

      return _CardWrapper(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader(
              icon: Icons.cloud_outlined,
              title: 'Current Weather Conditions',
            ),
            SizedBox(height: 14.px),
            Row(
              children: [
                if (temp.isNotEmpty)
                  _CondTile(icon: Icons.thermostat, label: 'Temp', value: temp),
                if (hum.isNotEmpty)
                  _CondTile(
                      icon: Icons.water_drop_outlined,
                      label: 'Humidity',
                      value: hum),
                if (ws.isNotEmpty)
                  _CondTile(
                    icon: Icons.air,
                    label: 'Wind',
                    value: wd.isNotEmpty ? '$wd $ws' : ws,
                  ),
              ],
            ),
            if (cond.isNotEmpty) ...[
              SizedBox(height: 10.px),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                    horizontal: 14.px, vertical: 8.px),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.wb_sunny_outlined,
                        color: Colors.white54, size: 16),
                    SizedBox(width: 8.px),
                    Text(
                      cond,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13.px,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      );
    });
  }
}

class _CondTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _CondTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.px),
        padding: EdgeInsets.symmetric(vertical: 12.px),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white54, size: 18),
            SizedBox(height: 6.px),
            Text(
              label,
              style: TextStyle(
                color: Colors.white38,
                fontSize: 10.px,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 4.px),
            Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.px,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Reusable widgets ─────────────────────────────────────────────────────────
class _CardWrapper extends StatelessWidget {
  final Widget child;

  const _CardWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.px),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: child,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: primaryColor2.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: primaryColor2, size: 16),
        ),
        SizedBox(width: 10.px),
        Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 15.px,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────
Color _aqiColor(int aqi) {
  if (aqi <= 50) return const Color(0xFF00E676);
  if (aqi <= 100) return const Color(0xFFFFEB3B);
  if (aqi <= 150) return const Color(0xFFFF9800);
  if (aqi <= 200) return const Color(0xFFFF5252);
  if (aqi <= 300) return const Color(0xFF9C27B0);
  return const Color(0xFF880E4F);
}

IconData _moodIcon(int aqi) {
  if (aqi <= 50) return Icons.sentiment_very_satisfied_rounded;
  if (aqi <= 100) return Icons.sentiment_satisfied_rounded;
  if (aqi <= 150) return Icons.sentiment_neutral_rounded;
  if (aqi <= 200) return Icons.sentiment_dissatisfied_rounded;
  return Icons.sick_rounded;
}