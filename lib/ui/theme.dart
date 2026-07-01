import 'package:flutter/material.dart';

/// Custom color palette mirroring the HTML mockup's CSS variables.
///
/// Exposed as a [ThemeExtension] so widgets can read tokens via
/// `Theme.of(context).extension<AppColors>()!` (or the [context] helper below)
/// and they automatically swap with the active light/dark theme.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  final Color accent;
  final Color accent2;
  final Color accentSoft;
  final Color bg;
  final Color surface;
  final Color surface2;
  final Color text;
  final Color text2;
  final Color text3;
  final Color border;

  const AppColors({
    required this.accent,
    required this.accent2,
    required this.accentSoft,
    required this.bg,
    required this.surface,
    required this.surface2,
    required this.text,
    required this.text2,
    required this.text3,
    required this.border,
  });

  /// Accent gradient used for the active period, FAB, avatars, etc.
  LinearGradient get accentGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [accent, accent2],
      );

  static const light = AppColors(
    accent: Color(0xFF5B5BF0),
    accent2: Color(0xFF8A6CF6),
    accentSoft: Color(0xFFECECFE),
    bg: Color(0xFFF4F5F9),
    surface: Color(0xFFFFFFFF),
    surface2: Color(0XFBFBFE),
    text: Color(0xFF14161F),
    text2: Color(0xFF5C6072),
    text3: Color(0xFF9AA0B4),
    border: Color(0xFFE9EAF2),
  );

  static const dark = AppColors(
    accent: Color(0xFF7C7CFF),
    accent2: Color(0xFFA98BFF),
    accentSoft: Color(0xFF23233A),
    bg: Color(0xFF0C0D12),
    surface: Color(0xFF16181F),
    surface2: Color(0xFF1C1E27),
    text: Color(0xFFF3F4F8),
    text2: Color(0xFFA7ADC0),
    text3: Color(0xFF6B7185),
    border: Color(0xFF262936),
  );

  @override
  AppColors copyWith({
    Color? accent,
    Color? accent2,
    Color? accentSoft,
    Color? bg,
    Color? surface,
    Color? surface2,
    Color? text,
    Color? text2,
    Color? text3,
    Color? border,
  }) {
    return AppColors(
      accent: accent ?? this.accent,
      accent2: accent2 ?? this.accent2,
      accentSoft: accentSoft ?? this.accentSoft,
      bg: bg ?? this.bg,
      surface: surface ?? this.surface,
      surface2: surface2 ?? this.surface2,
      text: text ?? this.text,
      text2: text2 ?? this.text2,
      text3: text3 ?? this.text3,
      border: border ?? this.border,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      accent: Color.lerp(accent, other.accent, t)!,
      accent2: Color.lerp(accent2, other.accent2, t)!,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t)!,
      bg: Color.lerp(bg, other.bg, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surface2: Color.lerp(surface2, other.surface2, t)!,
      text: Color.lerp(text, other.text, t)!,
      text2: Color.lerp(text2, other.text2, t)!,
      text3: Color.lerp(text3, other.text3, t)!,
      border: Color.lerp(border, other.border, t)!,
    );
  }
}

/// Convenience accessor: `context.colors.accent`.
extension AppColorsContext on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}

ThemeData _buildTheme(AppColors c, Brightness brightness) {
  final base = ThemeData(
    useMaterial3: true,
    brightness: brightness,
    scaffoldBackgroundColor: c.bg,
    colorScheme: ColorScheme.fromSeed(
      seedColor: c.accent,
      brightness: brightness,
    ).copyWith(surface: c.surface),
    fontFamily: 'Inter',
  );
  return base.copyWith(
    extensions: [c],
    textTheme: base.textTheme.apply(
      bodyColor: c.text,
      displayColor: c.text,
    ),
  );
}

ThemeData buildLightTheme() => _buildTheme(AppColors.light, Brightness.light);
ThemeData buildDarkTheme() => _buildTheme(AppColors.dark, Brightness.dark);

/// Simple [ChangeNotifier] that drives [MaterialApp.themeMode] so the
/// header's dark-mode toggle can flip the whole app.
class ThemeController extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.light;
  ThemeMode get mode => _mode;

  bool get isDark => _mode == ThemeMode.dark;

  void toggle() {
    _mode = isDark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }
}

/// Fallback palette used to colour a class when its [ClassPeriod.color] hasn't
/// been set to anything meaningful (the stub data uses [Colors.black]). Keyed
/// by period number so a given class keeps a stable colour day to day.
const List<Color> kClassPalette = [
  Color(0xFF14B8A6), // teal  (alg)
  Color(0xFFF43F5E), // rose  (eng)
  Color(0xFF22B07D), // green (bio)
  Color(0xFF3B82F6), // blue  (chem)
  Color(0xFFA855F7), // purple(span)
  Color(0xFFF59E0B), // amber (hist)
  Color(0xFFEF4444), // red   (gym)
  Color(0xFF6366F1), // indigo
];
