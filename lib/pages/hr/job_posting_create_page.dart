// ===================== File: job_posting_create_page.dart =====================
// Purpose:
// Page for creating a new Job Posting
//
// Structure:
// - Uses existing HRDashboardController (NO new controller)
// - Fully modular (uses jp_* widgets)
// - Backend-ready form structure
//
// Sections:
// 1. Job Title
// 2. Level & Work Type
// 3. Location (Country / City)
// 4. Salary (optional)
// 5. Description
// 6. Requirements
// 7. Publish Button
//
// TODO (Backend):
// - Send form data to API
// - Validate required fields
// - Persist posting
// ============================================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:interview_project/pages/hr/widgets/job_postings/jp_dropdown_field.dart';
import 'package:interview_project/pages/hr/widgets/job_postings/jp_multiline_field.dart';
import 'package:interview_project/pages/hr/widgets/job_postings/jp_publish_button.dart';
import 'package:interview_project/pages/hr/widgets/job_postings/jp_section_label.dart';
import 'package:interview_project/pages/hr/widgets/job_postings/jp_text_field.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../constants/colors.dart';
import '../../constants/constants.dart';
import 'controllers/hr_job_postings_controller.dart';

class JobPostingCreatePage extends StatefulWidget {
  const JobPostingCreatePage({super.key});

  @override
  State<JobPostingCreatePage> createState() => _JobPostingCreatePageState();
}

class _JobPostingCreatePageState extends State<JobPostingCreatePage> {
  late HrJobPostingsController c;

  @override
  void initState() {
    super.initState();
    c = Get.put(HrJobPostingsController()); // ✅ initState'de bir kez çalışır
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        centerTitle: true,
        title: const Text("New Posting"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const JPSectionLabel(text: "Job Title"),
              const SizedBox(height: AppSpacing.sm),
              JPTextField(
                hint: "e.g. Frontend Developer",
                value: c.jobTitle.value,
                suffixIcon: PhosphorIcons.pencil(PhosphorIconsStyle.fill),
                onChanged: (v) => c.jobTitle.value = v,
              ),
              const SizedBox(height: AppSpacing.lg),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const JPSectionLabel(text: "Level"),
                        const SizedBox(height: AppSpacing.sm),
                        JPDropdownField(
                          value: c.jobLevel.value,
                          hint: "Select",
                          items: const ["Intern", "Junior", "Mid-Level", "Senior"],
                          onChanged: (v) => c.jobLevel.value = v,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const JPSectionLabel(text: "Work Type"),
                        const SizedBox(height: AppSpacing.sm),
                        JPDropdownField(
                          value: c.workType.value,
                          hint: "Select",
                          items: const ["Remote", "Hybrid", "On-site"],
                          onChanged: (v) => c.workType.value = v,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const JPSectionLabel(text: "Country"),
                        const SizedBox(height: AppSpacing.sm),
                        JPTextField(
                          hint: "e.g. Turkey",
                          value: c.country.value,
                          onChanged: (v) => c.country.value = v,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const JPSectionLabel(text: "City"),
                        const SizedBox(height: AppSpacing.sm),
                        JPTextField(
                          hint: "e.g. Istanbul",
                          value: c.city.value,
                          onChanged: (v) => c.city.value = v,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              const JPSectionLabel(text: "Salary Range (Optional)"),
              const SizedBox(height: AppSpacing.sm),
              JPTextField(
                hint: "e.g. \$4000 - \$6000 / month",
                value: c.salary.value,
                onChanged: (v) => c.salary.value = v,
              ),
              const SizedBox(height: AppSpacing.lg),

              const JPSectionLabel(text: "Job Description"),
              const SizedBox(height: AppSpacing.sm),
              JPMultilineField(
                hint: "Describe the role, responsibilities...",
                value: c.description.value,
                onChanged: (v) => c.description.value = v,
              ),
              const SizedBox(height: AppSpacing.lg),

              const JPSectionLabel(text: "Requirements"),
              const SizedBox(height: AppSpacing.sm),
              JPMultilineField(
                hint: "List required skills, experience...",
                value: c.requirements.value,
                onChanged: (v) => c.requirements.value = v,
              ),
              const SizedBox(height: AppSpacing.xl),

              JPPublishButton(
                onTap: () {
                  Get.snackbar("Posting", "Publish clicked (mock)");
                },
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}