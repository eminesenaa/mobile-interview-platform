import 'package:flutter/material.dart';
import 'jp_posting_card.dart';

class JPPostingsList extends StatelessWidget {
  final List<Map<String, dynamic>> postings;
  final Function(Map<String, dynamic>) onTap;

  const JPPostingsList({
    super.key,
    required this.postings,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: postings.map((p) {
        return JPPostingCard(
          title: p["title"],
          level: p["level"],
          location: p["location"],
          workType: p["workType"],
          applicants: p["applicantCount"] ?? 0,
          accepted: p["accepted"] ?? 0,
          pending: p["pending"] ?? 0,
          status: p["status"] ?? "active",
          onTap: () => onTap(p),
        );
      }).toList(),
    );
  }
}