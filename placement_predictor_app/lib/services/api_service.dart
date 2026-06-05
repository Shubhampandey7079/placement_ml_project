import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

// NOTE: TimeoutException type comes from dart:async, not dart:io.
import 'dart:async';


import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../core/constants/api_constants.dart';
import '../models/prediction_request.dart';
import '../models/prediction_result.dart';

class ApiService {
  final http.Client _client = http.Client();

  // Health check endpoint
  Future<bool> checkHealth() async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.endpointHealth}');
    debugPrint('[API][HEALTH] GET $uri');

    try {
      final response = await _client
          .get(uri)
          .timeout(const Duration(seconds: 10));

      debugPrint('[API][HEALTH] status=${response.statusCode}');
      debugPrint('[API][HEALTH] body=${response.body}');

      if (response.statusCode != 200) return false;

      final body = jsonDecode(response.body);
      // Some backends return {"status":"healthy"} while others may return {"ok":true}
      if (body is Map<String, dynamic>) {
        if (body['status'] != null) return body['status'] == 'healthy';
        if (body['ok'] != null) return body['ok'] == true;
      }
      return false;
    } on SocketException catch (e) {
      debugPrint('[API][HEALTH][ERROR] SocketException: $e');
      return false;
    } on TimeoutException catch (e) {
      debugPrint('[API][HEALTH][ERROR] TimeoutException: $e');
      return false;
    } catch (e) {
      debugPrint('[API][HEALTH][ERROR] $e');
      return false;
    }
  }

  // Predict endpoint
  Future<PredictionResult> predict(PredictionRequest request) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.endpointPredict}');
    final payload = request.toJson();

    debugPrint('[API][PREDICT] POST $uri');
    debugPrint('[API][PREDICT] requestPayload=$payload');

    try {
      final response = await _client
          .post(
            uri,
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 20));

      debugPrint('[API][PREDICT] status=${response.statusCode}');
      debugPrint('[API][PREDICT] responseBody=${response.body}');

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);
        if (decoded is! Map<String, dynamic>) {
          throw FormatException(
            'Unexpected JSON type. Expected object but got: ${decoded.runtimeType}',
          );
        }
        try {
          final result = PredictionResult.fromJson(decoded);
          debugPrint('[API][PREDICT] parsedResult prediction=${result.prediction} confidence=${result.confidence}');
          return result;
        } catch (e) {
          debugPrint('[API][PREDICT][PARSING_ERROR] $e');
          rethrow;
        }
      }

      // Handle known HTTP errors with useful details
      final bodyText = response.body;
      if (response.statusCode == 404) {
        throw Exception('404 Not Found: ${uri.toString()}. Body: $bodyText');
      }
      if (response.statusCode == 500) {
        throw Exception('500 Internal Server Error. Body: $bodyText');
      }

      // Try to decode error
      try {
        final dynamic decodedErr = jsonDecode(bodyText);
        if (decodedErr is Map<String, dynamic>) {
          throw Exception(decodedErr['error'] ?? decodedErr['message'] ?? 'Prediction failed (HTTP ${response.statusCode}).');
        }
      } catch (_) {
        // ignore json decode errors
      }

      // Give a concrete hint when server returns HTML.
      if (bodyText.trimLeft().startsWith('<!doctype') || bodyText.trimLeft().startsWith('<html')) {
        throw Exception('Backend returned HTML for prediction (HTTP ${response.statusCode}). Likely wrong route or server-side crash. Body: $bodyText');
      }

      throw Exception('Prediction failed (HTTP ${response.statusCode}). Body: $bodyText');

    } on SocketException catch (e) {
      debugPrint('[API][PREDICT][ERROR] SocketException: $e');
      throw Exception('SocketException: Could not connect to the backend. $e');
    } on TimeoutException catch (e) {
      debugPrint('[API][PREDICT][ERROR] TimeoutException: $e');
      throw Exception('TimeoutException: Backend did not respond in time. $e');
    } on FormatException catch (e) {
      debugPrint('[API][PREDICT][ERROR] JSON FormatException: $e');
      throw Exception('JSON parsing failure: $e');
    } catch (e) {
      debugPrint('[API][PREDICT][ERROR] $e');
      throw Exception('Prediction failed: $e');
    }
  }

  // Generate AI report endpoint
  Future<String> generateReport(PredictionResult result) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.endpointGenerateReport}');
    final payload = result.toJson();

    debugPrint('[API][REPORT] POST $uri');
    debugPrint('[API][REPORT] requestPayload=$payload');

    try {
      final response = await _client
          .post(
            uri,
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 60));

      debugPrint('[API][REPORT] status=${response.statusCode}');
      debugPrint('[API][REPORT] responseBody=${response.body}');

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          final report = decoded['ai_report'] ?? decoded['aiReport'] ?? decoded['report'];
          if (report is String) return report;
        }
        throw FormatException('Unexpected report JSON format.');
      }

      throw Exception('Failed to generate AI report: HTTP ${response.statusCode}. Body: ${response.body}');
    } on TimeoutException catch (e) {
      throw Exception('AI Consulting Error: Timeout. $e');
    } on SocketException catch (e) {
      throw Exception('AI Consulting Error: SocketException. $e');
    } catch (e) {
      throw Exception('AI Consulting Error: $e');
    }
  }

  // Download PDF Report endpoint
  Future<Uint8List> downloadReport(PredictionResult result) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.endpointDownloadReport}');
    final payload = result.toJson();

    debugPrint('[API][PDF] POST $uri');
    debugPrint('[API][PDF] requestPayload=$payload');

    try {
      final response = await _client
          .post(
            uri,
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 40));

      debugPrint('[API][PDF] status=${response.statusCode}');
      debugPrint('[API][PDF] responseBytesLength=${response.bodyBytes.length}');

      if (response.statusCode == 200) {
        return response.bodyBytes;
      }

      throw Exception('Failed to download PDF: HTTP ${response.statusCode}. Body: ${response.body}');
    } on TimeoutException catch (e) {
      throw Exception('Download Error: Timeout. $e');
    } on SocketException catch (e) {
      throw Exception('Download Error: SocketException. $e');
    } catch (e) {
      throw Exception('Download Error: $e');
    }
  }
}

