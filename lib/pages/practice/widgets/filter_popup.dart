import 'package:flutter/material.dart';
import '../../../constants/constants.dart';
import '../../../models/question.dart';

class FilterPopup extends StatefulWidget {
  final List<String> topics;
  final List<Difficulty?> difficulties;
  final List<Status?> statuses;
  final List<QuestionType?> questionTypes;

  /// Çoklu seçim için mevcut seçili değerler
  final List<String> selectedTopics;
  final List<Difficulty> selectedDifficulties;
  final List<QuestionType> selectedQuestionTypes;
  final Status? selectedStatus;

  /// Apply butonuna basıldığında controller'a geri dönecek değerler.
  final void Function({
    required List<String> topics,
    required List<Difficulty> difficulties,
    required List<QuestionType> questionTypes,
    required Status? status,
  }) onApply;

  const FilterPopup({
    super.key,
    required this.topics,
    required this.difficulties,
    required this.statuses,
    required this.questionTypes,
    required this.selectedTopics,
    required this.selectedDifficulties,
    required this.selectedQuestionTypes,
    required this.selectedStatus,
    required this.onApply,
  });

  @override
  State<FilterPopup> createState() => _FilterPopupState();
}

class _FilterPopupState extends State<FilterPopup> {
  late Set<String> _selectedTopics;
  late Set<Difficulty> _selectedDifficulties;
  late Set<QuestionType> _selectedQuestionTypes;
  Status? _status;

  String _topicSearch = '';

  late final FocusNode _topicFocusNode;
  bool _isTopicFocused = false;

