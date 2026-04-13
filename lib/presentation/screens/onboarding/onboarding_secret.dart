class OnboardingSecret {
  final String? mnemonic;
  final String? privateKeyHex;

  const OnboardingSecret.mnemonic(String this.mnemonic) : privateKeyHex = null;
  const OnboardingSecret.privateKey(String this.privateKeyHex) : mnemonic = null;

  bool get isMnemonic => mnemonic != null;
}
