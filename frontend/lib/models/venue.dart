class Venue {
  final String id;
  final String name;
  final String address;
  final bool active;

  Venue({
    required this.id,
    required this.name,
    required this.address,
    this.active = true,
  });

  factory Venue.fromFirestore(Map<String, dynamic> data, String id) {
    return Venue(
      id: id,
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      active: data['active'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'address': address,
      'active': active,
    };
  }
}
