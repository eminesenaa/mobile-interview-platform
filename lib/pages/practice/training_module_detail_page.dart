// ===================== File: lib/pages/practice/training_module_detail_page.dart =====================

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:interview_project/constants/constants.dart';

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
  final List<TrainingSection>? sections;

  /// Opsiyonel: Section + Question eşleşmeleri.
  final List<TrainingModuleQuestionRef>? questionRefs;

  // completedCount opsiyonel, içeride controller'dan güncelini alacağız.
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
    // Controller'ı bul
    final practiceController = Get.find<PracticeController>();
    
    // Verileri güvenli şekilde alalım
    final moduleSections = sections ?? const <TrainingSection>[];
    final moduleQuestionRefs = questionRefs ?? const <TrainingModuleQuestionRef>[];

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
        // 🔥 TÜM SAYFAYI REAKTİF (Obx) YAPIYORUZ
        child: Obx(() {
          // 1. Controller'dan anlık ilerlemeyi çek (Progress Bar için)
          final userProgress = practiceController.userProgressMap[module.id];
          final currentCompleted = userProgress?.completedQuestions ?? 0;
          final totalQuestions = module.totalQuestions;
          final progressRatio = userProgress?.progress ?? 0.0;

          // 2. 🔥 TİK İŞARETİ İÇİN KRİTİK VERİ:
          // Bu modülde çözülen soruların ID listesini (Set olarak) alıyoruz.
          final completedIds = practiceController.completedQuestionIdsByModule[module.id] ?? <String>{};

          return Column(
            children: [
              Expanded(
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
                          // Kart üzerindeki bar da güncel olsun
                          progress: progressRatio,
                          onTap: () {},
                        ),
                      ),

                      const SizedBox(height: AppSpacing.md),
                      // 🔹 Module progress bar
                      _ModuleProgressBar(
                        completed: currentCompleted,
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

                      // Küçük bilgi chipleri
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
                            label: '$totalQuestions questions',
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      // SECTION LISTESİ
                      if (moduleSections.isEmpty)
                        Text(
                          'No sections defined for this plan yet.',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.textMuted,
                          ),
                        )
                      else
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (int i = 0; i < moduleSections.length; i++) ...[
                              TrainingSectionCard(
                                section: moduleSections[i],
                                // 🔥 BURADA completedIds setini gönderiyoruz
                                questions: _resolveSectionQuestions(
                                  moduleSections[i],
                                  practiceController.allQuestions,
                                  moduleQuestionRefs,
                                  completedIds, 
                                ),
                                onQuestionTap: (question) {
                                  _startRunnerForQuestion(
                                    module: module,
                                    sections: moduleSections,
                                    refs: moduleQuestionRefs,
                                    allQuestions: practiceController.allQuestions,
                                    tappedQuestion: question,
                                  );
                                },
                              ),
                              if (i != moduleSections.length - 1)
                                const SizedBox(height: AppSpacing.md),
                            ],
                          ],
                        ),
                      
                      const SizedBox(height: AppSpacing.xl),
                    ],
                  ),
                ),
              ),

              // 🔹 ALT BUTON (Get Started / Continue)
              _buildBottomButton(
                context, 
                moduleSections, 
                moduleQuestionRefs, 
                practiceController.allQuestions, 
                currentCompleted, 
                totalQuestions,
                completedIds
              ),
            ],
          );
        }),
      ),
    );
  }

  // ===========================================================================
  // 🔘 BOTTOM ACTION BUTTON
  // ===========================================================================
  Widget _buildBottomButton(
    BuildContext context,
    List<TrainingSection> sections,
    List<TrainingModuleQuestionRef> refs,
    List<Question> allQuestions,
    int completed,
    int total,
    Set<String> completedIds,
  ) {
    String label = "Get started";
    IconData icon = Icons.play_arrow_rounded;

    if (completed > 0 && completed < total) {
      label = "Continue";
      icon = Icons.fast_forward_rounded;
    } else if (completed > 0 && completed == total) {
      label = "Review"; 
      icon = Icons.replay_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
           BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.md,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            elevation: 2,
          ),
          icon: Icon(icon, size: 20),
          label: Text(
            label,
            style: AppTextStyles.bodyStrong.copyWith(color: Colors.white),
          ),
          onPressed: () {
            // Tüm soruları sıralı al
            final orderedQuestions = _getAllOrderedQuestions(
              sections: sections, 
              refs: refs, 
              allQuestions: allQuestions
            );

            if (orderedQuestions.isEmpty) return;

            int startIndex = 0;
            if (label == "Continue") {
              // İlk çözülmemiş soruyu bul
              startIndex = orderedQuestions.indexWhere((q) {
                // Burada q.id kullanıyoruz
                return !completedIds.contains(q.id);
              });
              if (startIndex == -1) startIndex = 0;
            }

            // Runner'ı başlat
            _startRunnerWithIndex(
              module: module,
              questions: orderedQuestions,
              startIndex: startIndex
            );
          },
        ),
      ),
    );
  }


  // ===========================================================================
  // 🛠 HELPERS
  // ===========================================================================

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

  /// Tüm modülün sıralı soru listesini döndürür.
  List<Question> _getAllOrderedQuestions({
    required List<TrainingSection> sections,
    required List<TrainingModuleQuestionRef> refs,
    required List<Question> allQuestions,
  }) {
    final idToQuestion = {
      for (final q in allQuestions) q.id: q,
    };

    List<Question> result = [];

    for (var section in sections) {
       final refsForSection = refs
          .where((r) => r.sectionId == section.id)
          .toList()
          ..sort((a, b) => a.order.compareTo(b.order));
      
      for(var ref in refsForSection) {
        final q = idToQuestion[ref.questionId];
        if (q != null) result.add(q);
      }
    }
    return result;
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
/// 🔥 completedIds listesindeki soruları 'solved' olarak işaretler.
List<Question> _resolveSectionQuestions(
  TrainingSection section,
  List<Question> allQuestions,
  List<TrainingModuleQuestionRef> allRefs,
  Set<String> completedIds,
) {
  // Bu section'a ait referansları sıraya göre al.
  final refsForSection = allRefs
      .where((ref) => ref.sectionId == section.id)
      .toList()
    ..sort((a, b) => a.order.compareTo(b.order));

  if (refsForSection.isEmpty) return const [];

  final byId = <String, Question>{
    for (final q in allQuestions) q.id: q,
  };

  final result = <Question>[];
  for (final ref in refsForSection) {
    final q = byId[ref.questionId];
    if (q != null) {
      // 🔥 İŞTE SİHİR BURADA:
      // Eğer soru tamamlanmışlar listesindeyse, statüsünü değiştirip listeye ekliyoruz.
      if (completedIds.contains(ref.questionId)) {
         result.add(q.copyWith(status: Status.solved));
      } else {
         result.add(q);
      }
    }
  }
  return result;
}

String _extractQuestionId(Question q) => q.id;

/// Runner'ı belirli bir indexten başlatır
void _startRunnerWithIndex({
  required TrainingModule module,
  required List<Question> questions,
  required int startIndex,
}) {
  if (questions.isEmpty) return;

  final feed = QuestionFeed(
    questions: questions,
    questionIds: questions.map((q) => q.id).toList(),
    startIndex: startIndex,
    source: QuestionSourceContext(
      kind: QuestionSourceKind.trainingModule,
      label: 'Training • ${module.title}',
      refId: module.id,
    ),
  );

  Get.to(() => QuestionRunnerPage(feed: feed));
}

/// Belirli bir soruya tıklandığında çalışır
void _startRunnerForQuestion({
  required TrainingModule module,
  required List<TrainingSection> sections,
  required List<TrainingModuleQuestionRef> refs,
  required List<Question> allQuestions,
  required Question tappedQuestion,
}) {
  final idToQuestion = {
    for (final q in allQuestions) q.id: q,
  };

  final orderedQuestions = <Question>[];
  // Section sırasını takip et
  for (var section in sections) {
     final sRefs = refs.where((r) => r.sectionId == section.id).toList()
       ..sort((a,b) => a.order.compareTo(b.order));
     
     for (var r in sRefs) {
       final q = idToQuestion[r.questionId];
       if(q != null) orderedQuestions.add(q);
     }
  }

  if (orderedQuestions.isEmpty) {
    debugPrint("⚠️ No questions found for module ${module.id}");
    return;
  }

  // 3) Tıklanan sorunun index'ini bul
  final tappedId = tappedQuestion.id;
  final startIndex = orderedQuestions.indexWhere(
    (q) => q.id == tappedId,
  );

  if (startIndex < 0) {
    debugPrint("⚠️ Tapped question not found in ordered runner list");
    return;
  }

  _startRunnerWithIndex(
    module: module, 
    questions: orderedQuestions, 
    startIndex: startIndex
  );
}