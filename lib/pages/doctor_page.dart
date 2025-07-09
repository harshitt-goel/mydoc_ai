import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'ai_service.dart';

class DoctorPage extends StatefulWidget {
  const DoctorPage({super.key});

  @override
  State<DoctorPage> createState() => _DoctorPageState();
}

class _DoctorPageState extends State<DoctorPage>
    with SingleTickerProviderStateMixin {
  final List<String> _selectedSymptoms = [];
  final TextEditingController _symptomController = TextEditingController();
  final List<String> _allSymptoms = [
    'Headache',
    'Fever',
    'Cough',
    'Fatigue',
    'Nausea',
    'Dizziness',
    'Sore throat',
    'Shortness of breath',
    'Chest pain',
    'Muscle aches'
  ];

  List<String> _filteredSymptoms = [];
  bool _isAnalyzing = false;
  String _diagnosisResult = '';
  String _recommendedTreatment = '';

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _filteredSymptoms = _allSymptoms;
    _symptomController.addListener(_filterSymptoms);
    _animController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeInOut);
  }

  void _filterSymptoms() {
    setState(() {
      _filteredSymptoms = _allSymptoms
          .where((s) => s.toLowerCase().contains(_symptomController.text.toLowerCase()))
          .toList();
    });
  }

  void _addSymptom(String symptom) {
    if (!_selectedSymptoms.contains(symptom)) {
      setState(() {
        _selectedSymptoms.add(symptom);
        _symptomController.clear();
        _filteredSymptoms = _allSymptoms;
      });
    }
  }

  void _removeSymptom(String symptom) {
    setState(() => _selectedSymptoms.remove(symptom));
  }

  void _clearAll() {
    setState(() {
      _selectedSymptoms.clear();
      _symptomController.clear();
      _filteredSymptoms = _allSymptoms;
      _diagnosisResult = '';
      _recommendedTreatment = '';
    });
  }

  Future<void> _analyzeSymptoms() async {
    if (_selectedSymptoms.isEmpty) return;

    setState(() {
      _isAnalyzing = true;
      _diagnosisResult = '';
      _recommendedTreatment = '';
    });

    try {
      final result = await AIService.analyzeSymptoms(_selectedSymptoms);
      setState(() {
        _diagnosisResult = "AI Diagnosis";
        _recommendedTreatment = result;
      });
      _animController.forward(from: 0);
    } catch (e) {
      setState(() {
        _diagnosisResult = "Error";
        _recommendedTreatment = e.toString();
      });
    } finally {
      setState(() => _isAnalyzing = false);
    }
  }

  Widget _buildChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: CupertinoColors.darkBackgroundGray,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: CupertinoColors.systemGrey),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(text,
              style: const TextStyle(color: CupertinoColors.white, fontSize: 14)),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () => _removeSymptom(text),
            child: const Icon(CupertinoIcons.clear_circled_solid,
                size: 18, color: CupertinoColors.systemGrey),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _symptomController.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      theme: const CupertinoThemeData(brightness: Brightness.dark),
      home: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: const Text("AI Doctor"),
          trailing: _selectedSymptoms.isNotEmpty
              ? GestureDetector(
            onTap: _clearAll,
            child: const Icon(CupertinoIcons.clear_circled),
          )
              : null,
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const Icon(CupertinoIcons.heart_circle_fill,
                        color: CupertinoColors.systemRed, size: 64),
                    const SizedBox(height: 12),
                    const Text(
                      "Describe your symptoms",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    CupertinoTextField(
                      controller: _symptomController,
                      placeholder: 'Search symptoms...',
                      prefix: const Icon(CupertinoIcons.search),
                      padding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                      style: const TextStyle(color: CupertinoColors.white),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemGrey5,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_selectedSymptoms.isNotEmpty)
                      Wrap(
                        children: _selectedSymptoms.map(_buildChip).toList(),
                      ),
                    if (_symptomController.text.isNotEmpty)
                      ..._filteredSymptoms.map((symptom) => CupertinoButton(
                        padding: const EdgeInsets.symmetric(
                            vertical: 6, horizontal: 4),
                        onPressed: () => _addSymptom(symptom),
                        child: Row(
                          children: [
                            const Icon(CupertinoIcons.plus_circle,
                                size: 18, color: CupertinoColors.activeBlue),
                            const SizedBox(width: 6),
                            Text(symptom,
                                style: const TextStyle(
                                    color: CupertinoColors.white)),
                          ],
                        ),
                      )),
                    const SizedBox(height: 16),
                    CupertinoButton.filled(
                      onPressed:
                      _selectedSymptoms.isEmpty ? null : _analyzeSymptoms,
                      child: _isAnalyzing
                          ? const CupertinoActivityIndicator()
                          : const Text("Analyze Symptoms"),
                    ),
                  ],
                ),
              ),

              // Result area
              if (_diagnosisResult.isNotEmpty) ...[
                const SizedBox(height: 30),
                FadeTransition(
                  opacity: _fadeAnim,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: CupertinoColors.darkBackgroundGray.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_diagnosisResult,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        const Text("Recommended Treatment:",
                            style: TextStyle(
                                fontSize: 15,
                                color: CupertinoColors.systemGrey)),
                        const SizedBox(height: 6),
                        Text(_recommendedTreatment,
                            style: const TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 30),

              const Text("Recent Consultations",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              // Custom Cupertino-styled recent consultation
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.all(14),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey6.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(CupertinoIcons.lab_flask_solid,
                          size: 26, color: CupertinoColors.systemBlue),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text("Headache & Dizziness",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600)),
                            SizedBox(height: 4),
                            Text("Yesterday • Possible Migraine",
                                style: TextStyle(
                                    fontSize: 13,
                                    color: CupertinoColors.systemGrey)),
                          ],
                        ),
                      ),
                      const Icon(CupertinoIcons.chevron_forward,
                          color: CupertinoColors.systemGrey2, size: 18),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
