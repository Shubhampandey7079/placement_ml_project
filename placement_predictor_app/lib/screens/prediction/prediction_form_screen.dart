import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_strings.dart';
import '../../models/prediction_request.dart';
import '../../providers/prediction_provider.dart';
import '../../widgets/skill_slider.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/loading_overlay.dart';
import '../../core/utils/helpers.dart';

class PredictionFormScreen extends StatefulWidget {
  const PredictionFormScreen({Key? key}) : super(key: key);

  @override
  State<PredictionFormScreen> createState() => _PredictionFormScreenState();
}

class _PredictionFormScreenState extends State<PredictionFormScreen> {
  // Slider states
  double _cgpa = 7.5;
  double _aptitudeScore = 70.0;
  double _codingSkills = 7.0;
  double _internships = 1.0;
  double _certifications = 2.0;
  double _communicationSkills = 75.0;
  double _projects = 2.0;

  void _submitForm() async {
    final provider = Provider.of<PredictionProvider>(context, listen: false);
    
    final request = PredictionRequest(
      cgpa: _cgpa,
      aptitudeScore: _aptitudeScore,
      codingSkills: _codingSkills,
      internships: _internships.round(),
      certifications: _certifications.round(),
      communicationSkills: _communicationSkills,
      projects: _projects.round(),
    );

    final success = await provider.makePrediction(request);
    if (success) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppStrings.routeResult);
      }
    } else {
      if (mounted) {
        Helpers.showSnackBar(context, provider.errorMessage ?? "An error occurred", isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final predictionProvider = Provider.of<PredictionProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return LoadingOverlay(
      isLoading: predictionProvider.isLoading,
      message: "Analyzing profile data...",
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Placement Predictor",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Form explanation
                Text(
                  "Adjust the sliders to capture your academic, technical, and extracurricular metrics.",
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),

                // Group 1: Academic & Cognitive
                _buildSectionHeader("Academic & Cognitive Profile"),
                Card(
                  margin: const EdgeInsets.only(bottom: 24),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        SkillSlider(
                          label: "Cumulative CGPA",
                          value: _cgpa,
                          min: 0.0,
                          max: 10.0,
                          divisions: 100,
                          onChanged: (val) => setState(() => _cgpa = val),
                        ),
                        SkillSlider(
                          label: "Quantitative Aptitude Score",
                          value: _aptitudeScore,
                          min: 0.0,
                          max: 100.0,
                          divisions: 100,
                          onChanged: (val) => setState(() => _aptitudeScore = val),
                          suffix: "%",
                        ),
                      ],
                    ),
                  ),
                ),

                // Group 2: Technical Competence
                _buildSectionHeader("Technical Competence"),
                Card(
                  margin: const EdgeInsets.only(bottom: 24),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        SkillSlider(
                          label: "Coding Skills Level",
                          value: _codingSkills,
                          min: 0.0,
                          max: 10.0,
                          divisions: 20,
                          onChanged: (val) => setState(() => _codingSkills = val),
                        ),
                        SkillSlider(
                          label: "Significant Projects Count",
                          value: _projects,
                          min: 0.0,
                          max: 10.0,
                          divisions: 10,
                          onChanged: (val) => setState(() => _projects = val),
                        ),
                      ],
                    ),
                  ),
                ),

                // Group 3: Practical & Soft Skills
                _buildSectionHeader("Practical & Soft Skills"),
                Card(
                  margin: const EdgeInsets.only(bottom: 30),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        SkillSlider(
                          label: "Completed Internships",
                          value: _internships,
                          min: 0.0,
                          max: 5.0,
                          divisions: 5,
                          onChanged: (val) => setState(() => _internships = val),
                        ),
                        SkillSlider(
                          label: "Professional Certifications",
                          value: _certifications,
                          min: 0.0,
                          max: 10.0,
                          divisions: 10,
                          onChanged: (val) => setState(() => _certifications = val),
                        ),
                        SkillSlider(
                          label: "Communication Skills Level",
                          value: _communicationSkills,
                          min: 0.0,
                          max: 100.0,
                          divisions: 100,
                          onChanged: (val) => setState(() => _communicationSkills = val),
                          suffix: "%",
                        ),
                      ],
                    ),
                  ),
                ),

                // Submit Button
                GradientButton(
                  onPressed: _submitForm,
                  text: "Predict Placement Status",
                  icon: const Icon(Icons.analytics_rounded, color: Colors.white),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