  @override
  void initState() {
    super.initState();
    _selectedTopics = {...widget.selectedTopics};
    _selectedDifficulties = {...widget.selectedDifficulties};
    _selectedQuestionTypes = {...widget.selectedQuestionTypes};
    _status = widget.selectedStatus;
    _topicFocusNode = FocusNode();
    _topicFocusNode.addListener(() {
      setState(() {
        _isTopicFocused = _topicFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _topicFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredTopics = widget.topics
        .where(
          (t) => t.toLowerCase().contains(
                _topicSearch.toLowerCase().trim(),
              ),
        )
        .toList()
      ..sort();

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.lg + MediaQuery.of(context).padding.bottom,
          ),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppRadius.lg),
            ),
            boxShadow: AppShadows.medium,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              Center(
                child: Text(
                  'Filter Questions',
                  style: AppTextStyles.title.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // ===================== TOPICS =====================
              Text(
                'Topics',
                style: AppTextStyles.label.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),

              TextField(
                cursorColor: AppColors.primary,
                // cursor primary renk
                focusNode: _topicFocusNode,
                decoration: InputDecoration(
                  hintText: 'Search topic',
                  prefixIcon: const Icon(
                    Icons.search,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.sm,
                  ),
                  filled: true,
                  fillColor: AppColors.surfaceMuted,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                  ),
                ),
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textPrimary,
                ),
                onChanged: (value) {
                  setState(() {
                    _topicSearch = value;
                  });
                },
              ),

              const SizedBox(height: AppSpacing.sm),

              // Liste kısmı scroll edilebilir
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 260),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: filteredTopics.length,
                  itemBuilder: (context, index) {
                    final topic = filteredTopics[index];
                    final selected = _selectedTopics.contains(topic);

                    return Theme(
                      // Checkbox mor olmasın, primary olsun
                      data: Theme.of(context).copyWith(
                        checkboxTheme: CheckboxThemeData(
                          fillColor: MaterialStateProperty.resolveWith(
                                (states) => states.contains(MaterialState.selected)
                                ? AppColors.primary
                                : AppColors.surface,
                          ),
                          checkColor: MaterialStateProperty.all(
                            AppColors.textLightPrimary,
                          ),
                          side: MaterialStateBorderSide.resolveWith(
                                (states) {
                              if (states.contains(MaterialState.selected)) {
                                // ✅ seçili: primary border
                                return const BorderSide(
                                  color: AppColors.primary,
                                  width: 1.4,
                                );
                              }
                              // ✅ seçili DEĞİLKEN: textSecondary (yandaki yazıyla aynı)
                              return const BorderSide(
                                color: AppColors.textSecondary,
                                width: 1.4,
                              );
                            },
                          ),

                        ),
                      ),
                      child: CheckboxListTile(
                        value: selected,
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.trailing,
                        title: Text(
                          topic,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: selected
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                            fontWeight:
                                selected ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                        onChanged: (checked) {
                          setState(() {
                            if (checked == true) {
                              _selectedTopics.add(topic);
                            } else {
                              _selectedTopics.remove(topic);
                            }
                          });
                        },
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // ===================== DIFFICULTY =====================
              Text(
                'Difficulty',
                style: AppTextStyles.label.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),

              Wrap(
                children: widget.difficulties.whereType<Difficulty>().map((d) {
                  final selected = _selectedDifficulties.contains(d);
                  final baseColor = _difficultyColor(d);

                  return _DifficultyChip(
                    label: formatEnumLabel(d.name),
                    baseColor: baseColor,
                    selected: selected,
                    onTap: () {
                      setState(() {
                        if (selected) {
                          _selectedDifficulties.remove(d);
                        } else {
                          _selectedDifficulties.add(d);
                        }
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: AppSpacing.lg),

              // ===================== QUESTION TYPES =====================
              Text(
                'Question Types',
                style: AppTextStyles.label.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),

              Wrap(
                children:
                    widget.questionTypes.whereType<QuestionType>().map((qt) {
                  final selected = _selectedQuestionTypes.contains(qt);

                  return _QuestionTypeChip(
                    label: formatQuestionType(qt),
                    selected: selected,
                    onTap: () {
                      setState(() {
                        if (selected) {
                          _selectedQuestionTypes.remove(qt);
                        } else {
                          _selectedQuestionTypes.add(qt);
                        }
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: AppSpacing.lg),

              // ===================== STATUS (tek seçim – radio) =====================
              Text(
                'Status',
                style: AppTextStyles.label.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),

               Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // All (Any status)
                    RadioListTile<Status?>(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      value: null,
                      groupValue: _status,
                      activeColor: AppColors.primary,
                      title: Text(
                        'All',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: _status == null
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                          fontWeight:
                              _status == null ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                      onChanged: (_) {
                        setState(() {
                          _status = null;
                        });
                      },
                    ),

                    // Diğer durumlar (To do, Solved vs.)
                    ...widget.statuses.whereType<Status>().map(
                      (s) {
                        final selected = _status == s;
                        return RadioListTile<Status?>(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          value: s,
                          groupValue: _status,
                          fillColor: MaterialStateProperty.resolveWith(
                                (states) {
                              if (states.contains(MaterialState.selected)) {
                                return AppColors.primary; // seçili renk
                              }
                              return AppColors.textMuted; // seçilmemiş outer + inner renk
                            },
                          ),
                          activeColor: AppColors.primary,
                          title: Text(
                            formatEnumLabel(s.name),
                            style: AppTextStyles.bodySmall.copyWith(
                              color: selected
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary,
                              fontWeight:
                                  selected ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                          onChanged: (_) {
                            setState(() {
                              _status = s;
                            });
                          },
                        );
                      },
                    ),
                  ],
                ),

              const SizedBox(height: AppSpacing.lg),

              // ===================== ACTION BUTTONS =====================
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.border),
                        foregroundColor: AppColors.textSecondary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _selectedTopics.clear();
                          _selectedDifficulties.clear();
                          _selectedQuestionTypes.clear();
                          _status = null;
                          _topicSearch = '';
                        });

                        widget.onApply(
                          topics: const [],
                          difficulties: const [],
                          questionTypes: const [],
                          status: null,
                        );

                        Navigator.of(context).pop();
                      },
                      child: const Text('Clear'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.textLightPrimary,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.sm,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                      ),
                      onPressed: () {
                        widget.onApply(
                          topics: _selectedTopics.toList(),
                          difficulties: _selectedDifficulties.toList(),
                          questionTypes: _selectedQuestionTypes.toList(),
                          status: _status,
                        );
                        Navigator.of(context).pop();
                      },
                      child: const Text('Apply'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Difficulty için colors.dart’taki renkleri seçiyoruz.
  Color _difficultyColor(Difficulty d) {
    final raw = d.name.toLowerCase();

    if (raw.contains('easy') &&
        !raw.contains('medium') &&
        !raw.contains('hard')) {
      return AppColors.difficultyEasy;
    }
    if (raw.contains('easy') && raw.contains('medium')) {
      return AppColors.difficultyEasyMedium;
    }
    if (raw.contains('medium') &&
        !raw.contains('easy') &&
        !raw.contains('hard')) {
      return AppColors.difficultyMedium;
    }
    if (raw.contains('medium') && raw.contains('hard')) {
      return AppColors.difficultyMediumHard;
    }
    if (raw.contains('hard') &&
        !raw.contains('easy') &&
        !raw.contains('medium')) {
      return AppColors.difficultyHard;
    }

    // Fallback – hiçbirine uymuyorsa primary kullan.
    return AppColors.primary;
  }
}

/// Difficulty chip – 2. görseldeki gibi dikdörtgen, renkli border + seçilince hafif dolu.
class _DifficultyChip extends StatelessWidget {
  final String label;
  final Color baseColor;
  final bool selected;
  final VoidCallback onTap;

  const _DifficultyChip({
    required this.label,
    required this.baseColor,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final background =
        selected ? baseColor.withOpacity(0.10) : AppColors.surface;
    final borderColor = selected ? baseColor : baseColor.withOpacity(0.6);
    final textColor = baseColor;

    return Padding(
      padding: const EdgeInsets.only(
        right: AppSpacing.sm,
        bottom: AppSpacing.sm,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selected) ...[
                Icon(
                  Icons.check,
                  size: 14,
                  color: textColor,
                ),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: AppTextStyles.chip.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Question Type chip – seçili olunca mavi dolu, seçili değilken gri border.
class _QuestionTypeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _QuestionTypeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final background = selected ? AppColors.primary : AppColors.chipBackground;
    final borderColor = selected ? AppColors.primary : AppColors.chipBackground;
    final textColor =
        selected ? AppColors.textLightPrimary : AppColors.textSecondary;

    return Padding(
      padding: const EdgeInsets.only(
        right: AppSpacing.sm,
        bottom: AppSpacing.sm,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selected) ...[
                Icon(
                  Icons.check,
                  size: 14,
                  color: textColor,
                ),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: AppTextStyles.chip.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===================== Helpers =====================

String formatEnumLabel(String raw) {
  final lower = raw.toLowerCase();

  // 👇 özel case: TODO → To Do
  if (lower == 'todo') return 'To Do';

  // 👇 özel case: SOLVED → Solved (zaten böyle)
  if (lower == 'solved') return 'Solved';

  return lower
      .replaceAll('_', ' ')
      .split(' ')
      .where((p) => p.trim().isNotEmpty)
      .map((w) => w[0].toUpperCase() + w.substring(1))
      .join(' ');
}


/// Soru tipini kullanıcı dostu hale getiren helper.
String formatQuestionType(QuestionType? qt) {
  if (qt == null) return 'Any type';
  final raw = qt.name;

  // Özel case'ler – '_' kaldır, biraz format atalım
  if (raw.toLowerCase() == 'mcq') return 'MCQ';
  if (raw.toLowerCase().contains('short')) return 'Short Answer';
  if (raw.toLowerCase().contains('fill')) return 'Fill Blank';
  if (raw.toLowerCase().contains('debug')) return 'Debugging';

  return formatEnumLabel(raw);
}
