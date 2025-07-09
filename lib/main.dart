import 'package:flutter/cupertino.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      debugShowCheckedModeBanner: false,
      home: MainLayout(),
    );
  }
}

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 1;

  final List<Widget> _pages = [
    const ProfilePage(),
    const DoctorPage(),
    const HealthTipsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.bandage_fill),
            label: 'AI Doctor',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.heart),
            label: 'Health Tips',
          ),
        ],
        activeColor: CupertinoColors.activeBlue,
        inactiveColor: CupertinoColors.systemGrey,
      ),
      tabBuilder: (context, index) {
        return CupertinoTabView(
          builder: (context) => _pages[index],
        );
      },
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('My Profile'),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: CupertinoColors.systemGrey4,
              ),
              child: const Icon(
                CupertinoIcons.person,
                size: 50,
                color: CupertinoColors.white,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'User Name',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            const Text('user@example.com'),
            const SizedBox(height: 30),
            CupertinoButton.filled(
              child: const Text('Edit Profile'),
              onPressed: () {},
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
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('AI Doctor'),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const Icon(CupertinoIcons.heart_circle,
                        size: 64, color: CupertinoColors.systemBlue),
                    const SizedBox(height: 16),
                    const Text(
                      'How are you feeling today?',
                      style:
                      TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    CupertinoButton.filled(
                      child: const Text('Check Symptoms'),
                      onPressed: () {
                        // TODO: Navigate to symptom checker
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Recent Consultations',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: 3,
                  itemBuilder: (context, index) {
                    return CupertinoListTile(
                      leading: const Icon(CupertinoIcons.doc_text),
                      title: Text('Consultation ${index + 1}'),
                      subtitle: Text('2023-06-${15 - index}'),
                      trailing: const Icon(CupertinoIcons.chevron_forward),
                      onTap: () {},
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Cupertino-style ListTile replacement
class CupertinoListTile extends StatelessWidget {
  final Widget leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const CupertinoListTile({
    super.key,
    required this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
        const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: CupertinoColors.separator),
          ),
        ),
        child: Row(
          children: [
            leading,
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  title,
                  if (subtitle != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: DefaultTextStyle(
                        style: TextStyle(
                          fontSize: 13,
                          color: CupertinoColors.systemGrey,
                        ),
                        child: subtitle!,
                      ),
                    ),
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

class HealthTip {
  final String title;
  final String description;
  final IconData icon;
  final String category;
  final bool isFavorite;

  HealthTip({
    required this.title,
    required this.description,
    required this.icon,
    required this.category,
    this.isFavorite = false,
  });

  HealthTip copyWith({
    String? title,
    String? description,
    IconData? icon,
    String? category,
    bool? isFavorite,
  }) {
    return HealthTip(
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      category: category ?? this.category,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

class HealthTipsPage extends StatefulWidget {
  const HealthTipsPage({super.key});

  @override
  State<HealthTipsPage> createState() => _HealthTipsPageState();
}

class _HealthTipsPageState extends State<HealthTipsPage> {
  List<HealthTip> _tips = [];

  final List<HealthTip> _allTips = [
    HealthTip(
      title: "Stay Hydrated",
      description: "Drink at least 8 glasses of water daily.",
      icon: CupertinoIcons.drop,
      category: "General",
    ),
    HealthTip(
      title: "Regular Exercise",
      description: "30 minutes of exercise most days.",
      icon: CupertinoIcons.heart_fill,
      category: "Fitness",
    ),
    HealthTip(
      title: "Balanced Diet",
      description: "Eat fruits, vegetables and whole grains.",
      icon: CupertinoIcons.leaf_arrow_circlepath,
      category: "Nutrition",
    ),
    HealthTip(
      title: "Adequate Sleep",
      description: "Get 7–9 hours of quality sleep.",
      icon: CupertinoIcons.bed_double,
      category: "Rest",
    ),
    HealthTip(
      title: "Hand Hygiene",
      description: "Wash hands frequently with soap.",
      icon: CupertinoIcons.hand_raised_fill,
      category: "Prevention",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _shuffleTips();
  }

  void _shuffleTips() {
    setState(() {
      _tips = List.from(_allTips)..shuffle(Random());
    });
  }

  void _toggleFavorite(int index) {
    setState(() {
      _tips[index] = _tips[index].copyWith(
        isFavorite: !_tips[index].isFavorite,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text("Health Tips"),
        trailing: GestureDetector(
          child: const Icon(CupertinoIcons.refresh),
          onTap: _shuffleTips,
        ),
      ),
      child: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _tips.length,
          itemBuilder: (context, index) {
            final tip = _tips[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: CupertinoColors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: CupertinoColors.black.withOpacity(0.08),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(tip.icon, color: CupertinoColors.systemBlue),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          tip.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _toggleFavorite(index),
                        child: Icon(
                          tip.isFavorite
                              ? CupertinoIcons.heart_fill
                              : CupertinoIcons.heart,
                          color: tip.isFavorite
                              ? CupertinoColors.systemRed
                              : CupertinoColors.inactiveGray,
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    tip.description,
                    style: const TextStyle(
                      color: CupertinoColors.systemGrey,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 4, horizontal: 8),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey5,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      tip.category,
                      style: const TextStyle(
                        color: CupertinoColors.systemBlue,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
