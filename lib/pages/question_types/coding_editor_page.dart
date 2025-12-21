import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'package:get/get.dart';
import '../../models/question.dart';
import '../runner/controller/question_runner_controller.dart';
import 'controllers/coding_controller.dart';
import 'package:flutter_highlight/themes/github.dart';

class CodingEditorPage extends StatelessWidget {
  final Question question;

  CodingEditorPage({super.key, required this.question});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<CodingController>(tag: question.id);

    return WillPopScope(
      onWillPop: () async {
        final rc = Get.find<QuestionRunnerController>();
        rc.closeEditor(); // flush + canSubmit
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false, // geri oku kapat
          centerTitle: false,
          title: Text(question.title ?? 'Coding Editor'),
          actions: [
            IconButton(
              tooltip: 'Return to question',
              icon: const Icon(Icons.code),
              onPressed: Get.back, // soruya dön
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    // Kart arka planı editor hissi versin
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface, // açık tema
                      borderRadius: BorderRadius.circular(12),
                    ),
                    // CodeField'i dikeyde genişlet, yatay kaymayı azalt
                    child: Builder(
                      builder: (context) {
                        final isDark =
                            Theme.of(context).brightness == Brightness.dark;
                        final styles = isDark ? atomOneDarkTheme : githubTheme;
                        return CodeTheme(
                          data: CodeThemeData(styles: styles),
                          child: CodeField(
                            controller: c.codeController,
                            textStyle: const TextStyle(
                                fontFamily: 'monospace', fontSize: 14),
                            expands: true,
                            minLines: null,
                            maxLines: null,
                            lineNumberStyle: const LineNumberStyle(
                              width: 40,
                              textAlign: TextAlign.right,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
