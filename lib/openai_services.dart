import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenAIService {
  static const String apiKey =
      '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';
  static const String endpoint = 'https://api.openai.com/v1/completions';

  static Future<String> fetchChatGPTResponse(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model':
              'text-davinci-003', // Replace with the correct model if using a newer one
          'prompt': prompt,
          'max_tokens': 100,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data['choices'][0]['text'].trim();
      } else {
        return 'Sorry, I am having trouble responding right now.';
      }
    } catch (e) {
      return 'An error occurred. Please try again later.';
    }
  }
}
