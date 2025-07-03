import 'package:flutter/material.dart';
import 'pages/health_tips_page.dart';
import 'pages/profile_page.dart';
import 'pages/doctor_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Doctor',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MainLayout(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 1; // Start with doctor page as default

  // Pages for bottom navigation
  final List<Widget> _pages = const [
    ProfilePage(),
    DoctorPage(),
    HealthTipsPage(), // Additional useful page
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services),
            label: 'AI Doctor',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.health_and_safety),
            label: 'Health Tips',
          ),
        ],
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              child: Icon(Icons.person, size: 50),
            ),
            const SizedBox(height: 20),
            const Text(
              'User Name',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text('user@example.com'),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // Add profile editing functionality
              },
              child: const Text('Edit Profile'),
            ),
          ],
        ),
      ),
    );
  }
}

class DoctorPage extends StatelessWidget {
  const DoctorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Doctor'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Icon(Icons.medical_services, size: 64, color: Colors.blue),
                    const SizedBox(height: 16),
                    const Text(
                      'How are you feeling today?',
                      style: TextStyle(fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to symptom input page
                      },
                      child: const Text('Check Symptoms'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Recent Consultations', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: 3, // Placeholder for recent consultations
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: const Icon(Icons.medical_services),
                    title: Text('Consultation ${index + 1}'),
                    subtitle: Text('2023-06-${15 - index}'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // View consultation details
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HealthTipsPage extends StatelessWidget {
  const HealthTipsPage({super.key});

  final List<String> tips = const [
    'Drink at least 8 glasses of water daily',
    'Get 7-8 hours of sleep each night',
    'Exercise for 30 minutes most days',
    'Eat a balanced diet with fruits and vegetables',
    'Wash your hands frequently',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Tips'),
        automaticallyImplyLeading: false,
      ),
      body: ListView.builder(
        itemCount: tips.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: const Icon(Icons.favorite, color: Colors.red),
              title: Text(tips[index]),
            ),
          );
        },
      ),
    );
  }
}