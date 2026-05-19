// ===================== File: hr_job_postings_page.dart =====================
// Purpose:
// Main page for managing job postings (Applications)
//
// Features:
// - Toggle between Active / Closed postings
// - Displays list of postings
// - Floating button to create new posting
//
// IMPORTANT:
// - Uses HrJobPostingsController
// - Fully backend-ready
//
// TODO (Backend):
// - Fetch postings from API / Firestore
// - Handle pagination
// - Connect posting → applicants flow
// ==========================================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../constants/constants.dart';


// Widgets
import '../controllers/hr_job_postings_controller.dart';
import 'widgets/jp_create_button.dart';
import 'widgets/jp_filter_tabs.dart';
import 'widgets/jp_postings_list.dart';
import 'widgets/jp_section_header.dart';


class HRJobPostingsPage extends StatelessWidget {
  const HRJobPostingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(HrJobPostingsController());

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
        title: const Text("Applications"),
      ),

      /// ================= BODY =================
      body: Obx(() {
        final isActive = c.selectedTab.value == "active";
        final postings = isActive ? c.activePostings : c.closedPostings;

        return SingleChildScrollView(
          padding: const EdgeInsets.only(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            bottom: AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ================= FILTER =================
              JPFilterTabs(
                selected: c.selectedTab.value,
                onChanged: c.changeTab,
              ),

              const SizedBox(height: AppSpacing.lg),

              /// ================= SECTION HEADER =================
              JPSectionHeader(
                title: isActive ? "OPEN ROLES" : "CLOSED ROLES",
                badge: isActive
                    ? "${c.activePostings.length} active"
                    : "${c.closedPostings.length} closed",
              ),

              const SizedBox(height: AppSpacing.md),

              /// ================= LIST =================
              JPPostingsList(
                postings: postings,
                onTap: c.openPosting,
              ),

              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        );
      }),

      /// ================= FLOATING BUTTON =================
      floatingActionButton: JPCreateButton(
        onTap: c.createPosting,
      ),
    );
  }
}
