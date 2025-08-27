// ===================== File: lib/pages/question_types/short_answer_page.dart =====================
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/question.dart';
import 'controllers/short_answer_controller.dart';

class ShortAnswerPage extends StatelessWidget {
  final Question question;
  const ShortAnswerPage({super.key, required this.question});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(ShortAnswerController(question), tag: question.id);

    return Scaffold(
      appBar: AppBar(title: const Text('Short Answer'), centerTitle: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 Soru başlığı
              Text(
                question.title,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // 🔹 Açıklama / soru metni
              if ((question.description ?? '').isNotEmpty)
                Text(
                  question.description!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),

              const SizedBox(height: 20),

              // 🔹 Kullanıcı cevabı
              TextField(
                onChanged: (val) => c.answer.value = val,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: "Your Answer",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              // 🔹 Tek seferlik gönder butonu
              Obx(() => FilledButton(
                onPressed: c.isEvaluating.value ? null : () => c.submit(),
                child: c.isEvaluating.value
                    ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Send'),
              )),


              const SizedBox(height: 24),

              // 🔹 AI değerlendirme çıktısı
              Obx(() {
                if (c.aiFeedback.value.isEmpty) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    const Divider(),
                    if (c.aiMeta.value != null) Row(
                      children: [
                        Chip(label: Text(c.aiMeta.value!.correct ? 'Correct' : 'Incorrect')),
                        if (c.aiMeta.value!.score != null) ...[
                          const SizedBox(width: 8),
                          Chip(label: Text('Score: ${c.aiMeta.value!.score}/5')),
                        ],
                      ],
                    ),
                    if (c.aiMeta.value != null) const SizedBox(height: 8),
                    Text(c.aiFeedback.value),
                  ],
                );
              }),

            ],
          ),
        ),
      ),
    );
  }
}
