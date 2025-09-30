// lib/utils/language_mapper.dart
import 'package:highlight/highlight.dart';
import 'package:highlight/languages/java.dart' as java;
import 'package:highlight/languages/cpp.dart' as cpp;
import 'package:highlight/languages/python.dart' as python;
import 'package:highlight/languages/dart.dart' as dart;
import 'package:highlight/languages/plaintext.dart' as plaintext;

Mode mapTopicToMode(String? topic) {
  if (topic == null) return plaintext.plaintext;
  switch (topic.toLowerCase()) {
    case 'java':
      return java.java;
    case 'c':
    case 'c / c++':
    case 'c++':
      return cpp.cpp;
    case 'python':
      return python.python;
    case 'dart':
      return dart.dart;
    default:
      return plaintext.plaintext;
  }
}
