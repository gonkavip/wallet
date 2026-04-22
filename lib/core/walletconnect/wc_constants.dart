class WcConstants {
  static const String projectId = String.fromEnvironment('WC_PROJECT_ID');

  static const String appName = 'Gonka Wallet';
  static const String appDescription = 'Gonka blockchain wallet';
  static const String appUrl = 'https://gonka.ai';
  static const String appIconUrl = 'https://gonka.ai/icon.png';
  static const String appRedirectNative = 'gonka://';
  static const String appRedirectUniversal = 'https://gonka.ai/wc';

  static const String cosmosNamespace = 'cosmos';
  static const String chainIdBare = 'gonka-mainnet';
  static const String caipChainId = 'cosmos:gonka-mainnet';

  static const String methodSignDirect = 'cosmos_signDirect';
  static const String methodGetAccounts = 'cosmos_getAccounts';
  static const List<String> supportedMethods = [
    methodSignDirect,
    methodGetAccounts,
  ];

  static const String eventAccountsChanged = 'accountsChanged';
  static const String eventChainChanged = 'chainChanged';
  static const List<String> supportedEvents = [
    eventAccountsChanged,
    eventChainChanged,
  ];

  static const String deepLinkScheme = 'gonka';
  static const String deepLinkHost = 'wc';
}
