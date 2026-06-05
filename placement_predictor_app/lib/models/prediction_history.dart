import 'prediction_result.dart';

class PredictionHistoryItem {
  final DateTime dateTime;
  final PredictionResult result;

  PredictionHistoryItem({
    required this.dateTime,
    required this.result,
  });

  factory PredictionHistoryItem.fromJson(Map<String, dynamic> json) {
    return PredictionHistoryItem(
      dateTime: DateTime.parse(json['date_time'] as String),
      result: PredictionResult.fromJson(Map<String, dynamic>.from(json['result'] as Map)),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date_time': dateTime.toIso8601String(),
      'result': result.toJson(),
    };
  }
}
