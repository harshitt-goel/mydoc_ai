import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:google_generative_ai/google_generative_ai.dart';

class AIService {
  static Future<String> analyzeSymptoms(List<String> symptoms) async {
    final apiKey = dotenv.env['GEMINI_API_KEY']; // Use GEMINI_API_KEY
    if (apiKey == null) {
      throw Exception("GEMINI_API_KEY is not set in .env");
    }

    final model = GenerativeModel(model: 'gemini-2.5-pro', apiKey: apiKey); // Initialize Gemini-Pro model
    final prompt = "Given these symptoms: ${symptoms.join(', ')}, what is the likely illness and treatment plan? Provide a concise answer.";

    try {
      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);
      return response.text ?? "No diagnosis available."; // Get text from response
    } catch (e) {
      throw Exception("Gemini Symptom Analysis Error: $e");
    }
  }

  static Future<String> analyzeImage(Uint8List imageBytes) async {
    final apiKey = dotenv.env['GEMINI_API_KEY']; // Use GEMINI_API_KEY
    if (apiKey == null) {
      throw Exception("GEMINI_API_KEY is not set in .env");
    }

    // Initialize Gemini-Pro-Vision model for image analysis
    final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);

    try {
      final content = [
        Content.text("What is this skin condition and what are some general recommendations?"),
        Content.data('image/jpeg', imageBytes), // Assuming JPEG, adjust if needed
      ];
      final response = await model.generateContent(content);
      return response.text ?? "No image diagnosis available.";
    } catch (e) {
      throw Exception("Gemini Image Analysis Error: $e");
    }
  }
}