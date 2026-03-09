import 'dart:typed_data';

abstract class TxMessage {
  String get typeUrl;
  Uint8List encode();
}
