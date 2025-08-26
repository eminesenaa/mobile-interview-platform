// ===================== File: lib/pages/question_types/short_answer_page.dart =====================
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/question.dart';
import '../../../controllers/short_answer_controller.dart';

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
              Obx(() => ElevatedButton(
                    onPressed: c.answer.value.trim().isEmpty
                        ? null
                        : () => c.submitAnswerWithAI(),
                    child: const Text("Send"),
                  )),

              const SizedBox(height: 24),

              // 🔹 AI değerlendirme çıktısı
              Obx(() {
                if (c.aiResult.value.isEmpty) {
                  return const SizedBox.shrink();
                }
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    c.aiResult.value,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
