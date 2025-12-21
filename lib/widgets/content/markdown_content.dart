// lib/widgets/content/markdown_content.dart
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart' as mdw;
import 'package:markdown/markdown.dart' as md;
import 'code_block.dart';

class MarkdownContent extends StatelessWidget {
  final String data;
  final EdgeInsets padding;
  final String? fallbackLanguage;

  /// Fenced code (``` ... ```) yoksa ve metin "kod gibi" görünüyorsa
  /// otomatik CodeBlock'a çevir.
  final bool autoFenceCode;

  /// Otomatik kod modunda, hiç satır sonu yoksa bazı akıllı satır kırma ipuçları.
  final bool smartCodeBreaks;

  const MarkdownContent({
    super.key,
    required this.data,
    this.padding = EdgeInsets.zero,
    this.fallbackLanguage,
    this.autoFenceCode = false,
    this.smartCodeBreaks = true,
  });

  @override
  Widget build(BuildContext context) {
    // 1) Eğer fenced code zaten varsa normal markdown çizelim.
    final hasFence = data.contains('```');

    // 2) Basit "kod gibi" sezgisi: ; { } veya tipik anahtar kelimelerden biri
    final looksLikeCode = !hasFence &&
        RegExp(r'[;{}()]|\b(class|int|float|double|void|return|#include|printf|public|static)\b')
            .hasMatch(data);

    if (autoFenceCode && looksLikeCode) {
      var code = data.trim();

      // Satır hiç yoksa biraz okunaklı kır (printf içindeki \n'e dokunmuyoruz)
      if (smartCodeBreaks && !code.contains('\n')) {
        code = code
            .replaceAll('; ', ';\n')
            .replaceAll(';', ';\n')
            .replaceAll('{', '{\n')
            .replaceAll('} ', '\n}\n')
            .replaceAll('}', '\n}')
            .replaceAll(RegExp(r'\breturn\b'), '\nreturn');
      }

      return Padding(
        padding: padding,
        child: CodeBlock(
          code: code,
          language: fallbackLanguage, // yoksa auto-detect devrede
        ),
      );
    }

    // Normal markdown (fenced code varsa _PreCodeBlockBuilder zaten CodeBlock'a çeviriyor)
    return Padding(
      padding: padding,
      child: mdw.MarkdownBody(
        data: data,
        selectable: true,
        extensionSet: md.ExtensionSet.gitHubFlavored,
        styleSheet: mdw.MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
          code: const TextStyle(fontFamily: 'monospace'),
          codeblockDecoration: const BoxDecoration(), // kendi CodeBlock'umuzu kullanıyoruz
        ),
        builders: {
          'pre': _PreCodeBlockBuilder(fallbackLanguage: fallbackLanguage),
        },
      ),
    );
  }
}

/// Fenced codeblock'ları CodeBlock widgets’ına dönüştürür.
/// ```c ... ``` gibi bir fence varsa element.class = 'language-c' gelir.
/// Fenced codeblock'ları (pre > code) CodeBlock'a çevirir.
class _PreCodeBlockBuilder extends mdw.MarkdownElementBuilder {
  final String? fallbackLanguage;
  _PreCodeBlockBuilder({this.fallbackLanguage});

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    if (element.tag != 'pre') return null;

    // pre içine gömülü <code> öğesini bul
    md.Element? codeElem;
    for (final child in element.children ?? const <md.Node>[]) {
      if (child is md.Element && child.tag == 'code') {
        codeElem = child;
        break;
      }
    }

    final codeText = codeElem?.textContent ?? element.textContent;
    final langClass = codeElem?.attributes['class'];        // 'language-c' gibi
    String? lang = langClass?.replaceFirst('language-', '');
    lang ??= fallbackLanguage;

    return CodeBlock(code: codeText, language: lang);
  }
}

