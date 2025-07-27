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

    // Build final prompt
    String finalPrompt = '';
    if (symptoms.isNotEmpty && customPrompt.isNotEmpty) {
      finalPrompt =
      "The patient has the following symptoms: ${symptoms.join(', ')}. Additionally, they reported: $customPrompt. Please provide a likely diagnosis and treatment.";
    } else if (symptoms.isNotEmpty) {
      finalPrompt =
      "Given these symptoms: ${symptoms.join(', ')}, what is the likely illness and treatment plan?";
    } else if (customPrompt.isNotEmpty) {
      finalPrompt = "Patient says: $customPrompt. What could be the diagnosis and treatment?";
    } else {
      return "No symptoms or prompt provided.";
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
