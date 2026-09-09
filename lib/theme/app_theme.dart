import 'package:flutter/material.dart';
import 'package:directory_dash/core/constants/exam_constants.dart';

class AppTheme {
  static const Color seedColor = Color(0xFF007DC1);
  static const Color xpColor = Colors.amber;
  static const Color streakColor = Colors.deepOrange;

  // Assigned by position in ExamConstants.allDomains rather than keyed by
  // name, so a full exam-content pivot (new domain list, different names)
  // still gets stable, distinct colors with no edits needed here.
  static const List<Color> _domainPalette = [
    Colors.lightBlueAccent,
    Colors.tealAccent,
    Colors.indigoAccent,
    Colors.purpleAccent,
    Colors.greenAccent,
    Colors.orangeAccent,
    Colors.pinkAccent,
    Colors.amberAccent,
    Colors.cyanAccent,
    Colors.limeAccent,
    Colors.deepOrangeAccent,
    Colors.deepPurpleAccent,
  ];

  static Color domainColor(String domain) {
    final index = ExamConstants.allDomains.indexOf(domain);
    if (index == -1) return Colors.blueGrey;
    return _domainPalette[index % _domainPalette.length];
  }

  /// Clearance to reserve below bottom-anchored primary action buttons so
  /// they don't sit inside the Android gesture-nav swallow zone.
  ///
  /// `systemGestureInsets.bottom` alone is not trustworthy: several OEM
  /// Android skins (and older Android versions) never populate it and it
  /// reads as zero even though a real gesture nav bar is intercepting
  /// touches, which is why a device-tested `systemGestureInsets + 12`
  /// fix can look correct on one device/emulator and still eat taps on
  /// another. `viewPadding.bottom` is populated far more consistently for
  /// the nav bar reservation itself, so take whichever inset source is
  /// larger and pad well past it with a fixed floor.
  static double safeBottomInset(BuildContext context) {
    final mq = MediaQuery.of(context);
    final reported = mq.systemGestureInsets.bottom > mq.viewPadding.bottom
        ? mq.systemGestureInsets.bottom
        : mq.viewPadding.bottom;
    return reported + 24;
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.dark,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xFF0D1117),
      appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0),
    );
  }
}
