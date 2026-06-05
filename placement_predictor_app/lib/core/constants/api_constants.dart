class ApiConstants {
  static const String baseUrl = "https://placement-ml-project.onrender.com";

  // Render backend routes
  // Health endpoint tested: /api/health returns 404 from Render.
  // This app will attempt both /api/* and non-namespaced routes.
  static const String endpointPredict = "/predict";
  static const String endpointGenerateReport = "/generate-report";
  static const String endpointDownloadReport = "/download_report";
  static const String endpointHealth = "/api/health";
}


