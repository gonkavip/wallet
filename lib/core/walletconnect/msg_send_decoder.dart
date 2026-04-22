import 'dart:typed_data';
import '../transaction/protobuf_utils.dart';

class CoinDecoded {
  final String denom;
  final String amount;
  const CoinDecoded({required this.denom, required this.amount});
}

class MsgSendDecoded {
  final String fromAddress;
  final String toAddress;
  final List<CoinDecoded> amount;

  const MsgSendDecoded({
    required this.fromAddress,
    required this.toAddress,
    required this.amount,
  });
}

class MsgSendDecoder {
  static MsgSendDecoded? tryDecode(Uint8List valueBytes) {
    try {
      final reader = ProtobufReader(valueBytes);
      String? from;
      String? to;
      final coins = <CoinDecoded>[];

      while (reader.hasMore) {
        final (fieldNumber, wireType) = reader.readTag();
        switch (fieldNumber) {
          case 1:
            if (wireType != 2) return null;
            from = reader.readString();
          case 2:
            if (wireType != 2) return null;
            to = reader.readString();
          case 3:
            if (wireType != 2) return null;
            final coinBytes = reader.readBytes();
            final coin = _decodeCoin(coinBytes);
            if (coin == null) return null;
            coins.add(coin);
          default:
            reader.skip(wireType);
        }
      }
      if (from == null || to == null) return null;
      return MsgSendDecoded(fromAddress: from, toAddress: to, amount: coins);
    } catch (_) {
      return null;
    }
  }

  static CoinDecoded? _decodeCoin(Uint8List bytes) {
    try {
      final reader = ProtobufReader(bytes);
      String? denom;
      String? amount;
      while (reader.hasMore) {
        final (fieldNumber, wireType) = reader.readTag();
        switch (fieldNumber) {
          case 1:
            if (wireType != 2) return null;
            denom = reader.readString();
          case 2:
            if (wireType != 2) return null;
            amount = reader.readString();
          default:
            reader.skip(wireType);
        }
      }
      if (denom == null || amount == null) return null;
      return CoinDecoded(denom: denom, amount: amount);
    } catch (_) {
      return null;
    }
  }
}
