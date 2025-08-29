import 'dart:typed_data';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class AIService {
  static Future<String> analyzeSymptoms({
    required List<String> symptoms,
    required String customPrompt,
  }) async {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null) {
      throw Exception("GEMINI_API_KEY is not set in .env");
    }

    final model = GenerativeModel(model: 'gemini-2.5-pro', apiKey: apiKey);

    String finalPrompt = "Analyze these symptoms and provide response in 200 words in EXACTLY this format:\n"
    "[Differential Diagnosis (Max 3)]\n"
    "1. [Diagnosis] (Confidence: High/Moderate/Low)\n"
    "- Features: [characteristics]\n"
    "- Next Steps: [actions]\n"
    "- Rationale: [reasoning]\n"

    "2. [Diagnosis] (Confidence)\n"
    "- Features: [...]\n"
    "- Next Steps: [...]\n"

    "[Action Plan]"
    "- [Immediate step 1]\n"
    "- [Immediate step 2]\n"
    "- [Immediate step 3]\n"

    "[Clinical Notes]"
    "- Red flags: [if any]\n"
    "- Follow-up: [timeline]\n"
    "- Considerations: [additional notes]\n"

    "For these inputs:";

    if (symptoms.isNotEmpty && customPrompt.isNotEmpty) {
      finalPrompt += "Symptoms: ${symptoms.join(', ')}. Additional notes: $customPrompt";
    } else if (symptoms.isNotEmpty) {
      finalPrompt += "Symptoms: ${symptoms.join(', ')}";
    } else if (customPrompt.isNotEmpty) {
      finalPrompt += "Patient report: $customPrompt";
    } else {
      return "Please describe your symptoms or concerns.";
    }

    try {
      final content = [Content.text(finalPrompt)];
      final response = await model.generateContent(content);
      return response.text ?? "No diagnosis available.";
    } catch (e) {
      throw Exception("Gemini Symptom Analysis Error: $e");
    }
  }

  static Future<String> analyzeImage(Uint8List imageBytes) async {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null) {
      throw Exception("GEMINI_API_KEY is not set in .env");
    }

    final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);

    try {
      final content = [
        Content.text("What is this skin condition and what are some general recommendations?"),
        Content.data('image/jpeg', imageBytes),
      ];
      final response = await model.generateContent(content);
      return response.text ?? "No image diagnosis available.";
    } catch (e) {
      throw Exception("Gemini Image Analysis Error: $e");
    }
  }
}
