// ===================== File: lib/pages/practice/training_module_detail_page.dart =====================

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:interview_project/constants/colors.dart';
import 'package:interview_project/constants/constants.dart';
import 'package:interview_project/constants/text_styles.dart';

import 'package:interview_project/models/question.dart';
import 'package:interview_project/models/training_module.dart';
import 'package:interview_project/models/training_section.dart';
import 'package:interview_project/models/training_module_question_ref.dart';

import 'package:interview_project/pages/practice/controllers/practice_controller.dart';
import 'package:interview_project/pages/practice/widgets/training_module_card.dart';
import 'package:interview_project/pages/practice/widgets/training_section_card.dart';

import '../runner/question_feed.dart';
import '../runner/question_runner_page.dart';

class TrainingModuleDetailPage extends StatelessWidget {
  final TrainingModule module;

  /// Opsiyonel: Bu module’e ait section listesi.
  /// Şimdilik null gelirse boş liste varsayılır; backend bağlanınca controller’dan beslenecek.
  final List<TrainingSection>? sections;

  /// Opsiyonel: Section + Question eşleşmeleri.
  /// Hangi questionId’nin hangi section’da, hangi sırada olduğunu bilir.
  final List<TrainingModuleQuestionRef>? questionRefs;

  /// (Optional) user specific progress for this module.
  /// If null, UI will show 0 / total.
  final int? completedCount;

  const TrainingModuleDetailPage({
    super.key,
    required this.module,
    this.sections,
    this.questionRefs,
    this.completedCount,
  });

  @override
  Widget build(BuildContext context) {
    final practiceController = Get.find<PracticeController>();
    // Module level progress – backend bağlanınca gerçek değer gelecek.
    final int totalQuestions = module.totalQuestions;
    final int completedQuestions = completedCount ?? 0;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: AppColors.textPrimary,
        ),
        title: Text(
          'Training Module',
          style: AppTextStyles.headline.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero-like kart
              SizedBox(
                height: 170,
                child: TrainingModuleCard(
                  module: module,
                  progress: null,
                  onTap: () {
                    // detail içindeyken kart tıklamasına özel aksiyon yok
                  },
                ),
              ),

              const SizedBox(height: AppSpacing.md),
              // 🔹 Module progress bar (0/total da olsa gösteriyoruz)
              _ModuleProgressBar(
                completed: completedQuestions,
                total: totalQuestions,
              ),

              const SizedBox(height: AppSpacing.lg),

              // Başlık & açıklama
              Text(
                module.title,
                style: AppTextStyles.headline,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                module.subtitle,
                style: AppTextStyles.bodyStrong,
              ),
              if (module.description != null &&
                  module.description!.trim().isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  module.description!,
                  style: AppTextStyles.body,
                ),
              ],

              const SizedBox(height: AppSpacing.lg),

              // Küçük bilgi chipleri (format + soru sayısı)
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xs,
                children: [
                  _InfoChip(
                    icon: Icons.category_outlined,
                    label: _formatLabel(module.format),
                  ),
                  _InfoChip(
                    icon: Icons.help_outline,
                    label: '${module.totalQuestions} questions',
                  ),
                  // ⛔ süre chip'i artık yok
                ],
              ),

              const SizedBox(height: AppSpacing.lg),

              // SECTION LISTESİ (artık Obx yok, normal Builder)
              Builder(
                builder: (context) {
                  final allQuestions = practiceController.allQuestions;
                  final moduleSections = sections ?? const <TrainingSection>[];
                  final moduleQuestionRefs =
                      questionRefs ?? const <TrainingModuleQuestionRef>[];

                  if (moduleSections.isEmpty) {
                    return Text(
                      'No sections defined for this plan yet.',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textMuted,
                      ),
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (int i = 0; i < moduleSections.length; i++) ...[
                        TrainingSectionCard(
                          section: moduleSections[i],
                          questions: _resolveSectionQuestions(
                            moduleSections[i],
                            allQuestions,
                            moduleQuestionRefs,
                          ),
                          onQuestionTap: (question) {
                            _startRunnerForQuestion(
                              module: module,
                              sections: moduleSections,
                              refs: moduleQuestionRefs,
                              allQuestions: allQuestions,
                              tappedQuestion: question,
                            );
                          },
                        ),
                        if (i != moduleSections.length - 1)
                          const SizedBox(height: AppSpacing.md),
                      ],
                    ],
                  );
                },
              ),

              const SizedBox(height: AppSpacing.xl),

              // Opsiyonel: Tüm planı başlat butonu (ilk section, ilk sorudan başlatmak için)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                  onPressed: () {
                    // TODO: Burada tüm module sorularını sırayla çözdürecek runner akışını bağlayacağız.
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Training flow will be wired after backend is ready.',
                        ),
                      ),
                    );
                  },
                  child: Text(
                    'Start this plan',
                    style: AppTextStyles.bodyStrong.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  // ------ helpers ------

  static String _formatLabel(TrainingModuleFormat format) {
    switch (format) {
      case TrainingModuleFormat.crashCourse:
        return 'Crash course';
      case TrainingModuleFormat.challenge:
        return 'Challenge';
      case TrainingModuleFormat.interviewPrep:
        return 'Interview prep';
    }
  }
}

