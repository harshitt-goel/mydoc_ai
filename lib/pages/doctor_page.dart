import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DoctorPage extends StatefulWidget {
  const DoctorPage({super.key});

  @override
  State<DoctorPage> createState() => _DoctorPageState();
}

class _DoctorPageState extends State<DoctorPage> {
  final List<String> _selectedSymptoms = [];
  final TextEditingController _symptomController = TextEditingController();
  bool _isAnalyzing = false;
  String _diagnosisResult = '';
  String _recommendedTreatment = '';

  // Sample symptom database
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

  @override
  void initState() {
    super.initState();
    _filteredSymptoms = _allSymptoms;
    _symptomController.addListener(_filterSymptoms);
  }

  void _filterSymptoms() {
    setState(() {
      _filteredSymptoms = _allSymptoms
          .where((symptom) => symptom
          .toLowerCase()
          .contains(_symptomController.text.toLowerCase()))
          .toList();
    });
  }

  void _addSymptom(String symptom) {
    if (!_selectedSymptoms.contains(symptom)) {
      setState(() {
        _selectedSymptoms.add(symptom);
        _symptomController.clear();
        _filterSymptoms();
      });
    }
  }

  void _removeSymptom(String symptom) {
    setState(() {
      _selectedSymptoms.remove(symptom);
    });
  }

  Future<void> _analyzeSymptoms() async {
    if (_selectedSymptoms.isEmpty) return;

    setState(() {
      _isAnalyzing = true;
      _diagnosisResult = '';
      _recommendedTreatment = '';
    });

    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 2));

    // Mock diagnosis logic (replace with real AI integration)
    String result;
    String treatment;

    if (_selectedSymptoms.contains('Fever') &&
        _selectedSymptoms.contains('Cough')) {
      result = 'Possible Flu';
      treatment = 'Rest, fluids, and over-the-counter fever reducers';
    } else if (_selectedSymptoms.contains('Headache') &&
        _selectedSymptoms.contains('Dizziness')) {
      result = 'Possible Migraine';
      treatment = 'Rest in a dark room, consider pain relievers';
    } else {
      result = 'General Illness';
      treatment = 'Rest and monitor symptoms. Consult doctor if symptoms worsen';
    }

    setState(() {
      _isAnalyzing = false;
      _diagnosisResult = result;
      _recommendedTreatment = treatment;
    });
  }

  void _clearAll() {
    setState(() {
      _selectedSymptoms.clear();
      _diagnosisResult = '';
      _recommendedTreatment = '';
      _symptomController.clear();
      _filterSymptoms();
    });
  }

  @override
  void dispose() {
    _symptomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Doctor'),
        actions: [
          if (_selectedSymptoms.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: _clearAll,
              tooltip: 'Clear all',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Symptom Input Section
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Icon(Icons.medical_services,
                        size: 64, color: Colors.blue),
                    const SizedBox(height: 16),
                    const Text(
                      'Describe your symptoms',
                      style:
                      TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _symptomController,
                      decoration: InputDecoration(
                        hintText: 'Search symptoms...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Selected Symptoms
                    if (_selectedSymptoms.isNotEmpty) ...[
                      Wrap(
                        spacing: 8,
                        children: _selectedSymptoms
                            .map((symptom) => Chip(
                          label: Text(symptom),
                          onDeleted: () => _removeSymptom(symptom),
                        ))
                            .toList(),
                      ),
                      const SizedBox(height: 16),
                    ],
                    // Symptom Suggestions
                    if (_symptomController.text.isNotEmpty)
                      SizedBox(
                        height: 200,
                        child: ListView.builder(
                          itemCount: _filteredSymptoms.length,
                          itemBuilder: (context, index) {
                            final symptom = _filteredSymptoms[index];
                            return ListTile(
                              leading: const Icon(Icons.add_circle_outline),
                              title: Text(symptom),
                              onTap: () => _addSymptom(symptom),
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed:
                      _selectedSymptoms.isEmpty ? null : _analyzeSymptoms,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: _isAnalyzing
                          ? const CircularProgressIndicator(
                          color: Colors.white)
                          : const Text('Analyze Symptoms'),
                    ),
                  ],
                ),
              ),
            ),

            // Results Section
            if (_diagnosisResult.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Text(
                'Diagnosis Results',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Card(
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _diagnosisResult,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Recommended Treatment:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(_recommendedTreatment),
                    ],
                  ),
                ),
              ),
            ],

            // Recent Consultations
            const SizedBox(height: 24),
            const Text(
              'Recent Consultations',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(Icons.medical_services),
                title: const Text('Headache & Dizziness'),
                subtitle: const Text('Yesterday - Possible Migraine'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // Navigate to consultation details
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}