import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'firebase_options.dart';

const optimizerBaseUrl =
    String.fromEnvironment('OPTIMIZER_URL', defaultValue: 'http://localhost:8000');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const RosterMakerApp());
}

class RosterMakerApp extends StatelessWidget {
  const RosterMakerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Roster Maker',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final user = snapshot.data;
        if (user == null) {
          return const SignInScreen();
        }
        return Dashboard(user: user);
      },
    );
  }
}

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  String? error;

  Future<void> _signIn() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.text,
        password: password.text,
      );
    } on FirebaseAuthException catch (e) {
      setState(() => error = e.message);
    }
  }

  Future<void> _register() async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.text,
        password: password.text,
      );
    } on FirebaseAuthException catch (e) {
      setState(() => error = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: email,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: password,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(onPressed: _signIn, child: const Text('Sign in')),
                  TextButton(onPressed: _register, child: const Text('Register')),
                ],
              ),
              if (error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(error!, style: const TextStyle(color: Colors.red)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class Dashboard extends StatefulWidget {
  const Dashboard({super.key, required this.user});

  final User user;

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with TickerProviderStateMixin {
  late TabController tabController;
  final venues = <String>['Venue A', 'Venue B'];
  final roles = <String>['Grill', 'Fryer', 'Manager', 'Supervisor', 'Dessert'];
  final staff = <StaffMember>[
    StaffMember(id: 'alex', name: 'Alex Lee', roles: ['Grill', 'Fryer']),
    StaffMember(id: 'jamie', name: 'Jamie Kim', roles: ['Fryer']),
  ];
  final templates = <TemplateBlock>[];
  DateTime weekStart = _startOfWeek(DateTime.now());
  Map<String, String> assignments = {};
  List<SlotReason> reasons = [];
  List<ShiftSlotView> _cachedSlots = [];
  String _cachedSlotsKey = '';

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  List<ShiftSlotView> _getSlots() {
    final key = '${weekStart.toIso8601String()}-${templates.length}';
    if (_cachedSlotsKey != key) {
      _cachedSlots = _expandTemplates(templates, weekStart);
      _cachedSlotsKey = key;
    }
    return _cachedSlots;
  }

  Future<void> _generateRoster() async {
    final shiftSlots = _getSlots();
    final body = {
      'staff': staff.map((s) => s.toJson()).toList(),
      'shiftSlots': shiftSlots.map((s) => s.toJson()).toList(),
      'lockedAssignments': {},
      'lastApprovedAssignments': assignments,
    };
    final response = await http.post(
      Uri.parse('$optimizerBaseUrl/optimize'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    final success = response.statusCode >= 200 && response.statusCode < 300;
    if (success) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      setState(() {
        assignments = (data['assignments'] as Map<String, dynamic>)
            .map((k, v) => MapEntry(k, v.toString()));
        reasons = (data['reasons'] as List<dynamic>)
            .map((r) => SlotReason(r['slotId'] as String, r['reason'] as String))
            .toList();
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to generate roster. Check optimizer logs.'),
          ),
        );
      }
    }
  }

  void _exportCsv() {
    final shiftSlots = _getSlots();
    final staffLookup = {for (final s in staff) s.id: s.name};
    final buffer = StringBuffer();
    buffer.writeln(
        'VenueName,Date,Start,End,Role,EmployeeName,SlotId,Notes');
    for (final slot in shiftSlots) {
      final assignedId = assignments[slot.slotId] ?? '';
      final assignedName = staffLookup[assignedId] ?? '';
      buffer.writeln(
          '${slot.venueName},${slot.date},${slot.start},${slot.end},${slot.role},$assignedName,${slot.slotId},');
    }
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('CSV Preview'),
        content: SizedBox(
          width: 480,
          child: SingleChildScrollView(child: Text(buffer.toString())),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close'))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentSlots = _getSlots();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Roster Maker (Admin)'),
        actions: [
          IconButton(
            onPressed: () => FirebaseAuth.instance.signOut(),
            icon: const Icon(Icons.logout),
          )
        ],
        bottom: TabBar(
          controller: tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Venues'),
            Tab(text: 'Roles'),
            Tab(text: 'Staff'),
            Tab(text: 'Templates'),
            Tab(text: 'Roster'),
            Tab(text: 'Export'),
          ],
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          _VenuesTab(venues: venues, onAdd: (v) => setState(() => venues.add(v))),
          _RolesTab(roles: roles, onAdd: (r) => setState(() => roles.add(r))),
          _StaffTab(
            roles: roles,
            staff: staff,
            onAdd: (s) => setState(() => staff.add(s)),
          ),
          _TemplatesTab(
            venues: venues,
            roles: roles,
            blocks: templates,
            onAdd: (b) => setState(() => templates.add(b)),
          ),
          _RosterTab(
            slots: currentSlots,
            weekStart: weekStart,
            staff: staff,
            assignments: assignments,
            reasons: reasons,
            onWeekStartChanged: (d) => setState(() => weekStart = d),
            onGenerate: _generateRoster,
          ),
          _ExportTab(onExport: _exportCsv),
        ],
      ),
    );
  }
}

