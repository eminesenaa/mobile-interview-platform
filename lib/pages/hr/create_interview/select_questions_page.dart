// ===================== File: select_questions_page.dart =====================
// Purpose:
// HR - Select Questions From Database Page
//
// Features:
// - Same UI as Practice Page (filter + list)
// - Uses HrQuestionSelectCard (selection-based)
// - No runner / no solving
// - Multi-select support
// - Clean & lightweight
// ============================================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:interview_project/pages/hr/create_interview/widgets/create_interview/hr_question_select_card.dart';

import '../../../../constants/constants.dart';
import '../../../models/question.dart';
import '../../practice/widgets/filter_popup.dart';
import '../../practice/widgets/search_add_bar.dart';
import '../../practice/widgets/topic_chip_scroll.dart';
import '../controllers/select_questions_controller.dart';

class SelectQuestionsPage extends StatelessWidget {
  const SelectQuestionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SelectQuestionsController());

    return Scaffold(
      backgroundColor: AppColors.background,

      // ================= APP BAR =================
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text("Select Questions"),
      ),

      // ================= BODY =================
      body: SafeArea(
        child: Obx(() {
          final questions = controller.filteredQuestions;

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ================= FILTER BAR =================
              SliverPersistentHeader(
                pinned: true,
                delegate: _StickyHeader(
                  child: Container(
                    color: AppColors.background,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                    child: Column(
                      children: [
                        // Topic chips
                        Obx(() => TopicChipScroll(
                              topics: controller.allTopics,
                              selectedTopic: controller.selectedTopic.value,
                              onTopicSelected: controller.updateTopic,
                            )),

                        // Divider
                        Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: AppSpacing.md),
                          height: 1.2,
                          color: AppColors.textMuted,
                        ),

                        // Search bar
                        Obx(() => SearchAddBar(
                              searchText: controller.searchQuery.value,
                              onSearchChanged: controller.updateSearch,

                              // 🔥 EKLENDİ
                              isFilterActive:
                                  controller.selectedTopicsMulti.isNotEmpty ||
                                      controller.selectedDifficultiesMulti
                                          .isNotEmpty ||
                                      controller.selectedQuestionTypesMulti
                                          .isNotEmpty ||
                                      controller.selectedStatus.value != null,

                              onFilterPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (_) => FilterPopup(
                                    topics: controller.allTopics
                                        .where((t) => t != 'All')
                                        .toList(),
                                    difficulties: Difficulty.values,
                                    questionTypes: QuestionType.values,
                                    statuses: Status.values,
                                    selectedTopics:
                                        controller.selectedTopicsMulti.toList(),
                                    selectedDifficulties: controller
                                        .selectedDifficultiesMulti
                                        .toList(),
                                    selectedQuestionTypes: controller
                                        .selectedQuestionTypesMulti
                                        .toList(),
                                    selectedStatus:
                                        controller.selectedStatus.value,
                                    onApply: ({
                                      required List<String> topics,
                                      required List<Difficulty> difficulties,
                                      required List<QuestionType> questionTypes,
                                      required Status? status,
                                    }) {
                                      controller.updateFiltersMulti(
                                        topics: topics,
                                        difficulties: difficulties,
                                        questionTypes: questionTypes,
                                        status: status,
                                      );
                                    },
                                  ),
                                );
                              },

                              onRandomPressed: () {},
                            )),
                      ],
                    ),
                  ),
                ),
              ),

              // ================= LOADING =================
              if (controller.isLoading.value)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()),
                )

              // ================= EMPTY =================
              else if (questions.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyState(),
                )

              // ================= QUESTION LIST =================
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final q = questions[index];

                        return Padding(
                          padding: const EdgeInsets.only(
                            bottom: AppSpacing.sm,
                          ),
                          child: Obx(
                            () => HrQuestionSelectCard(
                              question: q,
                              isSelected: controller.isSelected(q.id),
                              onTap: () => controller.toggleSelection(q.id),
                            ),
                          ),
                        );
                      },
                      childCount: questions.length,
                    ),
                  ),
                ),

              const SliverToBoxAdapter(
                child: SizedBox(height: AppSpacing.xl),
              ),
            ],
          );
        }),
      ),

      // ================= BOTTOM ACTION BAR =================
      bottomNavigationBar: Obx(() {
        final count = controller.selectedCount;

        if (count == 0) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(
              top: BorderSide(color: AppColors.border),
            ),
          ),
          child: Row(
            children: [
              // Selected count
              Text(
                "$count selected".toUpperCase(),
                style: AppTextStyles.label.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const Spacer(),

              // Action button
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary),
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
                onPressed: () {
                  final selectedIds = controller.selectedIds;
                  // TODO: pass selectedIds to interview creation flow

                  Navigator.of(context).pop(selectedIds);
                },
                child: Text(
                  "Add Questions",
                  style: AppTextStyles.bodyStrong.copyWith(
                    color: AppColors.textLightPrimary,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

// ================= STICKY HEADER =================

class _StickyHeader extends SliverPersistentHeaderDelegate {
  final Widget child;

  _StickyHeader({required this.child});

  @override
  double get minExtent => 160;

  @override
  double get maxExtent => 160;

  @override
  Widget build(context, shrinkOffset, overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(_) => false;
}

// ================= EMPTY STATE =================

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'No questions found.',
        style: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(color: Theme.of(context).hintColor),
      ),
    );
  }
}
