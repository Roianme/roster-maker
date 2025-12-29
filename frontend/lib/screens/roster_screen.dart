import 'package:flutter/material.dart';
import 'package:file_saver/file_saver.dart';
import 'dart:convert';
import '../models/roster_shift.dart';
import '../services/roster_service.dart';

class RosterScreen extends StatefulWidget {
  const RosterScreen({super.key});

  @override
  State<RosterScreen> createState() => _RosterScreenState();
}

class _RosterScreenState extends State<RosterScreen> {
  final _rosterService = RosterService();
  List<RosterShift>? _shifts;
  bool _isGenerating = false;
  String? _errorMessage;

  Future<void> _generateRoster() async {
    setState(() {
      _isGenerating = true;
      _errorMessage = null;
    });

    try {
      // For POC, use hardcoded values - in production, select from UI
      final result = await _rosterService.generateRoster(
        venueId: 'venue1',
        weekStart: DateTime.now(),
      );
      setState(() {
        _shifts = result['shifts'] as List<RosterShift>;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  Future<void> _exportCsv() async {
    if (_shifts == null || _shifts!.isEmpty) return;

    final csv = _rosterService.generateCsv(_shifts!);
    final bytes = utf8.encode(csv);

    await FileSaver.instance.saveFile(
      name: 'roster_${DateTime.now().toIso8601String()}.csv',
      bytes: bytes,
      ext: 'csv',
      mimeType: MimeType.csv,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _isGenerating ? null : _generateRoster,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Generate Roster'),
                ),
                const SizedBox(width: 16),
                if (_shifts != null && _shifts!.isNotEmpty)
                  ElevatedButton.icon(
                    onPressed: _exportCsv,
                    icon: const Icon(Icons.download),
                    label: const Text('Export CSV'),
                  ),
              ],
            ),
          ),
          if (_isGenerating)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_errorMessage != null)
            Expanded(
              child: Center(
                child: Text(
                  'Error: $_errorMessage',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            )
          else if (_shifts != null)
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Slot ID')),
                      DataColumn(label: Text('Venue')),
                      DataColumn(label: Text('Date')),
                      DataColumn(label: Text('Start')),
                      DataColumn(label: Text('End')),
                      DataColumn(label: Text('Role')),
                      DataColumn(label: Text('Employee')),
                    ],
                    rows: _shifts!
                        .map(
                          (shift) => DataRow(
                            cells: [
                              DataCell(Text(shift.slotId)),
                              DataCell(Text(shift.venueName)),
                              DataCell(Text(shift.date.toIso8601String().split('T')[0])),
                              DataCell(Text(shift.startTime)),
                              DataCell(Text(shift.endTime)),
                              DataCell(Text(shift.roleName)),
                              DataCell(Text(shift.employeeName ?? 'Unassigned')),
                            ],
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            )
          else
            const Expanded(
              child: Center(
                child: Text('Click "Generate Roster" to create a new roster'),
              ),
            ),
        ],
      ),
    );
  }
}
