import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'venues_screen.dart';
import 'roles_screen.dart';
import 'staff_screen.dart';
import 'templates_screen.dart';
import 'roster_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final _authService = AuthService();

  static const List<Widget> _screens = [
    VenuesScreen(),
    RolesScreen(),
    StaffScreen(),
    TemplatesScreen(),
    RosterScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Roster Maker - Admin Portal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authService.signOut();
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.business),
                label: Text('Venues'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.work),
                label: Text('Roles'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people),
                label: Text('Staff'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.calendar_month),
                label: Text('Templates'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.schedule),
                label: Text('Roster'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: _screens[_selectedIndex],
          ),
        ],
      ),
    );
  }
}
