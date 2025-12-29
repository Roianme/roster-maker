class Role {
  final String id;
  final String name;
  final String? description;
  final bool active;

  Role({
    required this.id,
    required this.name,
    this.description,
    this.active = true,
  });

  factory Role.fromFirestore(Map<String, dynamic> data, String id) {
    return Role(
      id: id,
      name: data['name'] ?? '',
      description: data['description'],
      active: data['active'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'active': active,
    };
  }
}