/// Thin progress bar + "x / total" text.
class _ModuleProgressBar extends StatelessWidget {
  final int completed;
  final int total;

  const _ModuleProgressBar({
    required this.completed,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final safeTotal = total <= 0 ? 1 : total;
    final ratio = (completed / safeTotal).clamp(0.0, 1.0);

    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 8,
              backgroundColor: AppColors.chipBackground,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          '$completed / $total',
          style: AppTextStyles.bodySmall,
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.chipBackground,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: AppColors.textMuted,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: AppTextStyles.body,
          ),
        ],
      ),
    );
  }
}

/// Section içindeki soru referanslarına göre gerçek Question objelerini çözer.
List<Question> _resolveSectionQuestions(
  TrainingSection section,
  List<Question> allQuestions,
  List<TrainingModuleQuestionRef> allRefs,
) {
  // Bu section'a ait referansları sıraya göre al.
  final refsForSection = allRefs
      .where((ref) => ref.sectionId == section.id)
      .toList()
    ..sort((a, b) => a.order.compareTo(b.order));

  if (refsForSection.isEmpty) return const [];

  // Question havuzundan gerçek soruları seç.
  final byId = <String, Question>{
    for (final q in allQuestions) _extractQuestionId(q): q,
  };

  final result = <Question>[];
  for (final ref in refsForSection) {
    final q = byId[ref.questionId];
    if (q != null) {
      result.add(q);
    }
  }
  return result;
}

/// PracticePage’deki ile aynı: id / docId dene, yoksa title’a düş.
String _extractQuestionId(Question q) {
  try {
    final dynamic v = (q as dynamic).id;
    if (v != null) return v.toString();
  } catch (_) {}
  try {
    final dynamic v = (q as dynamic).docId;
    if (v != null) return v.toString();
  } catch (_) {}
  return q.title.toString();
}

void _startRunnerForQuestion({
  required TrainingModule module,
  required List<TrainingSection> sections,
  required List<TrainingModuleQuestionRef> refs,
  required List<Question> allQuestions,
  required Question tappedQuestion,
}) {
  // 1) Ref'leri doğru sıraya göre diz
  final sortedRefs = refs.toList()..sort((a, b) => a.order.compareTo(b.order));

  // 2) Question objelerini hazırla
  final idToQuestion = {
    for (final q in allQuestions) _extractQuestionId(q): q,
  };

  final orderedQuestions = <Question>[];
  for (final ref in sortedRefs) {
    final q = idToQuestion[ref.questionId];
    if (q != null) orderedQuestions.add(q);
  }

  if (orderedQuestions.isEmpty) {
    debugPrint("⚠️ No questions found for module ${module.id}");
    return;
  }

  // 3) Tıklanan sorunun index'ini bul
  final tappedId = _extractQuestionId(tappedQuestion);
  final startIndex = orderedQuestions.indexWhere(
    (q) => _extractQuestionId(q) == tappedId,
  );

  if (startIndex < 0) {
    debugPrint("⚠️ Tapped question not found in ordered runner list");
    return;
  }

  // 4) QuestionFeed oluştur
  final feed = QuestionFeed(
    questions: orderedQuestions,
    questionIds: orderedQuestions.map(_extractQuestionId).toList(),
    startIndex: startIndex,
    source: QuestionSourceContext(
      kind: QuestionSourceKind.trainingModule,
      label: 'Training • ${module.title}',
      // NOTE: trainingModule için refId = moduleId
      refId: module.id,
    ),
  );

  // 5) Runner aç
  Get.to(() => QuestionRunnerPage(feed: feed));
}
