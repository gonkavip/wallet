import 'dart:convert';
import 'dart:typed_data';

class SignDirectPayload {
  final String signerAddress;
  final Uint8List bodyBytes;
  final Uint8List authInfoBytes;
  final String chainId;
  final int accountNumber;

  const SignDirectPayload({
    required this.signerAddress,
    required this.bodyBytes,
    required this.authInfoBytes,
    required this.chainId,
    required this.accountNumber,
  });
}

class SignDirectDecoder {
  static SignDirectPayload parse(dynamic rpcParams) {
    if (rpcParams is List && rpcParams.isNotEmpty) {
      rpcParams = rpcParams.first;
    }
    if (rpcParams is! Map) {
      throw const FormatException('cosmos_signDirect params not an object');
    }

    final map = Map<String, dynamic>.from(rpcParams);
    final signerAddress = map['signerAddress'] as String? ??
        map['signer'] as String? ??
        '';

    final signDocRaw = map['signDoc'] ?? map;
    if (signDocRaw is! Map) {
      throw const FormatException('signDoc is not an object');
    }
    final signDoc = Map<String, dynamic>.from(signDocRaw);

    final bodyBytes = _decodeBytes(signDoc['bodyBytes']);
    final authInfoBytes = _decodeBytes(signDoc['authInfoBytes']);
    final chainId = signDoc['chainId'] as String? ?? '';
    final accountNumber = _parseAccountNumber(signDoc['accountNumber']);

    return SignDirectPayload(
      signerAddress: signerAddress,
      bodyBytes: bodyBytes,
      authInfoBytes: authInfoBytes,
      chainId: chainId,
      accountNumber: accountNumber,
    );
  }

  static Map<String, dynamic> buildResult({
    required SignDirectPayload payload,
    required Uint8List signature,
    required Uint8List publicKey,
  }) {
    return {
      'signature': {
        'signature': base64Encode(signature),
        'pub_key': {
          'type': 'tendermint/PubKeySecp256k1',
          'value': base64Encode(publicKey),
        },
      },
      'signed': {
        'chainId': payload.chainId,
        'accountNumber': payload.accountNumber.toString(),
        'bodyBytes': base64Encode(payload.bodyBytes),
        'authInfoBytes': base64Encode(payload.authInfoBytes),
      },
    };
  }

  static Uint8List _decodeBytes(dynamic value) {
    if (value == null) return Uint8List(0);
    if (value is String) {
      if (value.isEmpty) return Uint8List(0);
      return base64Decode(value);
    }
    if (value is List) {
      return Uint8List.fromList(value.cast<int>());
    }
    throw FormatException('Unexpected bytes encoding: ${value.runtimeType}');
  }

  static int _parseAccountNumber(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.parse(value);
    if (value is num) return value.toInt();
    throw FormatException('Unexpected accountNumber type: ${value.runtimeType}');
  }
}
