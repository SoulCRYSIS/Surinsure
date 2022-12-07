class Validator {
  Validator._();

  static String? noneEmpty(String? value) {
    if (value == null || value.isEmpty) {
      return 'จำเป็น';
    }
    return null;
  }

  static bool isNumber(String value) {
    return RegExp(r'^[0-9]+$').hasMatch(value);
  }
}
