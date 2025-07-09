import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class HealthTipsPage extends StatefulWidget {
  const HealthTipsPage({super.key});

  @override
  State<HealthTipsPage> createState() => _HealthTipsPageState();
}

class _HealthTipsPageState extends State<HealthTipsPage> {
  List<HealthTip> _healthTips = [];

  final List<HealthTip> _allPossibleTips = [
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
    _loadRandomTips();
  }

  void _loadRandomTips() {
    final random = Random();
    setState(() {
      _healthTips = List.from(_allPossibleTips)..shuffle(random);
    });
  }

  void _toggleFavorite(int index) {
    setState(() {
      _healthTips[index] = _healthTips[index].copyWith(
        isFavorite: !_healthTips[index].isFavorite,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: CupertinoNavigationBar(
        middle: const Text("Health Tips"),
        trailing: GestureDetector(
          onTap: _loadRandomTips,
          child: const Icon(CupertinoIcons.refresh),
        ),
      ),
      child: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: _healthTips.length,
          itemBuilder: (context, index) {
            final tip = _healthTips[index];
            return _buildAppleCard(tip, () => _toggleFavorite(index));
          },
        ),
      ),
    );
  }

  Widget _buildAppleCard(HealthTip tip, VoidCallback onToggle) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(tip.icon, color: CupertinoColors.systemBlue, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        tip.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: onToggle,
                      child: Icon(
                        tip.isFavorite
                            ? CupertinoIcons.heart_fill
                            : CupertinoIcons.heart,
                        color: tip.isFavorite
                            ? CupertinoColors.systemRed
                            : CupertinoColors.inactiveGray,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  tip.description,
                  style: TextStyle(
                    color: CupertinoColors.systemGrey,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey5,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    tip.category,
                    style: const TextStyle(
                      fontSize: 13,
                      color: CupertinoColors.systemBlue,
                    ),
                  ),
                ),
              ],
            ),
          ),
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
