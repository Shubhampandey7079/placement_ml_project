class PredictionRequest {
  final double cgpa;
  final double aptitudeScore;
  final double codingSkills;
  final int internships;
  final int certifications;
  final double communicationSkills;
  final int projects;

  PredictionRequest({
    required this.cgpa,
    required this.aptitudeScore,
    required this.codingSkills,
    required this.internships,
    required this.certifications,
    required this.communicationSkills,
    required this.projects,
  });

  Map<String, dynamic> toJson() {
    // Match backend expectation for payload keys.
    // If backend uses different keys, server will return 400/422 and ApiService logs will show it.
    return {
      'cgpa': cgpa,
      'aptitude_score': aptitudeScore,
      'coding_skills': codingSkills,
      'internships': internships,
      'certifications': certifications,
      'communication_skills': communicationSkills,
      'projects': projects,
    };
  }


  factory PredictionRequest.fromJson(Map<String, dynamic> json) {
    return PredictionRequest(
      cgpa: (json['cgpa'] as num).toDouble(),
      aptitudeScore: (json['aptitude_score'] as num).toDouble(),
      codingSkills: (json['coding_skills'] as num).toDouble(),
      internships: (json['internships'] as num).toInt(),
      certifications: (json['certifications'] as num).toInt(),
      communicationSkills: (json['communication_skills'] as num).toDouble(),
      projects: (json['projects'] as num).toInt(),
    );
  }
}
