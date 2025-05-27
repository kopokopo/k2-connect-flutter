import 'package:flutter/services.dart';

class KenyanPhoneNumberFormatter extends TextInputFormatter {
  static const _grouping = [3, 3, 3];

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), '');

    StringBuffer formatted = StringBuffer();
    int used = 0;

    for (final group in _grouping) {
      final end = (used + group).clamp(0, digitsOnly.length);
      if (used >= digitsOnly.length) break;
      formatted.write(digitsOnly.substring(used, end));
      used = end;
      if (used < digitsOnly.length) formatted.write(' ');
    }

    int nonSpaceBeforeCursor = RegExp(r'\D')
        .allMatches(newValue.text.substring(0, newValue.selection.baseOffset))
        .length;

    int cursorPosition = newValue.selection.baseOffset - nonSpaceBeforeCursor;

    int newCursor =
        _calculateCursorPosition(formatted.toString(), cursorPosition);

    return TextEditingValue(
      text: formatted.toString(),
      selection: TextSelection.collapsed(offset: newCursor),
    );
  }

  int _calculateCursorPosition(String formattedText, int digitIndex) {
    int count = 0;
    int i = 0;

    while (count < digitIndex && i < formattedText.length) {
      if (formattedText[i] != ' ') {
        count++;
      }
      i++;
    }
    return i;
  }
}

String intlPhoneNumber(String phoneNumber) {
  phoneNumber = phoneNumber.replaceAll('+', '');
  return phoneNumber.startsWith('0')
      ? '+254${phoneNumber.replaceRange(0, 1, '')}'
      : phoneNumber;
}
