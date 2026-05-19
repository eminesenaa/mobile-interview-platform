// ===================== File: candidate_application_detail_page.dart =====================
// Purpose:
// Displays full details of a candidate's job application.
//
// Includes:
// - Profile header (name, avatar, status)
// - Contact info
// - Skills
// - Cover letter
// - Links (portfolio, github, linkedin)
// - Resume
// - Action section (Accept / Reject)
//
// IMPORTANT:
// - Uses JobApplication model
// - Controller integration will be added later
// ================================================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../constants/constants.dart';

// Widgets
import '../controllers/hr_job_postings_controller.dart';
import '../controllers/send_decision_message_controller.dart';
import 'send_decision_message_page.dart';
import 'widgets/candidate_application_detail/cad_action_section.dart';
import 'widgets/candidate_application_detail/cad_application_info_section.dart';
import 'widgets/candidate_application_detail/cad_contact_section.dart';
import 'widgets/candidate_application_detail/cad_cover_letter_section.dart';
import 'widgets/candidate_application_detail/cad_header.dart';
import 'widgets/candidate_application_detail/cad_links_section.dart';
import 'widgets/candidate_application_detail/cad_resume_section.dart';
import 'widgets/candidate_application_detail/cad_skills_section.dart';

class CandidateApplicationDetailPage extends StatelessWidget {
  final Map<String, dynamic> application;

  const CandidateApplicationDetailPage({
    super.key,
    required this.application,
  });

  @override
  Widget build(BuildContext context) {
    final c = Get.find<HrJobPostingsController>();

    /// ================= DATA PARSING =================
    final name = application["name"] ?? "Unknown";
    final position = application["position"] ?? "Unknown Position";
    final status = c.getApplicantStatus(
      application["postingId"],
      application["id"],
    );

    final email = application["email"] ?? "-";
    final phone = application["phone"] ?? "-";
    final location = application["location"] ?? "-";

    final skills = List<String>.from(application["skills"] ?? []);

    final coverLetter = application["coverLetter"] ?? "";

    final portfolio = application["portfolioUrl"];
    final github = application["githubUrl"];
    final linkedin = application["linkedinUrl"];

    final resume = application["resumeUrl"] ?? "Resume.pdf";

    return Scaffold(
      backgroundColor: AppColors.background,

      /// ================= APP BAR =================
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text("Candidate Application"),
      ),

      /// ================= BODY =================
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ================= HEADER =================
            Obx(() {
              final currentStatus = c.getApplicantStatus(
                application["postingId"],
                application["id"],
              );
              return Center(
                child: CADHeader(
                  name: name,
                  position: position,
                  status: currentStatus,
                ),
              );
            }),

            const SizedBox(height: AppSpacing.xl),

            /// ================= CONTACT =================
            Text("CONTACT", style: AppTextStyles.label.copyWith(fontSize: 13)),
            const SizedBox(height: 8),
            CADContactSection(
              email: email,
              phone: phone,
              location: location,
            ),

            const SizedBox(height: AppSpacing.xl),

            /// ================= APPLICATION INFO =================
            Text("APPLICATION INFO",
                style: AppTextStyles.label.copyWith(fontSize: 13)),

            const SizedBox(height: 8),

            CADApplicationInfoSection(
              position: position,
              university: application["university"] ?? "-",
              department: application["department"] ?? "-",
              grade: application["grade"],
            ),

            const SizedBox(height: AppSpacing.xl),

            /// ================= SKILLS =================
            if (skills.isNotEmpty) ...[
              Text("SKILLS", style: AppTextStyles.label.copyWith(fontSize: 13)),
              const SizedBox(height: 8),
              CADSkillsSection(skills: skills),
              const SizedBox(height: AppSpacing.xl),
            ],

            /// ================= COVER LETTER =================
            if (coverLetter.isNotEmpty) ...[
              Text("COVER LETTER",
                  style: AppTextStyles.label.copyWith(fontSize: 13)),
              const SizedBox(height: 8),
              CADCoverLetterSection(text: coverLetter),
              const SizedBox(height: AppSpacing.xl),
            ],

            /// ================= LINKS =================
            if (portfolio != null || github != null || linkedin != null) ...[
              Text("LINKS", style: AppTextStyles.label.copyWith(fontSize: 13)),
              const SizedBox(height: 8),
              CADLinksSection(
                portfolio: portfolio,
                github: github,
                linkedin: linkedin,
              ),
              const SizedBox(height: AppSpacing.xl),
            ],

            /// ================= RESUME =================
            if (resume != null) ...[
              Text("RESUME", style: AppTextStyles.label.copyWith(fontSize: 13)),
              const SizedBox(height: 8),
              CADResumeSection(fileName: resume),
              const SizedBox(height: AppSpacing.xl),
            ],

            /// ================= ACTION =================
            Obx(() {
              final currentStatus = c.getApplicantStatus(
                application["postingId"],
                application["id"],
              );
              return CADActionSection(
                status: currentStatus,
                onAccept: () async {
                  final result = await Get.to(() => SendDecisionMessagePage(
                        decision: DecisionType.accept,
                        application: application,
                      ));

                  if (result == true) {
                    // Update already handled in SendDecisionMessageController
                  }
                },
                onReject: () async {
                  final result = await Get.to(() => SendDecisionMessagePage(
                        decision: DecisionType.reject,
                        application: application,
                      ));

                  if (result == true) {
                    // Update already handled in SendDecisionMessageController
                  }
                },
              );
            }),

            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}
