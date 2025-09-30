// lib/utils/code_template_sanitizer.dart
import 'dart:convert';

class CodeTemplateSanitizer {
  /// Firebase'den gelen ham şablonu editörde okunur hale getirir.
  /// - \r\n / \r / \n normalizasyonu
  /// - literal '\\n' -> '\n' dönüşümü
  /// - HTML <br> -> '\n', &nbsp; -> ' '
  /// - Markdown code fence'leri (```lang ... ```) temizleme
  /// - Zero-width/garip whitespace temizliği
  /// - Süslüden sonra/before satır kırma
  /// - Basit girintileme
  static String sanitize(String raw) {
    if (raw.isEmpty) return raw;

    var s = raw;

    // 1) HTML kırıntıları (çok sık rastlanır)
    s = s
        .replaceAll('<br>', '\n')
        .replaceAll('<br/>', '\n')
        .replaceAll('<br />', '\n')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&amp;', '&');

    // 2) Satır sonlarını normalize et
    s = s.replaceAll('\r\n', '\n').replaceAll('\r', '\n');

    // 3) Literal kaçışları düzelt (örn. “void f(){\n //TODO }” tek satır gelmişse)
    //    -> önce JSON decode deneyelim; başarısızsa regex fallback
    try {
      // Örn: "\"void f(){\\n //TODO\\n}\"" gibi gelirse
      final decoded = json.decode('"${s.replaceAll(r'\', r'\\')}"');
      if (decoded is String) s = decoded;
    } catch (_) {
      s = s.replaceAll(r'\n', '\n').replaceAll(r'\t', '\t');
    }

    // 4) Markdown code fences kaldır
    // ```lang\n ... \n```
    final fenceRegex = RegExp(r'^```[a-zA-Z0-9_+-]*\n([\s\S]*?)\n```$');
    final m = fenceRegex.firstMatch(s.trim());
    if (m != null) {
      s = m.group(1) ?? s;
    }

    // 5) Zero-width vs.
    s = s.replaceAll(RegExp(r'[\u200B-\u200D\uFEFF]'), '');

    // 6) Eğer tek satıra toplanmışsa süslüler etrafında satır kır
    //    “) { //TODO }” gibi
    s = s
        .replaceAll(RegExp(r'\)\s*\{'), '){\n')
        .replaceAll(RegExp(r';\s*'), ';\n')
        .replaceAll(RegExp(r'\}\s*else'), '}\nelse')
        .replaceAll(RegExp(r'\}\s*catch'), '}\ncatch')
        .replaceAll(RegExp(r'\}\s*finally'), '}\nfinally');

    // Açılan süslüden sonra ve kapanandan önce en az bir newline olsun
    s = s
        .replaceAllMapped(RegExp(r'\{(?!\s*\n)'), (m) => '{\n')
        .replaceAllMapped(RegExp(r'(?<!\n\s*)\}'), (m) => '\n}');

    // 7) Trim + basit girintileme
    s = _simpleIndent(s.trim());

    return s;
  }

  /// Çok basit bir girintileme: '{' gördüğünde artırır, '}' gördüğünde azaltır.
  static String _simpleIndent(String code) {
    final lines = code.split('\n');
    final buf = StringBuffer();
    int level = 0;

    for (var rawLine in lines) {
      var line = rawLine.trimRight();

      // kapanan süslü ile başlıyorsa önce azalt
      if (line.trimLeft().startsWith('}')) {
        level = (level - 1).clamp(0, 1000);
      }

      // girinti uygula (4 boşluk; istersen 2 yap)
      buf.write('${' ' * (level * 4)}$line');

      // satır sonu
      buf.writeln();

      // satır içinde açılan/kapanan süslü sayısına göre level ayarla
      final opens = RegExp(r'\{').allMatches(line).length;
      final closes = RegExp(r'\}').allMatches(line).length;
      level = (level + opens - closes).clamp(0, 1000);
    }

    return buf.toString().trimRight();
  }
}
