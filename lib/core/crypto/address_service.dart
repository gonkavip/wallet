import 'dart:typed_data';
import 'package:bech32/bech32.dart';
import 'package:pointycastle/digests/sha256.dart';
import 'package:pointycastle/digests/ripemd160.dart';
import '../../config/constants.dart';
import 'hd_key_service.dart';

class AddressService {
  static final _bech32Codec = Bech32Codec();

  static String fromPublicKey(Uint8List publicKey) {
    final sha256 = SHA256Digest();
    final shaHash = sha256.process(publicKey);

    final ripemd160 = RIPEMD160Digest();
    final ripemdHash = ripemd160.process(shaHash);

    final converted = _convertBits(ripemdHash, 8, 5, true);
    final bech = Bech32(GonkaConstants.bech32Prefix, converted);
    return _bech32Codec.encode(bech);
  }

  static String fromMnemonic(String mnemonic) {
    final pubKey = HDKeyService.derivePublicKey(mnemonic);
    return fromPublicKey(pubKey);
  }

  static String toValoperAddress(String address) {
    final decoded = _bech32Codec.decode(address);
    final bech = Bech32('${GonkaConstants.bech32Prefix}valoper', decoded.data);
    return _bech32Codec.encode(bech);
  }

  static bool validate(String address) {
    try {
      if (!address.startsWith('${GonkaConstants.bech32Prefix}1')) return false;
      final decoded = _bech32Codec.decode(address);
      if (decoded.hrp != GonkaConstants.bech32Prefix) return false;
      final data = _convertBits(Uint8List.fromList(decoded.data), 5, 8, false);
      return data.length == 20;
    } catch (_) {
      return false;
    }
  }

  static List<int> _convertBits(Uint8List data, int fromBits, int toBits, bool pad) {
    var acc = 0;
    var bits = 0;
    final result = <int>[];
    final maxv = (1 << toBits) - 1;

    for (final value in data) {
      if (value < 0 || (value >> fromBits) != 0) {
        throw Exception('Invalid value: $value');
      }
      acc = (acc << fromBits) | value;
      bits += fromBits;
      while (bits >= toBits) {
        bits -= toBits;
        result.add((acc >> bits) & maxv);
      }
    }

    if (pad) {
      if (bits > 0) {
        result.add((acc << (toBits - bits)) & maxv);
      }
    }

    return result;
  }
}
