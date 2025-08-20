import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/question.dart';
import '../../controllers/short_answer_controller.dart';

class ShortAnswerPage extends StatelessWidget {
  final Question question;
  const ShortAnswerPage({super.key, required this.question});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(ShortAnswerController(question), tag: question.id);

    return Scaffold(
      appBar: AppBar(title: const Text('Short Answer'), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: GetX<ShortAnswerController>(
            init: c,
            tag: question.id,
            builder: (c) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  question.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                if ((question.description ?? '').isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(question.description!, style: Theme.of(context).textTheme.bodyMedium),
                ],
                const SizedBox(height: 16),

                // Input + Send
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        enabled: !c.isCorrect.value,
                        controller: TextEditingController(text: c.text.value)
                          ..selection = TextSelection.fromPosition(
                            TextPosition(offset: c.text.value.length),
                          ),
                        onChanged: c.onChanged,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => c.submit(),
                        decoration: InputDecoration(
                          hintText: 'Cevabını yaz...',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: c.isCorrect.value ? null : c.submit,
                      icon: const Icon(Icons.send_outlined, size: 18),
                      label: const Text('Send'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                if (!c.isCorrect.value && c.attemptedWrongOnce.value && !c.revealAnswer.value)
                  Text(
                    'Bir kez daha dene ya da aşağıdaki "Show answer" ile doğru cevabı görebilirsin.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),

                if (!c.isCorrect.value && c.attemptedWrongOnce.value && !c.revealAnswer.value) ...[
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () => c.revealAnswer.value = true,
                    icon: const Icon(Icons.visibility_outlined),
                    label: const Text('Show answer'),
                  ),
                ],

                if (c.revealAnswer.value) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Theme.of(context).colorScheme.surfaceVariant,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Correct Answer', style: TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        Text(question.correctAnswer ?? '—',
                            style: Theme.of(context).textTheme.titleMedium),
                      ],
                    ),
                  ),
                ],

                if (c.isCorrect.value) ...[
                  const SizedBox(height: 16),
                  Material(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => Get.back(),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_outline, size: 28),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Harika! Bu soruyu doğru cevapladın. Bir sonrakine geçmek için dokun.',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios_rounded, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 12),
                Text(
                  'Not: Kontrol harf duyarsızdır; yazım hatasına tolerans yoktur.',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).hintColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
