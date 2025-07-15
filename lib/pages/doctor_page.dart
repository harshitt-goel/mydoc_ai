import 'dart:io';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'ai_service.dart';

class DoctorPage extends StatefulWidget {
  const DoctorPage({super.key});

  @override
  State<DoctorPage> createState() => _DoctorPageState();
}

class _DoctorPageState extends State<DoctorPage> with SingleTickerProviderStateMixin {
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
    'Muscle aches',
    'Rash',
    'Joint pain',
    'Diarrhea',
    'Vomiting',
    'Abdominal pain'
  ];
  List<String> _filteredSymptoms = [];
  bool _isAnalyzingText = false;
  String _diagnosisResult = '';
  String _recommendedTreatment = '';
  String _prescribedMedication = '';
  String _preventionTips = '';
  bool _consultProfessional = false;

  // Image-related
  File? _selectedImage;
  bool _isAnalyzingImage = false;
  String _imageDiagnosis = '';

  late AnimationController _controller;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _filteredSymptoms = _allSymptoms;
    _symptomController.addListener(_filterSymptoms);
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic);
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant DoctorPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reinitialize animation on reassemble
    if (!_controller.isAnimating && !_controller.isCompleted) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _symptomController.removeListener(_filterSymptoms);
    _symptomController.dispose();
    _controller.dispose();
    super.dispose();
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
    showCupertinoDialog(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: const Text("Clear All"),
        content: const Text("Are you sure you want to clear all symptoms and results?"),
        actions: [
          CupertinoDialogAction(
            child: const Text("Cancel"),
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text("Clear"),
            onPressed: () {
              setState(() {
                _selectedSymptoms.clear();
                _symptomController.clear();
                _filteredSymptoms = _allSymptoms;
                _diagnosisResult = '';
                _recommendedTreatment = '';
                _prescribedMedication = '';
                _preventionTips = '';
                _consultProfessional = false;
                _selectedImage = null;
                _imageDiagnosis = '';
              });
              Navigator.of(dialogContext).pop();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _analyzeSymptoms() async {
    if (_selectedSymptoms.isEmpty) {
      showCupertinoDialog(
        context: context,
        builder: (dialogContext) => CupertinoAlertDialog(
          title: const Text("No Symptoms Selected"),
          content: const Text("Please select at least one symptom to analyze."),
          actions: [
            CupertinoDialogAction(
              child: const Text("OK"),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
          ],
        ),
      );
      return;
    }

    setState(() {
      _isAnalyzingText = true;
      _diagnosisResult = '';
      _recommendedTreatment = '';
      _prescribedMedication = '';
      _preventionTips = '';
      _consultProfessional = false;
    });

    try {
      final result = await AIService.analyzeSymptoms(_selectedSymptoms);
      bool isSevere = _selectedSymptoms.contains('Chest pain') ||
          _selectedSymptoms.contains('Shortness of breath');
      setState(() {
        _diagnosisResult = "AI Diagnosis";
        _recommendedTreatment = result;
        _prescribedMedication = "Consult a doctor for medication"; // Placeholder
        _preventionTips = "Maintain hydration, rest, and avoid triggers."; // Placeholder
        _consultProfessional = isSevere;
      });
    } catch (e, stackTrace) {
      debugPrint("Symptom Analysis Error: $e\nStack Trace: $stackTrace");
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (dialogContext) => CupertinoAlertDialog(
            title: const Text("Analysis Error"),
            content: Text(
              "Failed to analyze symptoms: $e\nPlease configure SERVER_URL in .env with a valid address (e.g., http://192.168.1.100:8000).",
            ),
            actions: [
              CupertinoDialogAction(
                child: const Text("OK"),
                onPressed: () => Navigator.of(dialogContext).pop(),
              ),
            ],
          ),
        );
      }
      setState(() {
        _diagnosisResult = "Error";
        _recommendedTreatment = "Failed to analyze. Check server configuration or connection.";
      });
    } finally {
      setState(() => _isAnalyzingText = false);
    }
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
          _imageDiagnosis = '';
        });
        await _analyzeImage(_selectedImage!);
      }
    } catch (e) {
      if (mounted) {
        debugPrint("Image Picker Error: $e");
        showCupertinoDialog(
          context: context,
          builder: (dialogContext) => CupertinoAlertDialog(
            title: const Text("Error"),
            content: Text("Failed to pick image: $e"),
            actions: [
              CupertinoDialogAction(
                child: const Text("OK"),
                onPressed: () => Navigator.of(dialogContext).pop(),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> _analyzeImage(File image) async {
    setState(() {
      _isAnalyzingImage = true;
      _imageDiagnosis = '';
    });

    final bytes = await image.readAsBytes();
    final apiKey = dotenv.env['HUGGINGFACE_API_KEY'];
    if (apiKey == null) {
      debugPrint("HUGGINGFACE_API_KEY is not set in .env");
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (dialogContext) => CupertinoAlertDialog(
            title: const Text("Configuration Error"),
            content: const Text("API key is missing. Please check your .env file."),
            actions: [
              CupertinoDialogAction(
                child: const Text("OK"),
                onPressed: () => Navigator.of(dialogContext).pop(),
              ),
            ],
          ),
        );
      }
      setState(() => _isAnalyzingImage = false);
      return;
    }

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
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final resultJson = json.decode(response.body);
        final prediction = resultJson[0]['label'];
        final confidence = (resultJson[0]['score'] * 100).toStringAsFixed(2);
        setState(() {
          _imageDiagnosis = '$prediction (Confidence: $confidence%)';
          _consultProfessional = _consultProfessional || prediction.toLowerCase().contains('severe');
        });
      } else {
        throw Exception('API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e, stackTrace) {
      debugPrint("Image Analysis Error: $e\nStack Trace: $stackTrace");
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (dialogContext) => CupertinoAlertDialog(
            title: const Text("Image Analysis Error"),
            content: Text("Failed to analyze image: $e"),
            actions: [
              CupertinoDialogAction(
                child: const Text("OK"),
                onPressed: () => Navigator.of(dialogContext).pop(),
              ),
            ],
          ),
        );
      }
      setState(() {
        _imageDiagnosis = "Failed to analyze. Check your connection or try again.";
      });
    } finally {
      setState(() => _isAnalyzingImage = false);
    }
  }

  Future<void> _callAmbulance() async {
    showCupertinoDialog(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: const Text("Call Emergency Services"),
        content: const Text("Do you want to call an ambulance? This will dial emergency services."),
        actions: [
          CupertinoDialogAction(
            child: const Text("Cancel"),
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text("Call"),
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              const url = 'tel:911'; // Replace with appropriate emergency number
              if (await canLaunchUrl(Uri.parse(url))) {
                await launchUrl(Uri.parse(url));
              } else {
                if (mounted) {
                  showCupertinoDialog(
                    context: context,
                    builder: (dialogContext) => CupertinoAlertDialog(
                      title: const Text("Error"),
                      content: const Text("Unable to make a call. Please dial emergency services manually."),
                      actions: [
                        CupertinoDialogAction(
                          child: const Text("OK"),
                          onPressed: () => Navigator.of(dialogContext).pop(),
                        ),
                      ],
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSymptomChip(String text) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF2A3B4A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF3B4A5A)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _removeSymptom(text),
              child: const Icon(
                CupertinoIcons.clear_circled_solid,
                size: 18,
                color: Color(0xFFA3BFFA),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFF1A252F),
      navigationBar: CupertinoNavigationBar(
        middle: const Text(
          "AI Doctor",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        trailing: (_selectedSymptoms.isNotEmpty || _selectedImage != null)
            ? GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            _clearAll();
          },
          child: const Icon(
            CupertinoIcons.clear_circled,
            size: 28,
            color: Color(0xFF4A90E2),
          ),
        )
            : null,
        backgroundColor: const Color(0xFF1A252F).withOpacity(0.8),
      ),
      child: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            children: [
              // Emergency Call Button
              CupertinoButton.filled(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(CupertinoIcons.phone_fill, size: 20),
                    SizedBox(width: 8),
                    Text(
                      "Call Ambulance",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                onPressed: () {
                  HapticFeedback.heavyImpact();
                  _callAmbulance();
                },
              ),
              const SizedBox(height: 32),

              // Symptom Checker
              const Text(
                "Symptom Checker",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              CupertinoTextField(
                controller: _symptomController,
                placeholder: "Search symptoms...",
                prefix: const Padding(
                  padding: EdgeInsets.only(left: 12),
                  child: Icon(CupertinoIcons.search, color: Color(0xFFA3BFFA)),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                style: const TextStyle(color: Colors.white, fontSize: 16),
                placeholderStyle: const TextStyle(color: Color(0xFF6B7280)),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A3B4A),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF3B4A5A), width: 0.5),
                ),
                cursorColor: const Color(0xFF4A90E2),
              ),
              const SizedBox(height: 12),
              if (_selectedSymptoms.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _selectedSymptoms.map(_buildSymptomChip).toList(),
                ),
              if (_symptomController.text.isNotEmpty)
                Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A3B4A),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF3B4A5A), width: 0.5),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _filteredSymptoms.length,
                    itemBuilder: (context, index) {
                      final symptom = _filteredSymptoms[index];
                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          _addSymptom(symptom);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Color(0xFF3B4A5A), width: 0.5),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                CupertinoIcons.plus_circle,
                                size: 18,
                                color: Color(0xFF4A90E2),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  symptom,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 16),
              CupertinoButton.filled(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: _isAnalyzingText
                    ? const CupertinoActivityIndicator(radius: 12)
                    : const Text(
                  "Analyze Symptoms",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                onPressed: _selectedSymptoms.isEmpty ? null : () {
                  HapticFeedback.mediumImpact();
                  _analyzeSymptoms();
                },
              ),

              // Symptom Analysis Results
              if (_diagnosisResult.isNotEmpty) ...[
                const SizedBox(height: 32),
                const Text(
                  "Diagnosis Results",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A3B4A),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF3B4A5A), width: 0.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _diagnosisResult,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Recommended Treatment:",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFFA3BFFA),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _recommendedTreatment,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Prescribed Medication:",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFFA3BFFA),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _prescribedMedication,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Prevention Tips:",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFFA3BFFA),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _preventionTips,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                      if (_consultProfessional) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE57373).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFE57373), width: 0.5),
                          ),
                          child: const Text(
                            "⚠️ Consult a medical professional immediately due to potentially serious symptoms.",
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFFE57373),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // Image-based Diagnosis
              const Text(
                "Image-based Diagnosis",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              CupertinoButton.filled(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: const Text(
                  "Upload Skin Image",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  _pickImage();
                },
              ),
              const SizedBox(height: 16),
              if (_selectedImage != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(
                    _selectedImage!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              if (_isAnalyzingImage)
                const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: CupertinoActivityIndicator(radius: 12),
                ),
              if (_imageDiagnosis.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A3B4A),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF3B4A5A), width: 0.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Image Diagnosis:",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFFA3BFFA),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _imageDiagnosis,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                        if (_consultProfessional && _imageDiagnosis.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE57373).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFE57373), width: 0.5),
                            ),
                            child: const Text(
                              "⚠️ Consult a medical professional immediately due to potentially serious condition.",
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFFE57373),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
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