import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

class GeminiService {
//put api in .env file if possible(prnv)
  static const String _apiKey = 'AIzaSyDYjLQFjC4o0JHUJduGlTYp_BuIgaINKec';
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta';

  final List<String> _availableWorkingModels = [];
  bool _modelsDiscovered = false;

  Future<void> _discoverModels() async {
    if (_modelsDiscovered) return;
    try {
      final response = await http.get(Uri.parse('$_baseUrl/models?key=$_apiKey'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['models'] != null) {
          print("--- Available Gemini Models ---");

          for (var model in data['models']) {
            String name = model['name'];
            print(name); // Print available models in console
            
            if (model['supportedGenerationMethods'] != null && 
                (model['supportedGenerationMethods'] as List).contains('generateContent')) {
              _availableWorkingModels.add(name);
            }
          }
          print("-------------------------------");
          _modelsDiscovered = true;
        }
      } else {
        print("Model discovery returned status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Model discovery failed: $e");
    }
  }

  Future<String> getAIResponse(String userMessage) async {
    // 3. Add Model Discovery & Initialization
    await _discoverModels();

    final prompt = """
You are MindCare, a supportive and empathetic mental health assistant.

Rules:
- Be calm and supportive
- Do NOT give medical diagnosis
- Keep responses short and friendly

User message:
$userMessage
""";

    List<String> modelsToTry = [];

    // Add Random Model Selection (Load Balancing) from discovered working models
    if (_availableWorkingModels.isNotEmpty) {
       final random = Random();
       String randomlyPicked = _availableWorkingModels[random.nextInt(_availableWorkingModels.length)];
       modelsToTry.add(randomlyPicked);
    }

    // Add Model Fallback sequence in the specific order requested
    modelsToTry.addAll([
      'models/gemini-2.5-flash',
      'models/gemini-flash-latest',
      'models/gemini-2.0-flash-lite'
    ]);

    // Ensure we don't try the exact same model more than once by eliminating duplicates
    // while preserving the fallback order.
    modelsToTry = modelsToTry.toSet().toList();

    for (String model in modelsToTry) {
      int retries = 0;
      bool modelFailed = false;

      while (retries <= 2 && !modelFailed) {
        try {
          final url = '$_baseUrl/$model:generateContent?key=$_apiKey';
          final response = await http.post(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'contents': [
                {
                  'parts': [
                    {'text': prompt}
                  ]
                }
              ]
            }),
          );

          // Keep existing logging
          print("Attempting with Model: $model (Retry: $retries)");
          print(response.statusCode);
          print(response.body);

          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            if (data['candidates'] != null && data['candidates'].isNotEmpty) {
              final content = data['candidates'][0]['content'];
              if (content['parts'] != null && content['parts'].isNotEmpty) {
                return content['parts'][0]['text'];
              }
            }
            // Parse error (safe check failed), move to next model
            modelFailed = true;
          } else if (response.statusCode == 503) {
            // 503 UNAVAILABLE (Model overloaded) -> Retry Logic
            if (retries < 2) {
              print("Model $model returned 503. Retrying in 2 seconds...");
              retries++;
              await Future.delayed(const Duration(seconds: 2));
            } else {
              print("Model $model max retries reached. Attempting fallback...");
              modelFailed = true;
            }
          } else {
            // 404, 400, or any other hard error -> move to next model immediately
            print("Model $model returned error ${response.statusCode}. Attempting fallback...");
            modelFailed = true;
          }
        } catch (e) {
          print("Error during API call to $model: $e");
          modelFailed = true; 
        }
      } // End retry loop
    } // End model iteration loop

    // 4. Return User-Friendly Message if ALL fail
    return "Things are a bit busy right now, but I'm still here with you. Try again in a moment.";
  }
}
