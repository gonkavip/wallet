import 'package:flutter/material.dart';

abstract class GonkaColors {
  static const Color bgPrimary = Color(0xFF06060B);
  static const Color bgSecondary = Color(0xFF0E0E16);
  static const Color bgCard = Color(0xFF141420);
  static const Color bgElevated = Color(0xFF1A1A2E);

  static const Color textPrimary = Color(0xFFF0F0F5);
  static const Color textMuted = Color(0xFF8A8AA0);

  static const Color iconPrimary = Color(0xFFE1ECF7);
  static const Color iconMuted = Color(0xFF60A5FA);

  static const Color accentBlue = Color(0xFF3B82F6);
  static const Color accentIndigo = Color(0xFF818CF8);
  static const Color accentPurple = Color(0xFFC084FC);

  static const Color glowBlue = Color(0x263B82F6);
  static const Color glowIndigo = Color(0x1A818CF8);

  static const Color borderSubtle = Color(0x0FFFFFFF);
  static const Color borderStrong = Color(0x1FFFFFFF);

  static const Color success = Color(0xFF22C55E);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  static const Color txReceive = Color(0xFF22C55E);
  static const Color txSend = Color(0xFFF97316);
  static const Color txVesting = Color(0xFF06B6D4);
  static const Color txCollateralDeposit = Color(0xFF3B82F6);
  static const Color txCollateralWithdraw = Color(0xFF14B8A6);
  static const Color txGrant = Color(0xFF64748B);
  static const Color txUnjail = Color(0xFFF59E0B);
  static const Color txVote = Color(0xFF3B82F6);
  static const Color txContract = Color(0xFFEA580C);
  static const Color txContractWithdraw = Color(0xFF22C55E);
}

abstract class GonkaGradients {

  static const LinearGradient walletCard = LinearGradient(
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
    colors: [
      Color(0xFF0F172A),
      Color(0xFF254C90),
      Color(0xFF3B82F6),
    ],
    stops: [0.0, 0.6, 1.0],
  );

  static const LinearGradient brandText = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      GonkaColors.accentBlue,
      GonkaColors.accentIndigo,
      GonkaColors.accentPurple,
    ],
    stops: [0.0, 0.5, 1.0],
  );

  static const RadialGradient heroGlow = RadialGradient(
    center: Alignment.center,
    radius: 0.7,
    colors: [GonkaColors.glowBlue, Colors.transparent],
    stops: [0.0, 1.0],
  );
}

abstract class GonkaRadius {
  static const double sm = 8.0;
  static const double md = 14.0;
  static const double lg = 20.0;
  static const double xl = 28.0;
  static const double pill = 999.0;
}

abstract class GonkaShadows {
  static const List<BoxShadow> glowBlue = [
    BoxShadow(
      color: Color(0x4D1D4ED8),
      blurRadius: 30,
      spreadRadius: -5,
      offset: Offset(0, 10),
    ),
  ];

  static const List<BoxShadow> glowIndigo = [
    BoxShadow(
      color: Color(0x33818CF8),
      blurRadius: 20,
      spreadRadius: 0,
      offset: Offset(0, 6),
    ),
  ];

  static const List<BoxShadow> cardSoft = [
    BoxShadow(
      color: Color(0x66000000),
      blurRadius: 16,
      spreadRadius: 0,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> cardElevated = [
    BoxShadow(
      color: Color(0x99000000),
      blurRadius: 32,
      spreadRadius: 0,
      offset: Offset(0, 12),
    ),
  ];
}
