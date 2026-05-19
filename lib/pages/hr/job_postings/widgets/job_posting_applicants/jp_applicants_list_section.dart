import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../controllers/hr_job_postings_controller.dart';
import 'jp_applicants_section_label.dart';
import '../job_posting_detail/jp_applicant_card.dart';
import 'package:get/get.dart';

/// ===================== APPLICANTS LIST SECTION =====================
/// Combines:
/// - Section label
/// - List of applicant cards
///
/// Used for:
/// - Pending section
/// - Accepted section
/// - Rejected section
/// ================================================================

class JPApplicantsListSection extends StatelessWidget {
  final String postingId;
  final String title;
  final List<Map<String, dynamic>> applicants;

  const JPApplicantsListSection({
    super.key,
    required this.postingId,
    required this.title,
    required this.applicants,
  });

  @override
  Widget build(BuildContext context) {
    if (applicants.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// SECTION LABEL
        JPApplicantsSectionLabel(
          title: title,
          count: applicants.length,
        ),

        const SizedBox(height: 10),

        /// LIST
        ...applicants.map((a) {
          final controller = Get.find<HrJobPostingsController>();
          final userId = a["userId"] ?? "";

          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection("users").doc(userId).get(),
            builder: (context, snapshot) {
              String name = a["name"] ?? "Anonymous";
              String university = a["university"] ?? "";
              String department = a["department"] ?? "";

              if (snapshot.hasData && snapshot.data!.exists) {
                final userData = snapshot.data!.data() as Map<String, dynamic>;
                // Use profile data if current data is placeholder or empty
                if (name == "Anonymous" || name.isEmpty) {
                  final fName = userData["name"] ?? "";
                  final lName = userData["surname"] ?? "";
                  final combined = "$fName $lName".trim();
                  name = combined.isNotEmpty ? combined : (userData["displayName"] ?? name);
                }
                if (university.isEmpty) {
                  university = userData["school"] ?? userData["university"] ?? "";
                }
                if (department.isEmpty) {
                  department = userData["department"] ?? "";
                }
              }

              final subtitle = (university.isNotEmpty)
                  ? "$university · $department"
                  : department;

              return GestureDetector(
                onTap: () {
                  controller.openCandidateDetail(
                    postingId,
                    userId,
                  );
                },
                child: JPApplicantCard(
                  name: name,
                  subtitle: subtitle,
                  status: a["status"],
                  postingId: postingId, // 🔥 Pass postingId
                  application: a,
                ),
              );
            },
          );
        }),
      ],
    );
  }
}
