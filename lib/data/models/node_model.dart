class NodeModel {
  final String url;
  final String label;
  final bool proxyMode;
  final int latencyMs;
  final bool isSyncing;
  final String chainId;
  final bool isOnline;
  final bool isHealthy;
  final bool isChecking;

  NodeModel({
    required this.url,
    required this.label,
    this.proxyMode = true,
    this.latencyMs = 0,
    this.isSyncing = false,
    this.chainId = '',
    this.isOnline = false,
    this.isHealthy = false,
    this.isChecking = false,
  });

  NodeModel copyWith({
    String? url,
    String? label,
    bool? proxyMode,
    int? latencyMs,
    bool? isSyncing,
    String? chainId,
    bool? isOnline,
    bool? isHealthy,
    bool? isChecking,
  }) {
    return NodeModel(
      url: url ?? this.url,
      label: label ?? this.label,
      proxyMode: proxyMode ?? this.proxyMode,
      latencyMs: latencyMs ?? this.latencyMs,
      isSyncing: isSyncing ?? this.isSyncing,
      chainId: chainId ?? this.chainId,
      isOnline: isOnline ?? this.isOnline,
      isHealthy: isHealthy ?? this.isHealthy,
      isChecking: isChecking ?? this.isChecking,
    );
  }

  Map<String, dynamic> toJson() => {
        'url': url,
        'label': label,
        'proxyMode': proxyMode,
        'latencyMs': latencyMs,
        'isSyncing': isSyncing,
        'chainId': chainId,
        'isOnline': isOnline,
        'isHealthy': isHealthy,
      };

  factory NodeModel.fromJson(Map<String, dynamic> json) => NodeModel(
        url: json['url'],
        label: json['label'],
        proxyMode: json['proxyMode'] ?? true,
        latencyMs: json['latencyMs'] ?? 0,
        isSyncing: json['isSyncing'] ?? false,
        chainId: json['chainId'] ?? '',
        isOnline: json['isOnline'] ?? false,
        isHealthy: json['isHealthy'] ?? false,
      );
}
