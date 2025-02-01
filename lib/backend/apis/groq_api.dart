import 'dart:convert';
import 'package:http/http.dart' as http;

class GroqAPI {
  final String baseUrl = "https://api.groq.com/openai/v1/chat/completions";
  final String apiKey =
      "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"; // Replace with your API key

  Future<String?> sendMessage(String userPrompt) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          "Authorization": "Bearer $apiKey",
          "Content-Type": "application/json",
        },
        body: json.encode({
          "model": "llama3-8b-8192",
          "messages": [
            {
              "role": "system",
              "content": "You are a creative and captivating story/script writer, specializing in short, engaging scripts perfect for YouTube shorts or similar formats.\n"
                  "Your task is to write brief, interesting, and visually compelling scripts without dialogue, scene numbers, or any action notes.\n"
                  "The script should read like a fast-paced narrative that flows seamlessly, delivering key points in a fun, energetic, and impactful way.\n"
                  "Keep it short, snappy, and packed with engaging information that captures attention from the start. No more than 100 words.",
            },
            {
              "role": "user",
              "content": userPrompt,
            }
          ],
          "max_tokens": 1080,
          "temperature": 0.5,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['choices']?[0]['message']?['content']?.trim();
      } else {
        print("Failed to fetch response: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }
}
