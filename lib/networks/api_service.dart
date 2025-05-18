import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {

  Future<http.Response> postRequest({
    required String url,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );

      return response;
    } catch (e) {
      throw Exception('Failed to make POST request: $e');
    }
  }

}