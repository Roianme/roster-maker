class ShiftBlock {
  final String startTime; // HH:mm format
  final String endTime;   // HH:mm format
  final String roleId;
  final int count;

  ShiftBlock({
    required this.startTime,
    required this.endTime,
    required this.roleId,
    required this.count,
  });

  factory ShiftBlock.fromJson(Map<String, dynamic> json) {
    return ShiftBlock(
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
      roleId: json['roleId'] ?? '',
      count: json['count'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startTime': startTime,
      'endTime': endTime,
      'roleId': roleId,
      'count': count,
    };
  }
}

class WeekdayTemplate {
  final String id;
  final String venueId;
  final int weekday; // 0 = Monday, 6 = Sunday
  final List<ShiftBlock> shiftBlocks;
  final String? supervisorRoleId;

  WeekdayTemplate({
    required this.id,
    required this.venueId,
    required this.weekday,
    required this.shiftBlocks,
    this.supervisorRoleId,
  });

  factory WeekdayTemplate.fromFirestore(Map<String, dynamic> data, String id) {
    return WeekdayTemplate(
      id: id,
      venueId: data['venueId'] ?? '',
      weekday: data['weekday'] ?? 0,
      shiftBlocks: (data['shiftBlocks'] as List<dynamic>?)
              ?.map((e) => ShiftBlock.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      supervisorRoleId: data['supervisorRoleId'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'venueId': venueId,
      'weekday': weekday,
      'shiftBlocks': shiftBlocks.map((e) => e.toJson()).toList(),
      'supervisorRoleId': supervisorRoleId,
    };
  }
}
