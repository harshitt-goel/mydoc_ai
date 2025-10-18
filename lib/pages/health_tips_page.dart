import 'dart:math';
import 'package:flutter/material.dart';
import 'package:ai_doctor/models/profile_data.dart';
import 'package:ai_doctor/models/profile_manager.dart';

class HealthTipsPage extends StatefulWidget {
  const HealthTipsPage({super.key});

  @override
  State<HealthTipsPage> createState() => _HealthTipsPageState();
}

class _HealthTipsPageState extends State<HealthTipsPage>
    with SingleTickerProviderStateMixin {
  final List<HealthTip> _commonTips = [];
  List<String> _personalizedTips = [];
  bool _isLoading = false;
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );
    _scaleAnim = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );
    _loadTips();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadTips() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600));
    setState(() {
      _commonTips.clear();
      _commonTips.addAll(_generateCommonTips());
      _generatePersonalizedTips();
      _isLoading = false;
    });
    _controller.forward();
  }

  void _generatePersonalizedTips() {
    final profile = ProfileManager.getProfile();
    if (profile == null) return;

    final List<String> tips = [];
    double bmi = 0;
    if (profile.heightCm != null && profile.weightKg != null && profile.heightCm! > 0) {
      final h = profile.heightCm! / 100.0;
      bmi = profile.weightKg! / (h * h);
    }

    if (profile.age > 60) {
      tips.add("As a senior, engage in light stretching and walking to maintain mobility.");
    } else if (profile.age < 18) {
      tips.add("As a young individual, focus on building strong habits around sleep, food, and exercise.");
    }

    if (profile.activityLevel.toLowerCase() == 'sedentary') {
      tips.add("Add 30 mins of walking to your day to boost metabolism and mental clarity.");
    } else if (profile.activityLevel.toLowerCase() == 'active') {
      tips.add("Maintain hydration and proper recovery to support your active lifestyle.");
    }

    for (final condition in profile.medicalConditions) {
      if (condition.toLowerCase().contains("diabetes")) {
        tips.add("Monitor blood sugar levels and avoid refined sugars.");
      }
      if (condition.toLowerCase().contains("hypertension")) {
        tips.add("Limit sodium intake and check your blood pressure weekly.");
      }
      if (condition.toLowerCase().contains("asthma")) {
        tips.add("Avoid dusty environments and practice breathing exercises.");
      }
    }

    if (bmi > 0) {
      if (bmi >= 25) {
        tips.add("Your BMI suggests you might benefit from more physical activity and a balanced diet.");
      } else if (bmi < 18.5) {
        tips.add("Include more nutrient-rich foods to reach a healthy weight.");
      } else {
        tips.add("Your BMI is in a healthy range — great job maintaining it!");
      }
    }

    if (tips.isEmpty) {
      tips.add("Stay hydrated, eat balanced meals, and move daily for long-term wellness.");
    }

    _personalizedTips = tips;
  }

  List<HealthTip> _generateCommonTips() {
    final random = Random();
    final categories = ['Mindfulness', 'Nutrition', 'Activity', 'Recovery', 'Prevention'];

    return List.generate(5, (index) {
      final category = categories[index % categories.length];
      final icon = _getCategoryIcon(category);
      final color = _getCategoryColor(category);
      return HealthTip(
        title: _generateTitle(category),
        content: _generateContent(category),
        category: category,
        icon: icon,
        color: color,
      );
    });
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Mindfulness': return Icons.self_improvement;
      case 'Nutrition': return Icons.restaurant;
      case 'Activity': return Icons.directions_run;
      case 'Recovery': return Icons.night_shelter;
      case 'Prevention': return Icons.medical_services;
      default: return Icons.health_and_safety;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Mindfulness': return const Color(0xFF7FD1B9);
      case 'Nutrition': return const Color(0xFFF7A76C);
      case 'Activity': return const Color(0xFF4A90E2);
      case 'Recovery': return const Color(0xFF9B59B6);
      case 'Prevention': return const Color(0xFFE74C3C);
      default: return const Color(0xFF4A90E2);
    }
  }

  String _generateTitle(String category) {
    switch (category) {
      case 'Mindfulness': return "Mindful Breathing";
      case 'Nutrition': return "Balanced Nutrition";
      case 'Activity': return "Daily Movement";
      case 'Recovery': return "Quality Sleep";
      case 'Prevention': return "Health Screening";
      default: return "Wellness Tip";
    }
  }

  String _generateContent(String category) {
    switch (category) {
      case 'Mindfulness': return "Practice 5 minutes of deep breathing daily to reduce stress and improve focus.";
      case 'Nutrition': return "Include colorful vegetables in every meal for diverse nutrients.";
      case 'Activity': return "Take a 10-minute walk after meals for better digestion and metabolism.";
      case 'Recovery': return "Stick to a sleep schedule and aim for 7–9 hours of quality rest.";
      case 'Prevention': return "Get annual health checkups. Prevention is better than cure.";
      default: return "Consistency in small daily actions leads to big health wins.";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0A1E3A),
        cardColor: const Color(0xFF1A3152),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Health Insights"),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Color(0xFF4A90E2)),
              onPressed: () {
                _controller.reset();
                _loadTips();
              },
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF4A90E2)))
            : ScaleTransition(
          scale: _scaleAnim,
          child: FadeTransition(
            opacity: _fadeAnim,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(20),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      if (_personalizedTips.isNotEmpty)
                        ..._personalizedTips.map((tip) => _buildPersonalTipCard(tip)).toList(),
                      const SizedBox(height: 20),
                      const Text("General Health Tips",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
                    ]),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) => _buildHealthCard(_commonTips[index]),
                      childCount: _commonTips.length,
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

  Widget _buildPersonalTipCard(String tip) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A3152),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF3B4A5A), width: 0.6),
      ),
      child: Text(tip, style: const TextStyle(color: Colors.white, fontSize: 16)),
    );
  }

  Widget _buildHealthCard(HealthTip tip) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: const Color(0xFF1A3152),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: tip.color.withOpacity(0.2), shape: BoxShape.circle),
                  child: Icon(tip.icon, color: tip.color, size: 24),
                ),
                const SizedBox(width: 12),
                Text(tip.category, style: TextStyle(fontSize: 14, color: tip.color, fontWeight: FontWeight.w500)),
              ],
            ),
            const SizedBox(height: 16),
            Text(tip.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white)),
            const SizedBox(height: 12),
            Text(tip.content, style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.8), height: 1.5)),
          ],
        ),
      ),
    );
  }
}

class HealthTip {
  final String title;
  final String content;
  final String category;
  final IconData icon;
  final Color color;

  HealthTip({required this.title, required this.content, required this.category, required this.icon, required this.color});
}