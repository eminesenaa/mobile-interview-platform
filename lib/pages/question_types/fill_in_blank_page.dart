import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../models/question.dart';
import '../../../controllers/fill_blank_controller.dart';

class FillInBlankPage extends StatelessWidget {
  final Question question;
  const FillInBlankPage({super.key, required this.question});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(FillBlankController(question), tag: question.id); // tag ile güvence

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fill in the Blank'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(                       // <- overflow fix
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: GetX<FillBlankController>(                 // <- Obx yerine GetX
            init: c,
            tag: question.id,
            builder: (c) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Başlık & açıklama
                Text(
                  question.title,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                if ((question.description ?? '').isNotEmpty &&
                    question.description != question.title) ...[
                  const SizedBox(height: 8),
                  Text(question.description!,
                      style: Theme.of(context).textTheme.bodyMedium),
                ],
                const SizedBox(height: 12),

                // Soru metni: left + [BLANK] + right
                Wrap(
                  alignment: WrapAlignment.start,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  runSpacing: 8,
                  children: [
                    Text(c.left.value,
                        style: Theme.of(context).textTheme.titleMedium),
                    _BlankSlot(
                      value: c.filled.value,
                      onTap: c.pickFromBottomSheet,
                      onAccept: (w) => c.place(w),
                    ),
                    Text(c.right.value,
                        style: Theme.of(context).textTheme.titleMedium),
                  ],
                ),

                const SizedBox(height: 16),

                // Choices
                _ChoicesBoard(
                  choices: c.choices,                // RxList okuma => GetX tetiklenir
                  onTapChoice: (w) => c.place(w),
                ),

                const SizedBox(height: 12),

                // Aksiyonlar
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: c.check,
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Check'),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: c.reset,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reset'),
                    ),
                    const Spacer(),
                    if (c.attemptedWrongOnce.value &&
                        !c.isCorrect.value &&
                        !c.showAnswer.value)
                      TextButton.icon(
                        onPressed: () => c.showAnswer.value = true,
                        icon: const Icon(Icons.visibility_outlined),
                        label: const Text('Show answer'),
                      ),
                  ],
                ),

                if (c.showAnswer.value) ...[
                  const SizedBox(height: 10),
                  _AnswersReveal(
                      answers: [question.correctAnswer ?? '—']),
                ],

                if (c.isCorrect.value) ...[
                  const SizedBox(height: 16),
                  _SuccessCard(onNext: () => Get.back()),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}


// --- UI parçaları (stateless, sadece callback + değer alır) ---

class _BlankSlot extends StatelessWidget {
  final String? value;
  final VoidCallback onTap;
  final void Function(String) onAccept;

  const _BlankSlot({
    required this.value,
    required this.onTap,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    final child = GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: value == null
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.secondary,
            width: 1.6,
          ),
          color: value == null
              ? Theme.of(context).colorScheme.primary.withOpacity(.06)
              : Theme.of(context).colorScheme.secondaryContainer.withOpacity(.6),
        ),
        child: Text(
          value ?? '____',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    );

    return DragTarget<String>(
      builder: (_, __, ___) => child,
      onAccept: onAccept,
    );
  }
}

class _ChoicesBoard extends StatelessWidget {
  final List<String> choices;
  final void Function(String) onTapChoice;

  const _ChoicesBoard({
    required this.choices,
    required this.onTapChoice,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 10,
      children: choices.map((w) {
        return LongPressDraggable<String>(
          data: w,
          feedback: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(999),
            child: _ChoiceChip(word: w, elevated: true),
          ),
          childWhenDragging: Opacity(opacity: 0.4, child: _ChoiceChip(word: w)),
          child: InkWell(
            onTap: () => onTapChoice(w),
            borderRadius: BorderRadius.circular(999),
            child: _ChoiceChip(word: w),
          ),
        );
      }).toList(),
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  final String word;
  final bool elevated;
  const _ChoiceChip({required this.word, this.elevated = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Theme.of(context).colorScheme.surfaceVariant,
        boxShadow: elevated
            ? [BoxShadow(blurRadius: 6, spreadRadius: 1, offset: const Offset(0, 2), color: Colors.black12)]
            : null,
      ),
      child: Text(
        word,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _AnswersReveal extends StatelessWidget {
  final List<String> answers;
  const _AnswersReveal({required this.answers});

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: answers.map((a) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: Theme.of(context).colorScheme.primary.withOpacity(.1),
                ),
                child: Text(
                  a,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _SuccessCard extends StatelessWidget {
  final VoidCallback onNext;
  const _SuccessCard({required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.secondaryContainer,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onNext,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              const Icon(Icons.check_circle_outline, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Harika! Boşluğu doğru doldurdun. Bir sonrakine geçmek için dokun.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
