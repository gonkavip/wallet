import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/address_book_entry.dart';
import '../../data/repositories/address_book_repository.dart';

final addressBookRepositoryProvider = Provider<AddressBookRepository>((ref) {
  throw UnimplementedError(
    'addressBookRepositoryProvider must be overridden in main',
  );
});

final addressBookProvider =
    StateNotifierProvider<AddressBookNotifier, List<AddressBookEntry>>((ref) {
  return AddressBookNotifier(ref.watch(addressBookRepositoryProvider));
});

class AddressBookNotifier extends StateNotifier<List<AddressBookEntry>> {
  final AddressBookRepository _repo;

  AddressBookNotifier(this._repo) : super([]);

  void load() {
    state = _repo.getAll();
  }

  Future<void> add(String name, String address) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final entry = AddressBookEntry(id: id, name: name, address: address);
    await _repo.add(entry);
    state = _repo.getAll();
  }

  Future<void> delete(String id) async {
    await _repo.delete(id);
    state = _repo.getAll();
  }

  Future<void> rename(String id, String newName) async {
    await _repo.update(id, newName);
    state = _repo.getAll();
  }

  bool containsAddress(String address) => _repo.containsAddress(address);
}
