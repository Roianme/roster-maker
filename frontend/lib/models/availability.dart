class Availability {
  final String id;
  final String staffId;
  final int weekday; // 0 = Monday, 6 = Sunday
  final bool available;
  final String? notes;

  Availability({
    required this.id,
    required this.staffId,
    required this.weekday,
    this.available = true,
    this.notes,
  });

  factory Availability.fromFirestore(Map<String, dynamic> data, String id) {
    return Availability(
      id: id,
      staffId: data['staffId'] ?? '',
      weekday: data['weekday'] ?? 0,
      available: data['available'] ?? true,
      notes: data['notes'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'staffId': staffId,
      'weekday': weekday,
      'available': available,
      'notes': notes,
    };
  }
}
