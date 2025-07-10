import 'dart:io';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'ai_service.dart';

class DoctorPage extends StatefulWidget {
  const DoctorPage({super.key});

  @override
  State<DoctorPage> createState() => _DoctorPageState();
}

class _DoctorPageState extends State<DoctorPage> {
  // Symptom-related
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
  bool _isAnalyzingText = false;
  String _diagnosisResult = '';
  String _recommendedTreatment = '';

  // Image-related
  File? _selectedImage;
  bool _isAnalyzingImage = false;
  String _imageDiagnosis = '';

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
      _isAnalyzingText = true;
      _diagnosisResult = '';
      _recommendedTreatment = '';
    });

    try {
      final result = await AIService.analyzeSymptoms(_selectedSymptoms);
      setState(() {
        _diagnosisResult = "AI Diagnosis";
        _recommendedTreatment = result;
      });
    } catch (e) {
      setState(() {
        _diagnosisResult = "Error";
        _recommendedTreatment = e.toString();
      });
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
      await _analyzeImage(_selectedImage!);
    }
  }

  Future<void> _analyzeImage(File image) async {
    setState(() {
      _isAnalyzingImage = true;
      _imageDiagnosis = '';
    });

    final bytes = await image.readAsBytes();
    final apiKey = dotenv.env['HUGGINGFACE_API_KEY'];
    const String apiUrl =
        'https://api-inference.huggingface.co/models/dima806/skin-disease-classification';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/octet-stream',
        },
        body: bytes,
      );

      if (response.statusCode == 200) {
        final resultJson = json.decode(response.body);
        final prediction = resultJson[0]['label'];
        final confidence = (resultJson[0]['score'] * 100).toStringAsFixed(2);

        setState(() {
          _imageDiagnosis = '$prediction (Confidence: $confidence%)';
        });
      } else {
        setState(() {
          _imageDiagnosis = 'API Error: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _imageDiagnosis = 'Error: $e';
      });
    } finally {
      setState(() => _isAnalyzingImage = false);
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
          Text(text, style: const TextStyle(color: CupertinoColors.white, fontSize: 14)),
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
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
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
            // 🔍 Symptom Checker
            const Text("Describe your symptoms", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            CupertinoTextField(
              controller: _symptomController,
              placeholder: 'Search symptoms...',
              prefix: const Icon(CupertinoIcons.search),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
              style: const TextStyle(color: CupertinoColors.white),
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey5,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 12),
            if (_selectedSymptoms.isNotEmpty) Wrap(children: _selectedSymptoms.map(_buildChip).toList()),
            if (_symptomController.text.isNotEmpty)
              ..._filteredSymptoms.map((symptom) => CupertinoButton(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                onPressed: () => _addSymptom(symptom),
                child: Row(
                  children: [
                    const Icon(CupertinoIcons.plus_circle,
                        size: 18, color: CupertinoColors.activeBlue),
                    const SizedBox(width: 6),
                    Text(symptom, style: const TextStyle(color: CupertinoColors.white)),
                  ],
                ),
              )),
            const SizedBox(height: 16),
            CupertinoButton.filled(
              onPressed: _selectedSymptoms.isEmpty ? null : _analyzeSymptoms,
              child: _isAnalyzingText
                  ? const CupertinoActivityIndicator()
                  : const Text("Analyze Symptoms"),
            ),

            // 🧠 Symptom result
            if (_diagnosisResult.isNotEmpty) ...[
              const SizedBox(height: 30),
              Text(_diagnosisResult, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text("Recommended Treatment:", style: TextStyle(color: CupertinoColors.systemGrey)),
              const SizedBox(height: 4),
              Text(_recommendedTreatment),
            ],

            const Divider(height: 40),

            // 📸 Image-based Diagnosis
            const Text("Or upload a skin image", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            CupertinoButton.filled(
              child: const Text('Pick Image'),
              onPressed: _pickImage,
            ),
            const SizedBox(height: 12),
            if (_selectedImage != null) Image.file(_selectedImage!, height: 200),
            if (_isAnalyzingImage)
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: CupertinoActivityIndicator(),
              ),
            if (_imageDiagnosis.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text("Image Diagnosis: $_imageDiagnosis"),
              ),
          ],
        ),
      ),
    );
  }
}
