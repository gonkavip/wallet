class GonkaConstants {
  static const String chainId = 'gonka-mainnet';
  static const String bech32Prefix = 'gonka';
  static const String hdPath = "m/44'/1200'/0'/0/0";
  static const String baseDenom = 'ngonka';
  static const String displayDenom = 'GNK';
  static const int denomExponent = 9;
  static const int defaultGasLimit = 10000000000000;
  static const String defaultFeeAmount = '0';
  static const String msgSendTypeUrl = '/cosmos.bank.v1beta1.MsgSend';
  static const String msgDepositCollateralTypeUrl =
      '/inference.collateral.MsgDepositCollateral';
  static const String msgWithdrawCollateralTypeUrl =
      '/inference.collateral.MsgWithdrawCollateral';
  static const String msgGrantTypeUrl = '/cosmos.authz.v1beta1.MsgGrant';
  static const String msgUnjailTypeUrl = '/cosmos.slashing.v1beta1.MsgUnjail';
  static const String msgVoteTypeUrl = '/cosmos.gov.v1.MsgVote';
  static const String signMode = 'SIGN_MODE_DIRECT';
  static const String broadcastMode = 'BROADCAST_MODE_SYNC';
  static const int pinLength = 6;
  static const int maxPinAttempts = 5;
  static const int pinCooldownSeconds = 30;
  static const int clipboardClearSeconds = 60;
  static const int balanceRefreshSeconds = 30;
  static const int healthCheckSeconds = 60;
  static const int maxConsecutiveErrors = 3;
}

BigInt get denomMultiplier => BigInt.from(10).pow(GonkaConstants.denomExponent);

String formatGnk(BigInt ngonka) {
  final whole = ngonka ~/ denomMultiplier;
  final fraction = (ngonka % denomMultiplier).abs();
  final fractionStr = fraction.toString().padLeft(GonkaConstants.denomExponent, '0');
  final trimmed = fractionStr.replaceAll(RegExp(r'0+$'), '');
  if (trimmed.isEmpty) return '$whole';
  return '$whole.$trimmed';
}

String formatGnkShort(BigInt ngonka) {
  final whole = ngonka ~/ denomMultiplier;
  final fraction = (ngonka % denomMultiplier).abs();
  final fractionStr = fraction.toString().padLeft(GonkaConstants.denomExponent, '0');
  final truncated = fractionStr.substring(0, 4);
  final trimmed = truncated.replaceAll(RegExp(r'0+$'), '');
  if (trimmed.isEmpty) return '$whole';
  return '$whole.$trimmed';
}

BigInt parseGnk(String gnkAmount) {
  final parts = gnkAmount.split('.');
  final whole = BigInt.parse(parts[0]) * denomMultiplier;
  if (parts.length == 1) return whole;
  final fractionStr = parts[1].padRight(GonkaConstants.denomExponent, '0');
  return whole + BigInt.parse(fractionStr.substring(0, GonkaConstants.denomExponent));
}
