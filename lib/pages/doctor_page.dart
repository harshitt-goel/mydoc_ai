// doctor_page.dart (Updated)
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'ai_service.dart';

class DoctorPage extends StatefulWidget {
  const DoctorPage({super.key});

  @override
  State<DoctorPage> createState() => _DoctorPageState();
}

class _DoctorPageState extends State<DoctorPage> {
  final List<String> _selectedSymptoms = [];
  final TextEditingController _symptomController = TextEditingController();
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
    if (_selectedSymptoms.isEmpty) return;
    setState(() {
      _isAnalyzingText = true;
      _textDiagnosis = '';
    });
    try {
      final result = await AIService.analyzeSymptoms(_selectedSymptoms);
      setState(() => _textDiagnosis = result);
    } catch (e) {
      debugPrint('Symptom Analysis Error: $e');
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
      debugPrint('Image Analysis Error: $e');
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
              decoration: const InputDecoration(hintText: 'Enter symptoms...'),
            ),
            Wrap(
              spacing: 8,
              children: _filteredSymptoms.map((s) => ActionChip(label: Text(s), onPressed: () => _addSymptom(s))).toList(),
            ),
            const SizedBox(height: 8),
            if (_selectedSymptoms.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                children: _selectedSymptoms
                    .map((s) => Chip(label: Text(s), onDeleted: () => setState(() => _selectedSymptoms.remove(s))))
                    .toList(),
              ),
              ElevatedButton(
                onPressed: _isAnalyzingText ? null : _analyzeSymptoms,
                child: _isAnalyzingText ? const CircularProgressIndicator() : const Text('Analyze Symptoms'),
              ),
              if (_textDiagnosis.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(_textDiagnosis),
                ),
            ],
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