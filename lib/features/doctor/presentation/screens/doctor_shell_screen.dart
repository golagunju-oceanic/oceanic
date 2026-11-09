import 'package:flutter/material.dart';

import 'doctor_appointments_screen.dart';
import 'doctor_dashboard_screen.dart';
import 'doctor_patients_screen.dart';
import 'doctor_profile_screen.dart';

/// Put this screen behind your existing authenticated / doctor-only app route.
/// Authentication/role redirection remains your app's responsibility.
class DoctorShellScreen extends StatefulWidget {
  const DoctorShellScreen({super.key});
  @override
  State<DoctorShellScreen> createState() => _DoctorShellScreenState();
}

class _DoctorShellScreenState extends State<DoctorShellScreen> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      DoctorDashboardScreen(
        onOpenTab: (index) => setState(() => _selected = index),
      ),
      const DoctorAppointmentsScreen(),
      const DoctorPatientsScreen(),
      const DoctorProfileScreen(),
    ];
    return Scaffold(
      body: pages[_selected],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selected,
        onDestinationSelected: (index) => setState(() => _selected = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home),
            selectedIcon: Icon(Icons.home_filled, color: Colors.white),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_note_outlined),
            selectedIcon: Icon(Icons.event_note, color: Colors.white),
            label: 'Visits',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people, color: Colors.white),
            label: 'Patients',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: Colors.white),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
