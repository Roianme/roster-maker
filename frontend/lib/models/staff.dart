class Staff {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final List<String> roleIds;
  final bool active;

  Staff({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.roleIds,
    this.active = true,
  });

  String get fullName => '$firstName $lastName';

  factory Staff.fromFirestore(Map<String, dynamic> data, String id) {
    return Staff(
      id: id,
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      email: data['email'] ?? '',
      roleIds: List<String>.from(data['roleIds'] ?? []),
      active: data['active'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'roleIds': roleIds,
      'active': active,
    };
  }
}
