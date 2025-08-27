import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/question.dart';
import 'controllers/fill_blank_controller.dart';

class FillInBlankPage extends StatelessWidget {
  final Question question;
  const FillInBlankPage({super.key, required this.question});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(FillBlankController(question), tag: question.id);

    // 🔹 Soru metnini parçala: ___ olan yerlere boşluk koy
    final parts = question.description?.split("___") ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text('Fill in the Blank'), centerTitle: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Başlık
                Text(
                  question.title,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                // 🔹 Metin içinde boşluklar
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: List.generate(parts.length * 2 - 1, (i) {
                    if (i.isEven) {
                      return Text(parts[i ~/ 2]);
                    } else {
                      final blankIndex = i ~/ 2;
                      return SizedBox(
                        width: 120,
                        child: TextField(
                          onChanged: (val) => c.updateAnswer(blankIndex, val),
                          decoration: const InputDecoration(
                            border: UnderlineInputBorder(),
                            hintText: "...",
                          ),
                        ),
                      );
                    }
                  }),
                ),

                const SizedBox(height: 20),

                // 🔹 Tek seferlik gönderme
                Obx(() => ElevatedButton(
                      onPressed: c.answers.isEmpty
                          ? null
                          : () => c.submitAnswersWithAI(),
                      child: const Text("Send"),
                    )),

                const SizedBox(height: 24),

                // 🔹 AI değerlendirme sonucu
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
      ),
    );
  }
}
