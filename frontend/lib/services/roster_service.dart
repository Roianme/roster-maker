import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/roster_shift.dart';

class RosterService {
  final String baseUrl;

  RosterService({this.baseUrl = 'http://localhost:8000'});

  Future<Map<String, dynamic>> generateRoster({
    required String venueId,
    required DateTime weekStart,
    List<String>? lockedShiftIds,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/roster/generate'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'venueId': venueId,
        'weekStart': weekStart.toIso8601String(),
        'lockedShiftIds': lockedShiftIds ?? [],
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {
        'shifts': (data['shifts'] as List)
            .map((s) => RosterShift.fromJson(s))
            .toList(),
        'warnings': data['warnings'] ?? [],
        'reasons': data['reasons'] ?? {},
      };
    } else {
      throw Exception('Failed to generate roster: ${response.body}');
    }
  }

  String generateCsv(List<RosterShift> shifts) {
    final buffer = StringBuffer();
    
    // Header
    buffer.writeln('SlotId,Venue,Date,StartTime,EndTime,Role,Employee');
    
    // Rows
    for (final shift in shifts) {
      buffer.writeln(shift.toCsvRow().join(','));
    }
    
    return buffer.toString();
  }
}
