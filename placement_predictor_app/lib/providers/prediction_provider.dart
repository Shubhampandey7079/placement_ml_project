import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/prediction_request.dart';
import '../models/prediction_result.dart';
import '../models/prediction_history.dart';
import '../services/api_service.dart';

class PredictionProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  static const String _historyKey = "prediction_history";
  
  bool _isLoading = false;
  bool _isGeneratingReport = false;
  bool _isDownloadingPdf = false;
  String? _errorMessage;
  PredictionResult? _currentResult;
  List<PredictionHistoryItem> _history = [];
  bool _isServerHealthy = false;

  bool get isLoading => _isLoading;
  bool get isGeneratingReport => _isGeneratingReport;
  bool get isDownloadingPdf => _isDownloadingPdf;
  String? get errorMessage => _errorMessage;
  PredictionResult? get currentResult => _currentResult;
  List<PredictionHistoryItem> get history => _history;
  bool get isServerHealthy => _isServerHealthy;

  PredictionProvider() {
    _loadHistory();
    checkBackendHealth();
  }

  Future<void> checkBackendHealth() async {
    _isServerHealthy = await _apiService.checkHealth();
    notifyListeners();
  }

  // Clear current result
  void clearCurrentResult() {
    _currentResult = null;
    _errorMessage = null;
    notifyListeners();
  }

  // Make prediction call
  Future<bool> makePrediction(PredictionRequest request) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _apiService.predict(request);
      debugPrint('[PROVIDER][PREDICT] received result prediction=${result.prediction} confidence=${result.confidence}');

      _currentResult = result;

      // Add to history list
      final newItem = PredictionHistoryItem(
        dateTime: DateTime.now(),
        result: result,
      );
      _history.insert(0, newItem);
      await _saveHistory();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceFirst("Exception: ", "");
      debugPrint('[PROVIDER][PREDICT][ERROR] $_errorMessage');
      notifyListeners();
      return false;
    }
  }


  // Generate AI Roadmap Report
  Future<bool> generateAiReport() async {
    if (_currentResult == null) return false;
    
    _isGeneratingReport = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final report = await _apiService.generateReport(_currentResult!);
      _currentResult!.aiReport = report;
      
      // Update history list item as well
      for (var item in _history) {
        if (item.result.prediction == _currentResult!.prediction && 
            item.result.confidence == _currentResult!.confidence &&
            item.result.inputData.toString() == _currentResult!.inputData.toString()) {
          item.result.aiReport = report;
          break;
        }
      }
      await _saveHistory();

      _isGeneratingReport = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isGeneratingReport = false;
      _errorMessage = e.toString().replaceFirst("Exception: ", "");
      notifyListeners();
      return false;
    }
  }

  // Download PDF and Save
  Future<String?> downloadPdfReport() async {
    if (_currentResult == null) return null;

    _isDownloadingPdf = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final Uint8List pdfBytes = await _apiService.downloadReport(_currentResult!);
      
      // Save locally
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = "${directory.path}/Placement_Report_$timestamp.pdf";
      
      final file = File(filePath);
      await file.writeAsBytes(pdfBytes);

      _isDownloadingPdf = false;
      notifyListeners();
      return filePath;
    } catch (e) {
      _isDownloadingPdf = false;
      _errorMessage = e.toString().replaceFirst("Exception: ", "");
      notifyListeners();
      return null;
    }
  }

  // Save prediction history to SharedPreferences
  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedHistory = jsonEncode(
      _history.map((item) => item.toJson()).toList(),
    );
    await prefs.setString(_historyKey, encodedHistory);
  }

  // Load prediction history from SharedPreferences
  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encodedHistory = prefs.getString(_historyKey);
    
    if (encodedHistory != null) {
      final List<dynamic> decodedList = jsonDecode(encodedHistory);
      _history = decodedList
          .map((item) => PredictionHistoryItem.fromJson(Map<String, dynamic>.from(item)))
          .toList();
      notifyListeners();
    }
  }

  // Clear all prediction history
  Future<void> clearHistory() async {
    _history.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
    notifyListeners();
  }

  // Set current prediction result from history (to re-view)
  void setCurrentFromHistory(PredictionResult result) {
    _currentResult = result;
    notifyListeners();
  }

  // Open file helper
  Future<void> openReportFile(String path) async {
    await OpenFilex.open(path);
  }
}