class StaffMember {
  StaffMember({required this.id, required this.name, required this.roles});

  final String id;
  final String name;
  final List<String> roles;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'roles': roles,
        'weekly': [],
        'exceptions': [],
      };

  static StaffMember empty() => StaffMember(id: '', name: '', roles: []);
}

class TemplateBlock {
  TemplateBlock({
    required this.venueName,
    required this.weekday,
    required this.start,
    required this.end,
    required this.role,
    required this.requiredCount,
  });

  final String venueName;
  final int weekday;
  final String start;
  final String end;
  final String role;
  final int requiredCount;
}

class ShiftSlotView {
  ShiftSlotView({
    required this.slotId,
    required this.venueName,
    required this.date,
    required this.start,
    required this.end,
    required this.role,
  });

  final String slotId;
  final String venueName;
  final String date;
  final String start;
  final String end;
  final String role;

  Map<String, dynamic> toJson() => {
        'slotId': slotId,
        'venueId': venueName,
        'weekday': _weekdayFromDate(date),
        'date': date,
        'start': start,
        'end': end,
        'role': role,
      };
}

class SlotReason {
  SlotReason(this.slotId, this.reason);
  final String slotId;
  final String reason;
}

class _VenuesTab extends StatefulWidget {
  const _VenuesTab({required this.venues, required this.onAdd});
  final List<String> venues;
  final ValueChanged<String> onAdd;

  @override
  State<_VenuesTab> createState() => _VenuesTabState();
}

class _VenuesTabState extends State<_VenuesTab> {
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Venues', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: const InputDecoration(labelText: 'Add venue'),
                ),
              ),
              ElevatedButton(
                  onPressed: () {
                    if (controller.text.isNotEmpty) {
                      widget.onAdd(controller.text);
                      controller.clear();
                    }
                  },
                  child: const Text('Add'))
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: widget.venues.length,
              itemBuilder: (_, i) => ListTile(title: Text(widget.venues[i])),
            ),
          ),
        ],
      ),
    );
  }
}

class _RolesTab extends StatefulWidget {
  const _RolesTab({required this.roles, required this.onAdd});
  final List<String> roles;
  final ValueChanged<String> onAdd;

  @override
  State<_RolesTab> createState() => _RolesTabState();
}

class _RolesTabState extends State<_RolesTab> {
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text('Roles', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: const InputDecoration(labelText: 'Add role'),
                ),
              ),
              ElevatedButton(
                  onPressed: () {
                    if (controller.text.isNotEmpty) {
                      widget.onAdd(controller.text);
                      controller.clear();
                    }
                  },
                  child: const Text('Add'))
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: widget.roles.length,
              itemBuilder: (_, i) => ListTile(title: Text(widget.roles[i])),
            ),
          ),
        ],
      ),
    );
  }
}

class _StaffTab extends StatefulWidget {
  const _StaffTab(
      {required this.roles, required this.staff, required this.onAdd, super.key});
  final List<String> roles;
  final List<StaffMember> staff;
  final ValueChanged<StaffMember> onAdd;

  @override
  State<_StaffTab> createState() => _StaffTabState();
}

