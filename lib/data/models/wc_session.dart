class WcSession {
  final String topic;
  final String walletId;
  final String walletAddress;
  final String dappName;
  final String? dappUrl;
  final String? dappIconUrl;
  final String? dappDescription;
  final List<String> chains;
  final List<String> methods;
  final DateTime approvedAt;
  final DateTime? expiresAt;

  WcSession({
    required this.topic,
    required this.walletId,
    required this.walletAddress,
    required this.dappName,
    required this.chains,
    required this.methods,
    required this.approvedAt,
    this.dappUrl,
    this.dappIconUrl,
    this.dappDescription,
    this.expiresAt,
  });

  Map<String, dynamic> toJson() => {
        'topic': topic,
        'walletId': walletId,
        'walletAddress': walletAddress,
        'dappName': dappName,
        'dappUrl': dappUrl,
        'dappIconUrl': dappIconUrl,
        'dappDescription': dappDescription,
        'chains': chains,
        'methods': methods,
        'approvedAt': approvedAt.toIso8601String(),
        'expiresAt': expiresAt?.toIso8601String(),
      };

  factory WcSession.fromJson(Map<String, dynamic> json) => WcSession(
        topic: json['topic'] as String,
        walletId: json['walletId'] as String,
        walletAddress: json['walletAddress'] as String,
        dappName: json['dappName'] as String,
        dappUrl: json['dappUrl'] as String?,
        dappIconUrl: json['dappIconUrl'] as String?,
        dappDescription: json['dappDescription'] as String?,
        chains: (json['chains'] as List).cast<String>(),
        methods: (json['methods'] as List).cast<String>(),
        approvedAt: DateTime.parse(json['approvedAt'] as String),
        expiresAt: json['expiresAt'] != null
            ? DateTime.parse(json['expiresAt'] as String)
            : null,
      );
}
