import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class HttpService {
  HttpService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const Duration _timeout = Duration(seconds: 15);

  Future<dynamic> getJson(String url, {Map<String, String>? headers}) async {
    final uri = Uri.parse(url);

    try {
      final response = await _client
          .get(
            uri,
            headers: <String, String>{
              'Accept': 'application/json',
              'Content-Type': 'application/json',
              ...?headers,
            },
          )
          .timeout(_timeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      }

      throw HttpException(
        'Request failed with status ${response.statusCode}: ${response.reasonPhrase ?? 'Unknown reason'}',
      );
    } on SocketException {
      throw const HttpException(
        'No internet connection. Please check your network and try again.',
      );
    } on TimeoutException {
      throw const HttpException(
        'Request timed out. Please try again in a moment.',
      );
    } on FormatException {
      throw const HttpException('Unexpected server response format.');
    } on http.ClientException catch (error) {
      throw HttpException('Network error: ${error.message}');
    }
  }

  void dispose() {
    _client.close();
  }
}
