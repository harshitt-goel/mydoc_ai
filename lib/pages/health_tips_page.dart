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
      description: "Drink at least 8 glasses of water daily",
      icon: Icons.local_drink,
      category: "General",
    ),
    HealthTip(
      title: "Regular Exercise",
      description: "30 minutes of exercise most days",
      icon: Icons.directions_run,
      category: "Fitness",
    ),
    HealthTip(
      title: "Balanced Diet",
      description: "Eat fruits, vegetables and whole grains",
      icon: Icons.restaurant,
      category: "Nutrition",
    ),
    HealthTip(
      title: "Adequate Sleep",
      description: "Get 7-9 hours of quality sleep",
      icon: Icons.bedtime,
      category: "General",
    ),
    HealthTip(
      title: "Hand Hygiene",
      description: "Wash hands frequently with soap",
      icon: Icons.wash,
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Health Tips"),
      ),
      body: ListView.builder(
        itemCount: _healthTips.length,
        itemBuilder: (context, index) {
          final tip = _healthTips[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              leading: Icon(tip.icon),
              title: Text(tip.title),
              subtitle: Text(tip.description),
              trailing: IconButton(
                icon: Icon(
                  tip.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: tip.isFavorite ? Colors.red : null,
                ),
                onPressed: () => _toggleFavorite(index),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadRandomTips,
        child: const Icon(Icons.refresh),
        tooltip: 'Refresh Tips',
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


class HealthTipCard extends StatelessWidget {
  final HealthTip tip;
  final ValueChanged<bool> onFavoriteChanged;

  const HealthTipCard({
    super.key,
    required this.tip,
    required this.onFavoriteChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(tip.icon, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(
                      tip.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(
                    tip.isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: tip.isFavorite ? Colors.red : null,
                  ),
                  onPressed: () {
                    onFavoriteChanged(!tip.isFavorite);
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(tip.description),
            const SizedBox(height: 8),
            Chip(
              label: Text(tip.category),
              backgroundColor: Colors.blue.withOpacity(0.1),
            ),
          ],
        ),
      ),
    );
  }
}

class HealthTipSearch extends SearchDelegate<String> {
  final List<HealthTip> tips;

  HealthTipSearch(this.tips);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    final results = tips.where((tip) {
      return tip.title.toLowerCase().contains(query.toLowerCase()) ||
          tip.description.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final tip = results[index];
        return ListTile(
          leading: Icon(tip.icon),
          title: Text(tip.title),
          subtitle: Text(tip.description),
          onTap: () {
            close(context, tip.title);
          },
        );
      },
    );
  }
}