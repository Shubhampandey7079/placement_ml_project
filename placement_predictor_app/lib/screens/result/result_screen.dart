import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/prediction_provider.dart';
import '../../widgets/result_card.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/loading_overlay.dart';
import '../../core/utils/helpers.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final predictionProvider = Provider.of<PredictionProvider>(context);
    final result = predictionProvider.currentResult;

    if (result == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Results")),
        body: const Center(child: Text("No prediction results available")),
      );
    }

    return LoadingOverlay(
      isLoading: predictionProvider.isGeneratingReport || predictionProvider.isDownloadingPdf,
      message: predictionProvider.isGeneratingReport
          ? "Consulting career AI model..."
          : "Compiling and downloading PDF report...",
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Career Diagnostics"),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Celebration / Status badge card
                ResultCard(result: result),
                const SizedBox(height: 24),

                // Grid of Input Metrics
                const Text(
                  "Metric Summary",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                _buildMetricsGrid(result.inputData, context),
                const SizedBox(height: 28),

                // AI Roadmap Section
                const Text(
                  "AI Career Mentorship & Roadmap",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                _buildAiRoadmapSection(predictionProvider, context),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricsGrid(Map<String, dynamic> inputs, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.2,
      ),
      itemCount: inputs.length,
      itemBuilder: (context, index) {
        final key = inputs.keys.elementAt(index);
        final value = inputs[key];
        final formattedName = Helpers.formatFeatureName(key);
        
        // Suffix resolution
        String suffix = "";
        if (key.contains("score") || key.contains("skills")) suffix = "%";
        if (key.contains("cgpa")) suffix = "/10";

        return Card(
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  formattedName,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  "$value$suffix",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAiRoadmapSection(PredictionProvider provider, BuildContext context) {
    final result = provider.currentResult!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (result.aiReport == null) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Icon(
                Icons.psychology_rounded,
                size: 48,
                color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
              ),
              const SizedBox(height: 12),
              const Text(
                "AI Recommendations & Custom Roadmap",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 8),
              Text(
                "Generate a detailed, step-by-step career readiness roadmap using LLaMA AI metrics analysis.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.auto_awesome),
                label: const Text("Generate Roadmap"),
                onPressed: () async {
                  final success = await provider.generateAiReport();
                  if (!success) {
                    Helpers.showSnackBar(
                      context,
                      provider.errorMessage ?? "Failed to consult career AI",
                      isError: true,
                    );
                  }
                },
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // The Report text panel
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_awesome, color: Colors.amber, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      "AI Mentor Insights",
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: isDark ? AppColors.accentDark : AppColors.primaryLight,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Formatted/Readable AI report content
                _buildReportContent(result.aiReport!),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Actions Row: PDF Download button
        GradientButton(
          text: "Download PDF Roadmap Report",
          icon: const Icon(Icons.picture_as_pdf_rounded, color: Colors.white),
          onPressed: () async {
            final filePath = await provider.downloadPdfReport();
            if (filePath != null) {
              Helpers.showSnackBar(
                context,
                "Report downloaded successfully to storage.",
              );
              // Open file trigger
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text("Report Ready"),
                  content: const Text("Would you like to open the PDF report now?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text("Later"),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        provider.openReportFile(filePath);
                      },
                      child: const Text("Open PDF"),
                    ),
                  ],
                ),
              );
            } else {
              Helpers.showSnackBar(
                context,
                provider.errorMessage ?? "Failed to download PDF",
                isError: true,
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildReportContent(String reportText) {
    // Process markdown to double-newline paragraphs and lists
    final lines = reportText.split('\n');
    final widgets = <Widget>[];

    for (var line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;

      // Bold text handling **text** -> bold
      bool isHeading = trimmed.startsWith("###") || trimmed.startsWith("==") || trimmed.startsWith("#");
      bool isBullet = trimmed.startsWith("-") || trimmed.startsWith("*") || trimmed.startsWith("•");

      var displayText = trimmed;
      if (isBullet) {
        displayText = trimmed.substring(1).trim();
      }
      displayText = displayText.replaceAll("**", ""); // Simple clean representation

      widgets.add(
        Padding(
          padding: EdgeInsets.only(
            bottom: isHeading ? 12.0 : 6.0,
            top: isHeading ? 14.0 : 0.0,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isBullet) ...[
                const Padding(
                  padding: EdgeInsets.only(top: 6.0, right: 8.0),
                  child: Icon(Icons.brightness_1, size: 6, color: AppColors.primaryLight),
                ),
              ],
              Expanded(
                child: Text(
                  displayText,
                  style: TextStyle(
                    fontSize: isHeading ? 15 : 13.5,
                    fontWeight: isHeading ? FontWeight.bold : FontWeight.normal,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }
}
