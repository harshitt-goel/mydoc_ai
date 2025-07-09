import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  static const String _endpoint = "http://<your-server-ip>:8000/generate"; // Replace with your local/cloud IP
  static const Map<String, String> _headers = {
    "Content-Type": "application/json"
  };

  static Future<String> analyzeSymptoms(List<String> symptoms) async {
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
