// ===================== File: ir_results_list.dart =====================
// Purpose:
// Displays grouped interview widgets list
// (Accepted → Pending → Rejected)
// ====================================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../constants/constants.dart';
import '../../../../models/interview_result.dart';
import '../../pages/results/interview_result_detail_page.dart';
import '../interview_dashboard/id_result_item.dart';
import 'ir_section_label.dart';

class IrResultsList extends StatelessWidget {
  final List<Map<String, dynamic>> results;
  final Function(Map<String, dynamic>) onTap;

  const IrResultsList({
    super.key,
    required this.results,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    String getStatus(Map<String, dynamic> r) {
      if (r["result"] is InterviewResult) {
        final decision = (r["result"] as InterviewResult).decision;
        return decision.toString().split('.').last.toLowerCase();
      }
      final dec = r["decision"]?.toString().toLowerCase() ?? "pending";
      if (dec == "accepted" || dec == "rejected") {
        return dec;
      }
      return "pending";
    }

    // ================= GROUPING =================
    final accepted = results.where((r) {
      return getStatus(r) == "accepted";
    }).toList();

    final pending = results.where((r) {
      return getStatus(r) == "pending";
    }).toList();

    final rejected = results.where((r) {
      return getStatus(r) == "rejected";
    }).toList();

    return ListView(
      children: [
        // ================= ACCEPTED =================
        if (accepted.isNotEmpty) ...[
          const IrSectionLabel(title: "ACCEPTED"),
          const SizedBox(height: AppSpacing.sm),
          ...accepted.map((r) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: IdResultItem(
                  result: r,
                  onTap: () {
                    Get.to(
                      () => const InterviewResultDetailPage(),
                      arguments: r,
                    );
                  },
                ),
              )),
          const SizedBox(height: AppSpacing.lg),
        ],

        // ================= REJECTED =================
        if (rejected.isNotEmpty) ...[
          const IrSectionLabel(title: "REJECTED"),
          const SizedBox(height: AppSpacing.sm),
          ...rejected.map((r) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: IdResultItem(
                  result: r,
                  onTap: () {
                    Get.to(
                      () => const InterviewResultDetailPage(),
                      arguments: r,
                    );
                  },
                ),
              )),
        ],

        // ================= PENDING =================
        if (pending.isNotEmpty) ...[
          const IrSectionLabel(title: "PENDING"),
          const SizedBox(height: AppSpacing.sm),
          ...pending.map((r) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: IdResultItem(
                  result: r,
                  onTap: () {
                    Get.to(
                      () => const InterviewResultDetailPage(),
                      arguments: r,
                    );
                  },
                ),
              )),
          const SizedBox(height: AppSpacing.lg),
        ],
      ],
    );
  }
}
