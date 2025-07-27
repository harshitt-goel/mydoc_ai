import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'ai_service.dart';

class DoctorPage extends StatefulWidget {
  const DoctorPage({super.key});

  @override
  State<DoctorPage> createState() => _DoctorPageState();
}

class _DoctorPageState extends State<DoctorPage> {
  final List<String> _selectedSymptoms = [];
  final TextEditingController _symptomController = TextEditingController();
  final TextEditingController _customPromptController = TextEditingController();
  final List<String> _allSymptoms = [
    'Headache', 'Fever', 'Cough', 'Fatigue', 'Nausea',
    'Dizziness', 'Sore throat', 'Shortness of breath',
    'Chest pain', 'Muscle aches', 'Rash', 'Joint pain',
    'Diarrhea', 'Vomiting', 'Abdominal pain'
  ];
  List<String> _filteredSymptoms = [];

  File? _selectedImage;
  String _imageDiagnosis = '';
  String _textDiagnosis = '';
  bool _isAnalyzingImage = false;
  bool _isAnalyzingText = false;

  @override
  void initState() {
    super.initState();
    _filteredSymptoms = _allSymptoms;
    _symptomController.addListener(_filterSymptoms);
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
      });
    }
  }

  Future<void> _analyzeSymptoms() async {
    final customPrompt = _customPromptController.text.trim();
    if (_selectedSymptoms.isEmpty && customPrompt.isEmpty) return;

    setState(() {
      _isAnalyzingText = true;
      _textDiagnosis = '';
    });

    try {
      final result = await AIService.analyzeSymptoms(
        symptoms: _selectedSymptoms,
        customPrompt: customPrompt,
      );
      setState(() => _textDiagnosis = result);
    } catch (e) {
      setState(() => _textDiagnosis = 'Error: $e');
    } finally {
      setState(() => _isAnalyzingText = false);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _imageDiagnosis = '';
      });
      await _analyzeImage(File(pickedFile.path));
    }
  }

  Future<void> _analyzeImage(File image) async {
    setState(() {
      _isAnalyzingImage = true;
      _imageDiagnosis = '';
    });
    try {
      final bytes = await image.readAsBytes();
      final result = await AIService.analyzeImage(bytes);
      setState(() => _imageDiagnosis = result);
    } catch (e) {
      setState(() => _imageDiagnosis = 'Error: $e');
    } finally {
      setState(() => _isAnalyzingImage = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Doctor')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text('Symptom Checker', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            TextField(
              controller: _symptomController,
              decoration: const InputDecoration(hintText: 'Enter or select symptoms...'),
            ),
            Wrap(
              spacing: 8,
              children: _filteredSymptoms
                  .map((s) => ActionChip(label: Text(s), onPressed: () => _addSymptom(s)))
                  .toList(),
            ),
            const SizedBox(height: 12),
            if (_selectedSymptoms.isNotEmpty)
              Wrap(
                spacing: 8,
                children: _selectedSymptoms
                    .map((s) => Chip(
                  label: Text(s),
                  onDeleted: () => setState(() => _selectedSymptoms.remove(s)),
                ))
                    .toList(),
              ),
            const SizedBox(height: 12),
            TextField(
              controller: _customPromptController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Custom Prompt',
                hintText: 'Describe your symptoms or health concern...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _isAnalyzingText ? null : _analyzeSymptoms,
              child: _isAnalyzingText
                  ? const CircularProgressIndicator()
                  : const Text('Analyze Symptoms'),
            ),
            if (_textDiagnosis.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(_textDiagnosis),
              ),
            const Divider(),
            const Text('Image Diagnosis', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ElevatedButton(onPressed: _pickImage, child: const Text('Upload Skin Image')),
            if (_isAnalyzingImage) const CircularProgressIndicator(),
            if (_imageDiagnosis.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(_imageDiagnosis),
              ),
            if (_selectedImage != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.file(_selectedImage!, height: 200),
              ),
          ],
        ),
      ),
    );
  }
}
