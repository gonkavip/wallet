import 'wc_constants.dart';

class WcUriData {
  final String topic;
  final String version;
  final String relayProtocol;
  final DateTime? expiry;
  final String raw;

  const WcUriData({
    required this.topic,
    required this.version,
    required this.relayProtocol,
    required this.raw,
    this.expiry,
  });

  bool get isExpired {
    final e = expiry;
    if (e == null) return false;
    return DateTime.now().isAfter(e);
  }
}

class WcUriParser {
  static String? extractFromString(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return null;

    if (trimmed.startsWith('wc:')) {
      return trimmed;
    }

    final parsed = Uri.tryParse(trimmed);
    if (parsed == null) return null;
    if (parsed.scheme == WcConstants.deepLinkScheme &&
        parsed.host == WcConstants.deepLinkHost) {
      final inner = parsed.queryParameters['uri'];
      if (inner != null && inner.startsWith('wc:')) return inner;
    }
    return null;
  }

  static WcUriData? parse(String raw) {
    if (!raw.startsWith('wc:')) return null;
    final afterScheme = raw.substring(3);
    final qIndex = afterScheme.indexOf('?');
    final head = qIndex == -1 ? afterScheme : afterScheme.substring(0, qIndex);
    final tail = qIndex == -1 ? '' : afterScheme.substring(qIndex + 1);

    final atIndex = head.indexOf('@');
    if (atIndex <= 0) return null;
    final topic = head.substring(0, atIndex);
    final version = head.substring(atIndex + 1);
    if (version != '2') return null;

    final params = _parseQuery(tail);
    final relay = params['relay-protocol'] ?? '';
    if (relay.isEmpty) return null;

    DateTime? expiry;
    final expiryStr = params['expiryTimestamp'];
    if (expiryStr != null) {
      final seconds = int.tryParse(expiryStr);
      if (seconds != null) {
        expiry = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
      }
    }

    return WcUriData(
      topic: topic,
      version: version,
      relayProtocol: relay,
      expiry: expiry,
      raw: raw,
    );
  }

  static Map<String, String> _parseQuery(String query) {
    if (query.isEmpty) return const {};
    final out = <String, String>{};
    for (final pair in query.split('&')) {
      if (pair.isEmpty) continue;
      final eq = pair.indexOf('=');
      if (eq == -1) {
        out[Uri.decodeComponent(pair)] = '';
      } else {
        out[Uri.decodeComponent(pair.substring(0, eq))] =
            Uri.decodeComponent(pair.substring(eq + 1));
      }
    }
    return out;
  }
}
