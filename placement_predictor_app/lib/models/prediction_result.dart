class PredictionResult {
  final String prediction;
  final String confidence;
  final Map<String, dynamic> inputData;
  String? aiReport;

  PredictionResult({
    required this.prediction,
    required this.confidence,
    required this.inputData,
    this.aiReport,
  });

  factory PredictionResult.fromJson(Map<String, dynamic> json) {
    // Be tolerant to backend response variations.
    // ApiService will log raw response body if parsing fails.

    final prediction = (json['prediction'] ?? json['predicted_placement'] ?? json['result']).toString();

    final confidenceRaw = json['confidence'] ?? json['confidence_score'] ?? json['probability'];
    final confidence = confidenceRaw == null ? '' : confidenceRaw.toString();

    final inputRaw = json['input_data'] ?? json['inputs'] ?? json['input'];
    final Map<String, dynamic> inputData =
        inputRaw is Map ? Map<String, dynamic>.from(inputRaw) : <String, dynamic>{};

    final aiReport =
        (json['ai_report'] ?? json['aiReport'] ?? json['report']) as String?;

    return PredictionResult(
      prediction: prediction,
      confidence: confidence,
      inputData: inputData,
      aiReport: aiReport,
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'prediction': prediction,
      'confidence': confidence,
      'input_data': inputData,
      'ai_report': aiReport,
    };
  }
}
