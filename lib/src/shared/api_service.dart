import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:k2_connect_flutter/src/shared/k2_connect_logger.dart';

// ignore: constant_identifier_names
enum HttpMethod { GET, POST, PUT, PATCH, DELETE }

const defaultHeaders = <String, String>{
  'User-Agent': 'Kopokopo-Dart-SDK',
};

class ApiService {
  http.Client? _client;

  ApiService({http.Client? client}) : _client = client;

  Future<http.Response?> sendRequest({
    required HttpMethod requestType,
    required Uri url,
    Map<String, String>? otherHeaders,
    dynamic queryParameters,
    int timeoutPeriod = 30,
  }) async {
    _client ??= http.Client();

    K2ConnectLogger.d('Making API call to $url');

    final headers = {
      ...defaultHeaders,
      if (otherHeaders != null) ...otherHeaders
    };

    K2ConnectLogger.d(
        'Request: $requestType $url, Headers: $headers, Params: $queryParameters');

    try {
      final response = await _sendHttpRequest(
          requestType, url, headers, queryParameters, timeoutPeriod);
      if (response?.statusCode == 401) {
        throw Exception('You are unauthorized to perform this request');
      }
      return response;
    } on TimeoutException catch (e) {
      K2ConnectLogger.d('Request timed out: $e');
      throw Exception('Request timed out. Please try again');
    } catch (e) {
      K2ConnectLogger.d(
          'We encountered an exception while processing your request: $e');
      rethrow;
    } finally {
      _dispose();
    }
  }

  Future<http.Response?> _sendHttpRequest(
    HttpMethod requestType,
    Uri uri,
    Map<String, String>? headers,
    dynamic body,
    int timeout,
  ) {
    switch (requestType) {
      case HttpMethod.GET:
        return _client!
            .get(uri, headers: headers)
            .timeout(Duration(seconds: timeout));
      case HttpMethod.POST:
        return _client!
            .post(uri, headers: headers, body: body)
            .timeout(Duration(seconds: timeout));
      case HttpMethod.PATCH:
        return _client!
            .patch(uri, headers: headers, body: body)
            .timeout(Duration(seconds: timeout));
      case HttpMethod.DELETE:
        return _client!
            .delete(uri, headers: headers, body: body)
            .timeout(Duration(seconds: timeout));
      default:
        K2ConnectLogger.d('MainRepo $requestType not implemented!');
        throw Exception('MainRepo $requestType not implemented!');
    }
  }

  void _dispose() {
    _client?.close();
    _client = null;
  }

  Future<T> processResponse<T>(
    http.Response? response,
    T Function(Map<String, dynamic>)? fromJson,
  ) async {
    if (response == null) {
      K2ConnectLogger.d('Failed to reach the server');
      throw Exception('Failed to reach the server');
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      K2ConnectLogger.d('HTTP error: ${response.statusCode}');
      throw Exception('HTTP error: ${response.statusCode}');
    }

    try {
      final jsonData = jsonDecode(response.body);

      if (fromJson == null) {
        return null as T;
      }

      return fromJson(jsonData);
    } on FormatException catch (e) {
      K2ConnectLogger.d(
          'The response received was in an unexpected format: $e');
      throw Exception('The response received was in an unexpected format');
    } on TypeError catch (e) {
      K2ConnectLogger.d('Type error: $e');
      throw Exception('Type error');
    } catch (e) {
      K2ConnectLogger.d('Unexpected error: $e');
      rethrow;
    }
  }
}
