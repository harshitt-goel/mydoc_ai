import 'dart:convert';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show debugPrint; // Fixed import
import 'package:url_launcher/url_launcher.dart';

// Placeholder for profile data
class ProfileData {
  final int age;
  final String gender;
  final String activityLevel;
  final List<String> medicalConditions;

  ProfileData({
    required this.age,
    required this.gender,
    required this.activityLevel,
    required this.medicalConditions,
  });
}

class ProfileManager {
  static ProfileData? _profile;

  static void setProfile(ProfileData profile) {
    _profile = profile;
  }

  static ProfileData? getProfile() => _profile;
}

class HealthTipsPage extends StatefulWidget {
  const HealthTipsPage({super.key});

  @override
  State<HealthTipsPage> createState() => _HealthTipsPageState();
}

class _HealthTipsPageState extends State<HealthTipsPage> with SingleTickerProviderStateMixin {
  List<String> _tips = [];
  bool _isLoading = false;
  late AnimationController _controller;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic);
    _controller.forward();
    _loadTips();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadTips() async {
    setState(() => _isLoading = true);

    final profile = ProfileManager.getProfile();
    List<String> fetchedTips = [];

    // Simulated health API (replace with a real health-focused API if available)
    const String healthApiUrl = 'https://api.adviceslip.com/advice'; // Placeholder; use a health API if possible
    for (int i = 0; i < 5; i++) {
      try {
        final res = await http.get(Uri.parse(healthApiUrl));
        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          String baseTip = data['slip']['advice'];
          fetchedTips.add(_customizeHealthTip(baseTip, profile));
        } else {
          fetchedTips.add(_customizeHealthTip("Maintain a balanced diet and stay active.", profile));
        }
      } catch (e) {
        debugPrint("Tip fetch error: $e");
        fetchedTips.add(_customizeHealthTip("Stay active and consult a doctor if needed.", profile));
      }
    }

    setState(() {
      _tips = fetchedTips;
      _isLoading = false;
    });
  }

  String _customizeHealthTip(String baseTip, ProfileData? profile) {
    if (profile == null) {
      return "General health tip: $baseTip. Visit apple.com/health for more info.";
    }

    String customizedTip = baseTip;
    if (profile.age > 60) {
      customizedTip = "For seniors: $customizedTip. Try 10 minutes of light yoga daily.";
    } else if (profile.age < 30 && profile.activityLevel == "Active") {
      customizedTip = "For young actives: $customizedTip. Aim for 30 minutes of cardio.";
    } else if (profile.activityLevel == "Sedentary") {
      customizedTip = "For low activity: $customizedTip. Start with 15-minute walks.";
    }
    if (profile.medicalConditions.contains("Diabetes")) {
      customizedTip += " Monitor blood sugar and eat low-glycemic foods.";
    } else if (profile.medicalConditions.contains("Hypertension")) {
      customizedTip += " Reduce sodium and check blood pressure regularly.";
    } else if (profile.medicalConditions.isNotEmpty) {
      customizedTip += " Consult your doctor about your condition.";
    }

    return "$customizedTip Learn more at apple.com/health.";
  }

  Widget _buildHealthCard(String tip, int index) {
    final random = Random();
    final icons = [
      CupertinoIcons.heart_fill,
      CupertinoIcons.flame_fill,
      CupertinoIcons.drop_fill,
      CupertinoIcons.moon_fill,
      CupertinoIcons.person_fill,
    ];
    final icon = icons[random.nextInt(icons.length)];
    final categories = [
      "Heart Health",
      "Energy",
      "Hydration",
      "Rest",
      "Wellness"
    ];
    final category = categories[index % categories.length];

    return FadeTransition(
      opacity: _fadeAnim,
      child: GestureDetector(
        onTap: () {
          _showTipDetails(tip);
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: const Color(0xFF2A3B4A),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF3B4A5A), width: 0.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3B4A5A).withOpacity(0.3),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: const Color(0xFF4A90E2), size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Health Tip ${index + 1}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  tip,
                  style: const TextStyle(
                    color: Color(0xFFA3BFFA),
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B4A5A).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    category.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF4A90E2),
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.1,
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

  Future<void> _showTipDetails(String tip) async {
    await showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text(
          "Health Tip Details",
          style: TextStyle(color: Colors.white),
        ),
        message: Text(
          tip,
          style: const TextStyle(color: Color(0xFFA3BFFA)),
        ),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () async {
              const url = 'https://www.apple.com/healthcare/health-records/';
              if (await canLaunchUrl(Uri.parse(url))) {
                await launchUrl(Uri.parse(url));
              }
              Navigator.pop(context);
            },
            child: const Text("Learn More"),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text("Close"),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      theme: const CupertinoThemeData(
        brightness: Brightness.dark,
        primaryColor: Color(0xFF4A90E2),
      ),
      home: CupertinoPageScaffold(
        backgroundColor: const Color(0xFF1A252F),
        navigationBar: CupertinoNavigationBar(
          middle: const Text(
            "Health Tips",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          trailing: _isLoading
              ? const CupertinoActivityIndicator(radius: 12)
              : GestureDetector(
            onTap: () {
              _controller.forward(from: 0.0);
              _loadTips();
            },
            child: const Icon(
              CupertinoIcons.refresh,
              size: 28,
              color: Color(0xFF4A90E2),
            ),
          ),
          backgroundColor: const Color(0xFF1A252F).withOpacity(0.8),
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CupertinoActivityIndicator(radius: 12))
              : FadeTransition(
            opacity: _fadeAnim,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                CupertinoSliverRefreshControl(
                  onRefresh: () async {
                    _controller.forward(from: 0.0);
                    await _loadTips();
                  },
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) => _buildHealthCard(_tips[index], index),
                      childCount: _tips.length,
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