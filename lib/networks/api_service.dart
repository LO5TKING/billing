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

  Future<http.Response> getRequest({
    required String url,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: headers ?? {
          'Content-Type': 'application/json',
        },
      );

      return response;
    } catch (e) {
      throw Exception('Failed to make GET request: $e');
    }
  }

  Future<http.Response> putRequest({
    required String url,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );

      return response;
    } catch (e) {
      throw Exception('Failed to make PUT request: $e');
    }
  }

}