import 'dart:convert';
import 'dart:typed_data';

class ProtobufWriter {
  final _buffer = BytesBuilder(copy: false);

  void writeVarint(int fieldNumber, int value) {
    _writeTag(fieldNumber, 0);
    _writeRawVarint(value);
  }

  void writeString(int fieldNumber, String value) {
    _writeTag(fieldNumber, 2);
    final bytes = utf8.encode(value);
    _writeRawVarint(bytes.length);
    _buffer.add(bytes);
  }

  void writeBytes(int fieldNumber, Uint8List value) {
    _writeTag(fieldNumber, 2);
    _writeRawVarint(value.length);
    _buffer.add(value);
  }

  void writeMessage(int fieldNumber, Uint8List encodedMessage) {
    _writeTag(fieldNumber, 2);
    _writeRawVarint(encodedMessage.length);
    _buffer.add(encodedMessage);
  }

  void writeUint64(int fieldNumber, int value) {
    _writeTag(fieldNumber, 0);
    _writeRawVarint(value);
  }

  void _writeTag(int fieldNumber, int wireType) {
    _writeRawVarint((fieldNumber << 3) | wireType);
  }

  void _writeRawVarint(int value) {
    var v = value;
    while (v > 0x7f) {
      _buffer.addByte((v & 0x7f) | 0x80);
      v >>= 7;
    }
    _buffer.addByte(v & 0x7f);
  }

  Uint8List toBytes() => _buffer.toBytes();
}

class ProtobufReader {
  final Uint8List _data;
  int _pos = 0;

  ProtobufReader(this._data);

  bool get hasMore => _pos < _data.length;

  (int fieldNumber, int wireType) readTag() {
    final tag = _readRawVarint();
    return (tag >> 3, tag & 0x7);
  }

  int readVarint() => _readRawVarint();

  Uint8List readBytes() {
    final length = _readRawVarint();
    final bytes = _data.sublist(_pos, _pos + length);
    _pos += length;
    return bytes;
  }

  String readString() => utf8.decode(readBytes());

  void skip(int wireType) {
    switch (wireType) {
      case 0:
        _readRawVarint();
      case 1:
        _pos += 8;
      case 2:
        final len = _readRawVarint();
        _pos += len;
      case 5:
        _pos += 4;
    }
  }

  int _readRawVarint() {
    var result = 0;
    var shift = 0;
    while (true) {
      final byte = _data[_pos++];
      result |= (byte & 0x7f) << shift;
      if ((byte & 0x80) == 0) break;
      shift += 7;
    }
    return result;
  }
}
