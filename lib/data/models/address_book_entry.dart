class AddressBookEntry {
  final String id;
  final String name;
  final String address;
  final DateTime createdAt;

  AddressBookEntry({
    required this.id,
    required this.name,
    required this.address,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  AddressBookEntry copyWith({String? name}) {
    return AddressBookEntry(
      id: id,
      name: name ?? this.name,
      address: address,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'address': address,
        'createdAt': createdAt.toIso8601String(),
      };

  factory AddressBookEntry.fromJson(Map<String, dynamic> json) =>
      AddressBookEntry(
        id: json['id'] as String,
        name: json['name'] as String,
        address: json['address'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
