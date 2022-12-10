class Validator {
  Validator._();

  static String? Function(String?) notEmpty(
      String? Function(String?)? validator) {
    return (value) {
      if (value == null || value.isEmpty) {
        return 'จำเป็น';
      }
      if (validator != null) {
        return validator(value);
      }
      return null;
    };
  }

  static bool isDigits(String value) {
    return RegExp(r'^[0-9]+$').hasMatch(value);
  }

  static bool isNumber(String value) {
    return RegExp(r'(^\d*\.?\d*)').hasMatch(value);
  }
}
