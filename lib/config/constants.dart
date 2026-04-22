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

String _addCommas(String intStr) {
  final negative = intStr.startsWith('-');
  final digits = negative ? intStr.substring(1) : intStr;
  final buf = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buf.write(',');
    buf.write(digits[i]);
  }
  return negative ? '-${buf.toString()}' : buf.toString();
}

String formatNgonka(BigInt ngonka) {
  return _addCommas(ngonka.toString());
}

String formatGnk(BigInt ngonka) {
  final whole = ngonka ~/ denomMultiplier;
  final fraction = (ngonka % denomMultiplier).abs();
  final fractionStr = fraction.toString().padLeft(GonkaConstants.denomExponent, '0');
  final wholeFormatted = _addCommas(whole.toString());

  if (whole.abs() >= BigInt.one) {
    final twoDigits = fractionStr.substring(0, 2);
    final trimmed = twoDigits.replaceAll(RegExp(r'0+$'), '');
    if (trimmed.isEmpty) return wholeFormatted;
    return '$wholeFormatted.$twoDigits';
  } else {
    final trimmedAll = fractionStr.replaceAll(RegExp(r'0+$'), '');
    if (trimmedAll.isEmpty) return '0';
    var firstNonZero = 0;
    while (firstNonZero < fractionStr.length && fractionStr[firstNonZero] == '0') {
      firstNonZero++;
    }
    final end = (firstNonZero + 2).clamp(0, fractionStr.length);
    final significant = fractionStr.substring(0, end).replaceAll(RegExp(r'0+$'), '');
    return '0.$significant';
  }
}

String formatGnkShort(BigInt ngonka) {
  return formatGnk(ngonka);
}

String formatUsd(BigInt ngonka, double pricePerGnk) {
  final gnk = ngonka.toDouble() / denomMultiplier.toDouble();
  final usd = gnk * pricePerGnk;
  final whole = usd.truncate();
  final fraction = ((usd - whole) * 100).round().abs();
  final wholeStr = _addCommas(whole.toString());
  final fractionStr = fraction.toString().padLeft(2, '0');
  return '\$$wholeStr.$fractionStr';
}

BigInt parseGnk(String gnkAmount) {
  final cleaned = gnkAmount.replaceAll(',', '');
  final parts = cleaned.split('.');
  final whole = BigInt.parse(parts[0]) * denomMultiplier;
  if (parts.length == 1) return whole;
  final fractionStr = parts[1].padRight(GonkaConstants.denomExponent, '0');
  return whole + BigInt.parse(fractionStr.substring(0, GonkaConstants.denomExponent));
}
