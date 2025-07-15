import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AIService {
  static String _endpoint = dotenv.env['SERVER_URL'] ?? "http://localhost:8000/generate"; // Default to localhost if not set
  static const Map<String, String> _headers = {
    "Content-Type": "application/json"
  };

  static Future<String> analyzeSymptoms(List<String> symptoms) async {
    // Validate endpoint
    try {
      Uri.parse(_endpoint);
    } catch (e) {
      throw Exception("Invalid server URL: $_endpoint. Please configure SERVER_URL in .env with a valid address (e.g., http://192.168.1.100:8000).");
    }

    final prompt = "The patient reports the following symptoms: ${symptoms.join(', ')}. What could be the possible diagnosis and treatment?";

    final response = await http.post(
      Uri.parse(_endpoint),
      headers: _headers,
      body: jsonEncode({"text": prompt}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["generated_text"] ?? "No response from AI.";
    } else {
      throw Exception("AI Error: ${response.statusCode} ${response.body}");
    }
  }
}