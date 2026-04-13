import 'package:flutter/services.dart';

final commaToDotInsertedFormatter = TextInputFormatter.withFunction((oldValue, newValue) {
  if (!newValue.text.contains(',')) return newValue;
  final oldText = oldValue.text;
  final newText = newValue.text;
  var prefix = 0;
  while (prefix < oldText.length &&
      prefix < newText.length &&
      oldText[prefix] == newText[prefix]) {
    prefix++;
  }
  var suffix = 0;
  while (suffix < oldText.length - prefix &&
      suffix < newText.length - prefix &&
      oldText[oldText.length - 1 - suffix] ==
          newText[newText.length - 1 - suffix]) {
    suffix++;
  }
  final insertedEnd = newText.length - suffix;
  if (insertedEnd <= prefix) return newValue;
  final inserted = newText.substring(prefix, insertedEnd);
  if (!inserted.contains(',')) return newValue;
  if (inserted.contains('.')) return newValue;
  final fixed = inserted.replaceAll(',', '.');
  final result =
      newText.substring(0, prefix) + fixed + newText.substring(insertedEnd);
  return TextEditingValue(
    text: result,
    selection: TextSelection.collapsed(offset: prefix + fixed.length),
    composing: TextRange.empty,
  );
});
