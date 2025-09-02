import 'dart:convert';
import 'package:http/http.dart' as http;

class AIWeeklySummaryService {
  // Ganti URL sesuai endpoint Netlify Function untuk summary weekly
  final String functionUrl = 'https://lockinappp.netlify.app/.netlify/functions/generate-weekly-summary';

  Future<Map<String, String?>> generateWeeklySummary(List<Map<String, dynamic>> journals) async {
    try {
      final response = await http.post(
        Uri.parse(functionUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"journals": journals}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        try {
          var raw = data['result'] ?? '';
          raw = raw.replaceAll('```json', '').replaceAll('```', '').trim();
          final jsonResult = jsonDecode(raw);
          return {
            "summary": jsonResult['summary'],
            "advice": jsonResult['advice'],
          };
        } catch (e) {}
      }
    } catch (e) {}
    return {"summary": null, "advice": null};
  }
}
