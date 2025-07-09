import 'package:flutter/cupertino.dart';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

class HealthTipsPage extends StatefulWidget {
  const HealthTipsPage({super.key});

  @override
  State<HealthTipsPage> createState() => _HealthTipsPageState();
}

class _HealthTipsPageState extends State<HealthTipsPage>
    with SingleTickerProviderStateMixin {
  List<String> _tips = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadTips();
  }

  Future<void> _loadTips() async {
    setState(() => _isLoading = true);

    final url = Uri.parse('https://api.adviceslip.com/advice');
    List<String> fetchedTips = [];

    for (int i = 0; i < 5; i++) {
      try {
        final res = await http.get(url);
        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          fetchedTips.add(data['slip']['advice']);
        } else {
          fetchedTips.add("Keep a calm mind and stay hydrated.");
        }
      } catch (e) {
        fetchedTips.add("Stay positive and keep moving!");
      }
    }

    setState(() {
      _tips = fetchedTips;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      theme: const CupertinoThemeData(brightness: Brightness.dark),
      home: CupertinoPageScaffold(
        backgroundColor: CupertinoColors.black,
        navigationBar: CupertinoNavigationBar(
          middle: const Text("Health Tips"),
          trailing: _isLoading
              ? const CupertinoActivityIndicator()
              : GestureDetector(
            onTap: _loadTips,
            child: const Icon(CupertinoIcons.refresh),
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CupertinoActivityIndicator())
              : CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              CupertinoSliverRefreshControl(
                onRefresh: _loadTips,
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) =>
                        _buildAppleCard(_tips[index], index),
                    childCount: _tips.length,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppleCard(String tip, int index) {
    final random = Random();
    final icons = [
      CupertinoIcons.heart,
      CupertinoIcons.bolt_fill,
      CupertinoIcons.drop,
      CupertinoIcons.bed_double_fill,
      CupertinoIcons.hand_raised_fill,
    ];
    final icon = icons[random.nextInt(icons.length)];
    final categories = [
      "Mind",
      "Body",
      "Hydration",
      "Sleep",
      "Hygiene"
    ];
    final category = categories[index % categories.length];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: CupertinoColors.darkBackgroundGray.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withOpacity(0.3),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: CupertinoButton(
        padding: const EdgeInsets.all(16),
        onPressed: () {},
        borderRadius: BorderRadius.circular(20),
        color: CupertinoColors.darkBackgroundGray.withOpacity(0.001),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: CupertinoColors.activeBlue, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Tip ${index + 1}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              tip,
              style: const TextStyle(
                color: CupertinoColors.systemGrey2,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey5.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                category.toUpperCase(),
                style: const TextStyle(
                  fontSize: 13,
                  color: CupertinoColors.activeBlue,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
