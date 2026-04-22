enum WcValidationResult {
  ok,
  unsupportedChain,
  unsupportedMethod,
  noRequiredNamespace,
}

class WcProposalView {
  final int id;
  final String pairingTopic;
  final String dappName;
  final String? dappUrl;
  final String? dappIcon;
  final String? dappDescription;
  final List<String> requiredChains;
  final List<String> requiredMethods;
  final List<String> optionalChains;
  final List<String> optionalMethods;
  final WcValidationResult validation;

  const WcProposalView({
    required this.id,
    required this.pairingTopic,
    required this.dappName,
    required this.requiredChains,
    required this.requiredMethods,
    required this.optionalChains,
    required this.optionalMethods,
    required this.validation,
    this.dappUrl,
    this.dappIcon,
    this.dappDescription,
  });
}
