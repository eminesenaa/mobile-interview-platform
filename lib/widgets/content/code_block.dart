// lib/widgets/content/code_block.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:highlight/highlight_core.dart' show highlight;
import 'package:highlight/highlight.dart' as hi;

//import 'package:highlight/languages/c.dart' as lang_c;
import 'package:highlight/languages/cpp.dart' as lang_cpp;
import 'package:highlight/languages/java.dart' as lang_java;
import 'package:highlight/languages/python.dart' as lang_py;
import 'package:highlight/languages/dart.dart' as lang_dart;

import '../../constants/colors.dart';
import 'code_themes.dart';


class CodeBlock extends StatelessWidget {
  final String code;
  final String? language;         // 'c', 'cpp', 'java', 'dart', 'python'...
  final bool showCopy;
  final bool showLineNumbers;
  final List<int>? highlightLines;
  final Color? backgroundColor;
  final double? fontSize;
  final bool showLanguageBadge;

  const CodeBlock({
    super.key,
    required this.code,
    this.language,
    this.showCopy = true,
    this.showLineNumbers = false,
    this.highlightLines,
    this.backgroundColor,
    this.fontSize,
    this.showLanguageBadge = false,
  });

  static bool _registered = false;
  static void _ensureLanguages() {
    if (_registered) return;

    //highlight.registerLanguage('c',     lang_c.c);
    highlight.registerLanguage('cpp',   lang_cpp.cpp);
    highlight.registerLanguage('java',  lang_java.java);
    highlight.registerLanguage('python',lang_py.python);
    highlight.registerLanguage('dart',  lang_dart.dart);

    _registered = true;
  }

  @override
  Widget build(BuildContext context) {
    _ensureLanguages();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Temanın fontunu burada büyütüyoruz
    final baseTheme = isDark ? githubDarkTheme : githubLightTheme;
    final fs = fontSize ?? 16; // 👈 14 yerine 16 (istersen 17–18 yap)
    final theme = {
      ...baseTheme,
      'root': (baseTheme['root'] ?? const TextStyle(fontFamily: 'monospace'))
          .copyWith(fontSize: fs),
    };
     final baseTextStyle = TextStyle(
       fontFamily: 'monospace',
       fontSize: fs,        // örn. 20
       height: 1.5,
    );

    final lang = (language == 'c') ? 'cpp' : language; // geçici eşleme
    final parsed = highlight.parse(
      code,
      language: lang ?? 'plaintext',
      autoDetection: language == null,
    );

    final spans = <InlineSpan>[];
    final List<hi.Node> nodes = (parsed.nodes ?? const []).cast<hi.Node>();
    for (final hi.Node node in nodes) {
      spans.add(_spanFor(node, theme));
    }

    Widget codeText = SelectableText.rich(
      TextSpan(style: baseTextStyle, children: spans),
    );

    if (showLineNumbers) {
      final lines = code.split('\n');
      final ln = List.generate(lines.length, (i) => '${i + 1}').join('\n');
      codeText = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ln,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontFamily: 'monospace',
              color: Colors.grey,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: SelectableText.rich(TextSpan(style: baseTextStyle, children: spans))),
        ],
      );
    }

    final bg = backgroundColor ??
        (isDark ? const Color(0xFF101417) : secondaryColor.withValues(alpha: 0.25));
    final border = isDark ? const Color(0xFF2A2E35) : secondaryColor.withValues(alpha: 0.25);

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),      // 👈 kenarlık yumuşak
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header bar
          // Container(
          //   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          //   decoration: BoxDecoration(
          //     border: Border(
          //       bottom: BorderSide(
          //         color: isDark ? const Color(0xFF2A2E35) : const Color(0xFFE2E6EA),
          //       ),
          //     ),
          //   ),
          //   child: Row(
          //     children: [
          //       if (language != null && language!.isNotEmpty)
          //         Container(
          //           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          //           decoration: BoxDecoration(
          //             color: isDark ? const Color(0xFF1b1f24) : Colors.white,
          //             borderRadius: BorderRadius.circular(8),
          //             border: Border.all(color: isDark ? const Color(0xFF2A2E35) : const Color(0xFFE2E6EA)),
          //           ),
          //           child: Text(language!.toUpperCase(),
          //               style: TextStyle(
          //                 fontSize: 12,
          //                 color: isDark ? Colors.white70 : Colors.black87,
          //                 letterSpacing: 0.5,
          //               )),
          //         ),
          //       const Spacer(),
          //       if (showCopy)
          //         IconButton(
          //           tooltip: 'Copy',
          //           icon: const Icon(Icons.copy_rounded, size: 18),
          //           onPressed: () {
          //             Clipboard.setData(ClipboardData(text: code));
          //             ScaffoldMessenger.of(context).showSnackBar(
          //               const SnackBar(content: Text('Code copied')),
          //             );
          //           },
          //         ),
          //     ],
          //   ),
          // ),
          // Code area (horizontal scroll)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: codeText,
          ),
        ],
      ),
    );
  }

   TextSpan _spanFor(hi.Node node, Map<String, TextStyle> theme) {
       // metin düğümü ise direkt yaz
       if (node.value != null) {
         return TextSpan(text: node.value);
       }
       // stil: sınıf adı yoksa 'root'
       final TextStyle? style = theme[node.className ?? 'root'];
       final List<hi.Node> children =
           (node.children ?? const []).cast<hi.Node>();
       return TextSpan(
         style: style,
         children: children
             .map<InlineSpan>((n) => _spanFor(n, theme))
             .toList(growable: false),
       );
     }

}
