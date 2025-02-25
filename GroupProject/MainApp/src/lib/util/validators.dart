import 'package:validators/validators.dart';

String validateUsername(String value) {
  if (value.isNotEmpty) return null;
  return 'Please type your hospital ID';
}

String validatePassword(String value) {
  if (value.isEmpty || value.length < 8)
    return 'The password should be at least 8-character long';

  bool hasUpper = false;
  bool hasLower = false;
  bool hasDigit = false;
  bool hasSpecial = false;
  int i = 0;
  while (i < value.length) {
    if (isUppercase(value[i])) hasUpper = true;
    if (isLowercase(value[i])) hasLower = true;
    if (isNumeric(value[i])) hasDigit = true;
    if (!isAlphanumeric(value[i])) hasSpecial = true;
    ++i;
  }

  if (hasUpper && hasLower && hasDigit && hasSpecial) return null;
  return 'The password should contain at least one uppercase letter, ont lowercase letter, one digit and one special character';
}

String validateDate(DateTime date) {
  if (date == null) return "The date is required";
  return null;
}

String intValidator(String number) {
  if (int.tryParse(number) == null)
    return "The input should contain only numbers, for example 12";
  return null;
}

String initialsValidator(String initials) {
  if (initials == null || initials.length == 0)
    return "Please type the patient's initials";
  int i = 0;
  while (i < initials.length) {
    if (!isAlpha(initials[i])) return "Please type only letters";
    ++i;
  }
  return null;
}

String serverValidator(String server) {
  if (server == null || server.isEmpty)
    return "Please type the server address in the form of https://domain.com";
  if (!(server.startsWith("http://") || server.startsWith("https://")))
    return "The server address should start with https:// or http://";
  return null;
}

String tokenValidator(String token) {
  if (token == null || token.isEmpty)
    return "Please type the access token for your hospital";

  return null;
}
