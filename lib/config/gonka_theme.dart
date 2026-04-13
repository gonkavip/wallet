import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'design_tokens.dart';

ThemeData buildGonkaDarkTheme() {
  const colorScheme = ColorScheme.dark(
    brightness: Brightness.dark,
    primary: GonkaColors.accentBlue,
    onPrimary: Colors.white,
    primaryContainer: GonkaColors.accentBlue,
    onPrimaryContainer: Colors.white,
    secondary: GonkaColors.accentBlue,
    onSecondary: Colors.white,
    secondaryContainer: GonkaColors.accentBlue,
    onSecondaryContainer: Colors.white,
    tertiary: GonkaColors.accentBlue,
    onTertiary: Colors.white,
    error: GonkaColors.error,
    onError: Colors.white,
    surface: GonkaColors.bgSecondary,
    onSurface: GonkaColors.textPrimary,
    onSurfaceVariant: GonkaColors.textMuted,
    surfaceContainerLowest: GonkaColors.bgPrimary,
    surfaceContainerLow: GonkaColors.bgSecondary,
    surfaceContainer: GonkaColors.bgCard,
    surfaceContainerHigh: GonkaColors.bgCard,
    surfaceContainerHighest: GonkaColors.bgElevated,
    outline: GonkaColors.borderStrong,
    outlineVariant: GonkaColors.borderSubtle,
  );



  final textTheme = Typography.whiteMountainView.apply(
    bodyColor: GonkaColors.textPrimary,
    displayColor: GonkaColors.textPrimary,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: GonkaColors.bgPrimary,
    canvasColor: GonkaColors.bgPrimary,
    dividerColor: GonkaColors.borderSubtle,
    textTheme: textTheme,
    primaryTextTheme: textTheme,

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      foregroundColor: GonkaColors.textPrimary,
      iconTheme: IconThemeData(color: GonkaColors.iconPrimary),
      actionsIconTheme: IconThemeData(color: GonkaColors.iconPrimary),
      titleTextStyle: TextStyle(
        color: GonkaColors.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: GonkaColors.bgPrimary,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    ),

    cardTheme: CardThemeData(
      color: GonkaColors.bgCard,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(GonkaRadius.lg),
        side: const BorderSide(color: GonkaColors.borderSubtle, width: 1),
      ),
    ),

    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: GonkaColors.accentBlue,
        foregroundColor: Colors.white,
        disabledBackgroundColor: GonkaColors.bgCard,
        disabledForegroundColor: GonkaColors.textMuted,
        minimumSize: const Size(0, 56),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        shape: const StadiumBorder(),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: GonkaColors.textPrimary,
        backgroundColor: Colors.transparent,
        minimumSize: const Size(0, 56),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        side: const BorderSide(color: GonkaColors.borderStrong, width: 1),
        shape: const StadiumBorder(),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: GonkaColors.accentBlue,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),

    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: GonkaColors.iconPrimary,
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: GonkaColors.bgSecondary,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: const TextStyle(color: GonkaColors.textMuted),
      labelStyle: const TextStyle(color: GonkaColors.textMuted),
      floatingLabelStyle: const TextStyle(color: GonkaColors.accentBlue),
      prefixIconColor: GonkaColors.iconMuted,
      suffixIconColor: GonkaColors.iconMuted,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(GonkaRadius.md),
        borderSide: const BorderSide(color: GonkaColors.borderSubtle),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(GonkaRadius.md),
        borderSide: const BorderSide(color: GonkaColors.borderSubtle),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(GonkaRadius.md),
        borderSide: const BorderSide(color: GonkaColors.accentBlue, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(GonkaRadius.md),
        borderSide: const BorderSide(color: GonkaColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(GonkaRadius.md),
        borderSide: const BorderSide(color: GonkaColors.error, width: 1.5),
      ),
      errorStyle: const TextStyle(color: GonkaColors.error),
    ),

    dividerTheme: const DividerThemeData(
      color: GonkaColors.borderSubtle,
      thickness: 1,
      space: 1,
    ),

    listTileTheme: const ListTileThemeData(
      textColor: GonkaColors.textPrimary,
      iconColor: GonkaColors.iconMuted,
      tileColor: Colors.transparent,
      selectedColor: GonkaColors.accentBlue,
      selectedTileColor: GonkaColors.glowBlue,
      titleTextStyle: TextStyle(
        color: GonkaColors.textPrimary,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      subtitleTextStyle: TextStyle(
        color: GonkaColors.textMuted,
        fontSize: 13,
      ),
    ),

    chipTheme: ChipThemeData(
      backgroundColor: GonkaColors.bgCard,
      selectedColor: GonkaColors.accentBlue,
      disabledColor: GonkaColors.bgSecondary,
      labelStyle: const TextStyle(color: GonkaColors.textPrimary),
      secondaryLabelStyle: const TextStyle(color: Colors.white),
      side: const BorderSide(color: GonkaColors.borderSubtle),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(GonkaRadius.md),
      ),
    ),

    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GonkaColors.accentBlue;
          }
          return GonkaColors.bgCard;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return GonkaColors.textPrimary;
        }),
        iconColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return GonkaColors.iconMuted;
        }),
        side: WidgetStateProperty.all(
          const BorderSide(color: GonkaColors.borderSubtle),
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(GonkaRadius.md),
          ),
        ),
      ),
    ),

    tabBarTheme: const TabBarThemeData(
      labelColor: GonkaColors.textPrimary,
      unselectedLabelColor: GonkaColors.textMuted,
      indicatorColor: GonkaColors.accentBlue,
      indicatorSize: TabBarIndicatorSize.label,
      dividerColor: Colors.transparent,
      labelStyle: TextStyle(fontWeight: FontWeight.w600),
    ),

    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: GonkaColors.bgSecondary,
      surfaceTintColor: Colors.transparent,
      modalBackgroundColor: GonkaColors.bgSecondary,
      modalBarrierColor: Colors.black.withValues(alpha: 0.7),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(GonkaRadius.xl),
        ),
      ),
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: GonkaColors.bgSecondary,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(GonkaRadius.lg),
        side: const BorderSide(color: GonkaColors.borderSubtle),
      ),
      titleTextStyle: const TextStyle(
        color: GonkaColors.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
      contentTextStyle: const TextStyle(
        color: GonkaColors.textPrimary,
        fontSize: 14,
      ),
    ),

    snackBarTheme: SnackBarThemeData(
      backgroundColor: GonkaColors.bgCard,
      contentTextStyle: const TextStyle(color: GonkaColors.textPrimary),
      actionTextColor: GonkaColors.accentBlue,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(GonkaRadius.md),
        side: const BorderSide(color: GonkaColors.borderSubtle),
      ),
    ),

    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return Colors.white;
        return GonkaColors.textMuted;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return GonkaColors.accentBlue;
        return GonkaColors.bgCard;
      }),
      trackOutlineColor: WidgetStateProperty.all(GonkaColors.borderSubtle),
    ),

    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return GonkaColors.accentBlue;
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(Colors.white),
      side: const BorderSide(color: GonkaColors.borderStrong, width: 1.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
    ),

    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return GonkaColors.accentBlue;
        return GonkaColors.textMuted;
      }),
    ),

    popupMenuTheme: PopupMenuThemeData(
      color: GonkaColors.bgCard,
      surfaceTintColor: Colors.transparent,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(GonkaRadius.md),
        side: const BorderSide(color: GonkaColors.borderSubtle),
      ),
      textStyle: const TextStyle(color: GonkaColors.textPrimary),
    ),

    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: GonkaColors.accentBlue,
      linearTrackColor: GonkaColors.bgCard,
      circularTrackColor: GonkaColors.bgCard,
    ),

    iconTheme: const IconThemeData(color: GonkaColors.iconPrimary),
    primaryIconTheme: const IconThemeData(color: GonkaColors.iconPrimary),

    splashFactory: InkRipple.splashFactory,
    highlightColor: GonkaColors.glowBlue,
    splashColor: GonkaColors.glowBlue,
  );
}
