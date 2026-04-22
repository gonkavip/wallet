import 'dart:convert';
import 'package:hive/hive.dart';
import '../models/address_book_entry.dart';

class AddressBookRepository {
  static const String _boxName = 'address_book';
  late Box<String> _box;

  Future<void> init() async {
    _box = await Hive.openBox<String>(_boxName);
  }

  Future<void> add(AddressBookEntry entry) async {
    await _box.put(entry.id, jsonEncode(entry.toJson()));
  }

  List<AddressBookEntry> getAll() {
    final result = <AddressBookEntry>[];
    for (final key in _box.keys) {
      final raw = _box.get(key);
      if (raw == null) continue;
      try {
        result.add(
          AddressBookEntry.fromJson(jsonDecode(raw) as Map<String, dynamic>),
        );
      } catch (_) {}
    }
    result.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return result;
  }

  Future<void> delete(String id) => _box.delete(id);

  Future<void> update(String id, String newName) async {
    final raw = _box.get(id);
    if (raw == null) return;
    try {
      final entry =
          AddressBookEntry.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      final updated = entry.copyWith(name: newName);
      await _box.put(id, jsonEncode(updated.toJson()));
    } catch (_) {}
  }

  bool containsAddress(String address) {
    for (final key in _box.keys) {
      final raw = _box.get(key);
      if (raw == null) continue;
      try {
        final entry =
            AddressBookEntry.fromJson(jsonDecode(raw) as Map<String, dynamic>);
        if (entry.address == address) return true;
      } catch (_) {}
    }
    return false;
  }
}
