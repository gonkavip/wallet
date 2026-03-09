class WalletModel {
  final String id;
  final String name;
  final String address;
  final DateTime createdAt;

  WalletModel({
    required this.id,
    required this.name,
    required this.address,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  WalletModel copyWith({String? name}) {
    return WalletModel(
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

  factory WalletModel.fromJson(Map<String, dynamic> json) => WalletModel(
        id: json['id'],
        name: json['name'],
        address: json['address'],
        createdAt: DateTime.parse(json['createdAt']),
      );
}
