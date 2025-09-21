// ===================== File: lib/pages/question_types/widgets/coding_question_view.dart =====================
// Purpose: Coding sorusunun ilk ekranı (yalın): problem metni + editor açma ikonu.
//          - AppBar başlığı QuestionRunnerPage’den geliyor.
//          - Submit, editor gelene kadar disabled (valid=false).
// ===========================================================================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:interview_project/models/question.dart';
import 'package:interview_project/pages/question_types/controllers/coding_controller.dart';

class CodingQuestionView extends StatefulWidget {
  final Question question;
  final bool locked;
  final void Function(Map<String, dynamic> payload, bool valid) onChanged;
  final VoidCallback onOpenEditor; // Runner bu callback’te editor ekranını açacak

  const CodingQuestionView({
    super.key,
    required this.question,
    required this.locked,
    required this.onChanged,
    required this.onOpenEditor,
  });

  @override
  State<CodingQuestionView> createState() => _CodingQuestionViewState();
}

class _CodingQuestionViewState extends State<CodingQuestionView> {
  late final CodingController c;

  @override
  void initState() {
    super.initState();
    c = Get.put(
      CodingController(
        question: widget.question,
        onChanged: widget.onChanged,
      ),
      tag: widget.question.id,
      permanent: false,
    );
  }

  @override
  void dispose() {
    Get.delete<CodingController>(tag: widget.question.id, force: true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: widget.locked,
      child: Scrollbar(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Üst satır: küçük başlık + editör açma ikonu
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      widget.question.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Tooltip(
                    message: widget.locked ? 'Locked' : 'Open editor',
                    child: IconButton(
                      onPressed: widget.locked ? null : widget.onOpenEditor,
                      icon: const Icon(Icons.code_rounded),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Soru metni (description)
              Text(
                (widget.question.description ?? '').trim().isNotEmpty
                    ? widget.question.description!.trim()
                    : 'No description provided.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),

              const SizedBox(height: 16),

              // (Opsiyonel) küçük meta satırı: sadece modelde varsa göster
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (widget.question.topic != null &&
                      widget.question.topic!.trim().isNotEmpty)
                    _Chip(text: widget.question.topic!),
                  if ((widget.question.tags ?? []).isNotEmpty)
                    ...widget.question.tags!.map((t) => _Chip(text: t)),
                ],
              ),

              if (widget.locked) ...[
                const SizedBox(height: 16),
                _LockedBanner(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  const _Chip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text, style: Theme.of(context).textTheme.labelMedium),
    );
  }
}

class _LockedBanner extends StatelessWidget {
  const _LockedBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(.35),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.lock_rounded),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'This question is locked. You can view the content but cannot edit.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
