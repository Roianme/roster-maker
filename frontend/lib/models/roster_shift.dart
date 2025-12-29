class RosterShift {
  final String slotId;
  final String venueId;
  final String venueName;
  final DateTime date;
  final String startTime;
  final String endTime;
  final String roleId;
  final String roleName;
  final String? employeeId;
  final String? employeeName;
  final bool locked;

  RosterShift({
    required this.slotId,
    required this.venueId,
    required this.venueName,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.roleId,
    required this.roleName,
    this.employeeId,
    this.employeeName,
    this.locked = false,
  });

  factory RosterShift.fromJson(Map<String, dynamic> json) {
    return RosterShift(
      slotId: json['slotId'] ?? '',
      venueId: json['venueId'] ?? '',
      venueName: json['venueName'] ?? '',
      date: DateTime.parse(json['date']),
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
      roleId: json['roleId'] ?? '',
      roleName: json['roleName'] ?? '',
      employeeId: json['employeeId'],
      employeeName: json['employeeName'],
      locked: json['locked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'slotId': slotId,
      'venueId': venueId,
      'venueName': venueName,
      'date': date.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      'roleId': roleId,
      'roleName': roleName,
      'employeeId': employeeId,
      'employeeName': employeeName,
      'locked': locked,
    };
  }

  List<String> toCsvRow() {
    return [
      slotId,
      venueName,
      date.toIso8601String().split('T')[0],
      startTime,
      endTime,
      roleName,
      employeeName ?? '',
    ];
  }
}
