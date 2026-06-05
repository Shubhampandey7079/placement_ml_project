import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../models/prediction_result.dart';

class ResultCard extends StatelessWidget {
  final PredictionResult result;

  const ResultCard({
    Key? key,
    required this.result,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isPlaced = result.prediction.toLowerCase() == "placed";
    final themeColor = isPlaced ? AppColors.success : AppColors.failure;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 4,
      shadowColor: themeColor.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: themeColor.withOpacity(0.5), width: 1.5),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: isDark
              ? LinearGradient(
                  colors: [
                    themeColor.withOpacity(0.1),
                    AppColors.surfaceDark,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : LinearGradient(
                  colors: [
                    themeColor.withOpacity(0.05),
                    Colors.white,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Status Icon Container
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: themeColor.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(color: themeColor.withOpacity(0.3), width: 2),
              ),
              child: Icon(
                isPlaced ? Icons.celebration_rounded : Icons.warning_amber_rounded,
                size: 52,
                color: themeColor,
              ),
            ),
            const SizedBox(height: 16),

            // Prediction Text
            Text(
              isPlaced ? "Congratulations!" : "Keep Working Hard!",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              result.prediction.toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 32,
                color: themeColor,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 20),

            const Divider(height: 1),
            const SizedBox(height: 20),

            // Confidence score section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Confidence Index",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  result.confidence,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: themeColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Confidence progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: double.tryParse(result.confidence.replaceAll('%', '')) != null
                    ? double.parse(result.confidence.replaceAll('%', '')) / 100
                    : 0.5,
                minHeight: 10,
                backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(themeColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