class _StaffTabState extends State<_StaffTab> {
  final name = TextEditingController();
  final id = TextEditingController();
  final selectedRoles = <String>{};

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Staff', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          TextField(controller: id, decoration: const InputDecoration(labelText: 'External ID')),
          TextField(controller: name, decoration: const InputDecoration(labelText: 'Name')),
          Wrap(
            spacing: 8,
            children: widget.roles
                .map((r) => FilterChip(
                      label: Text(r),
                      selected: selectedRoles.contains(r),
                      onSelected: (v) => setState(() {
                        if (v) {
                          selectedRoles.add(r);
                        } else {
                          selectedRoles.remove(r);
                        }
                      }),
                    ))
                .toList(),
          ),
          ElevatedButton(
              onPressed: () {
                if (name.text.isEmpty || id.text.isEmpty) return;
                widget.onAdd(
                  StaffMember(id: id.text, name: name.text, roles: selectedRoles.toList()),
                );
                id.clear();
                name.clear();
                selectedRoles.clear();
              },
              child: const Text('Add staff')),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: widget.staff.length,
              itemBuilder: (_, i) {
                final s = widget.staff[i];
                return ListTile(
                  title: Text(s.name),
                  subtitle: Text('Roles: ${s.roles.join(", ")}'),
                  trailing: Text(s.id),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TemplatesTab extends StatefulWidget {
  const _TemplatesTab(
      {required this.venues,
      required this.roles,
      required this.blocks,
      required this.onAdd,
      super.key});
  final List<String> venues;
  final List<String> roles;
  final List<TemplateBlock> blocks;
  final ValueChanged<TemplateBlock> onAdd;

  @override
  State<_TemplatesTab> createState() => _TemplatesTabState();
}

class _TemplatesTabState extends State<_TemplatesTab> {
  String? venue;
  int weekday = 1;
  final start = TextEditingController(text: '09:00');
  final end = TextEditingController(text: '17:00');
  String? role;
  final requiredCount = TextEditingController(text: '1');

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Templates', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          DropdownButton<String>(
            value: venue,
            hint: const Text('Select venue'),
            items: widget.venues.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
            onChanged: (v) => setState(() => venue = v),
          ),
          DropdownButton<int>(
            value: weekday,
            items: List.generate(
                7, (i) => DropdownMenuItem(value: i + 1, child: Text('Day ${i + 1} (Mon=1)'))),
            onChanged: (v) => setState(() => weekday = v ?? 1),
          ),
          DropdownButton<String>(
            value: role,
            hint: const Text('Select role'),
            items: widget.roles.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
            onChanged: (v) => setState(() => role = v),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: start,
                  decoration: const InputDecoration(labelText: 'Start HH:MM'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: end,
                  decoration: const InputDecoration(labelText: 'End HH:MM'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: requiredCount,
                  decoration: const InputDecoration(labelText: 'Required Count'),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ElevatedButton(
              onPressed: () {
                if (venue == null || role == null) return;
                widget.onAdd(
                  TemplateBlock(
                    venueName: venue!,
                    weekday: weekday,
                    start: start.text,
                    end: end.text,
                    role: role!,
                    requiredCount: int.tryParse(requiredCount.text) ?? 1,
                  ),
                );
              },
              child: const Text('Add block')),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: widget.blocks.length,
              itemBuilder: (_, i) {
                final b = widget.blocks[i];
                return ListTile(
                  title: Text('${b.venueName} - Day ${b.weekday} - ${b.role}'),
                  subtitle: Text('${b.start}-${b.end} x${b.requiredCount}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _RosterTab extends StatelessWidget {
  const _RosterTab({
    required this.slots,
    required this.weekStart,
    required this.staff,
    required this.assignments,
    required this.reasons,
    required this.onWeekStartChanged,
    required this.onGenerate,
  });

  final List<ShiftSlotView> slots;
  final DateTime weekStart;
  final List<StaffMember> staff;
  final Map<String, String> assignments;
  final List<SlotReason> reasons;
  final ValueChanged<DateTime> onWeekStartChanged;
  final VoidCallback onGenerate;

  @override
  Widget build(BuildContext context) {
    final reasonMap = {for (final r in reasons) r.slotId: r.reason};
    final staffNameMap = {for (final s in staff) s.id: s.name};
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Week of ${DateFormat('yyyy-MM-dd').format(weekStart)}'),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: weekStart,
                    firstDate: DateTime(2024, 1, 1),
                    lastDate: DateTime(2030, 1, 1),
                  );
                  if (picked != null) {
                    onWeekStartChanged(_startOfWeek(picked));
                  }
                },
                child: const Text('Change week'),
              ),
              const SizedBox(width: 12),
              ElevatedButton(onPressed: onGenerate, child: const Text('Generate roster')),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: slots.length,
              itemBuilder: (_, i) {
                final slot = slots[i];
                final assignedId = assignments[slot.slotId] ?? '';
                final assignedName = staffNameMap[assignedId] ?? '';
                final reason = reasonMap[slot.slotId] ?? '';
                return Card(
                  child: ListTile(
                    title: Text('${slot.venueName} ${slot.date} ${slot.start}-${slot.end}'),
                    subtitle: Text('${slot.role} • ${assignedName.isEmpty ? 'Unassigned' : assignedName}\n$reason'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ExportTab extends StatelessWidget {
  const _ExportTab({required this.onExport});
  final VoidCallback onExport;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        icon: const Icon(Icons.file_download),
        onPressed: onExport,
        label: const Text('Export CSV'),
      ),
    );
  }
}

List<ShiftSlotView> _expandTemplates(List<TemplateBlock> blocks, DateTime weekStart) {
  final formatter = DateFormat('yyyy-MM-dd');
  final slots = <ShiftSlotView>[];
  for (final block in blocks) {
    for (int i = 0; i < block.requiredCount; i++) {
      final date = weekStart.add(Duration(days: block.weekday - 1));
      final slotId =
          '${block.venueName}-${block.weekday}-${block.start}-${block.end}-${block.role}-$i';
      slots.add(
        ShiftSlotView(
          slotId: slotId,
          venueName: block.venueName,
          date: formatter.format(date),
          start: block.start,
          end: block.end,
          role: block.role,
        ),
      );
    }
  }
  return slots;
}

int _weekdayFromDate(String dateStr) {
  final parsed = DateTime.parse(dateStr);
  // In Dart, Monday = 1
  return parsed.weekday;
}

DateTime _startOfWeek(DateTime dt) {
  final weekday = dt.weekday;
  return DateTime(dt.year, dt.month, dt.day).subtract(Duration(days: weekday - 1));
}

// Minimal Firestore placeholder for future persistence.
FirebaseFirestore get firestore => FirebaseFirestore.instance;
