class Validators {
  static String? validateRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "This field is required";
    }
    return null;
  }

  static String? validateDoubleRange(String? value, double min, double max) {
    final reqCheck = validateRequired(value);
    if (reqCheck != null) return reqCheck;

    final parsed = double.tryParse(value!);
    if (parsed == null) {
      return "Please enter a valid number";
    }
    if (parsed < min || parsed > max) {
      return "Value must be between $min and $max";
    }
    return null;
  }

  static String? validateIntRange(String? value, int min, int max) {
    final reqCheck = validateRequired(value);
    if (reqCheck != null) return reqCheck;

    final parsed = int.tryParse(value!);
    if (parsed == null) {
      return "Please enter a valid integer";
    }
    if (parsed < min || parsed > max) {
      return "Value must be between $min and $max";
    }
    return null;
  }
}
