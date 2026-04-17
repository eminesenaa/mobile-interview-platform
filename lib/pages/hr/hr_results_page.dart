// ===================== File: hr_results_page.dart =====================
// Purpose:
// HR reviews interview results and makes decisions
//
// Notes:
// - Uses mock data for now
// - Accept / Reject flow implemented
// - Will connect to backend later
// =====================================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constants/colors.dart';
import '../../constants/constants.dart';

class HRResultsPage extends StatefulWidget {
  const HRResultsPage({super.key});

  @override
  State<HRResultsPage> createState() => _HRResultsPageState();
}

class _HRResultsPageState extends State<HRResultsPage> {
  int? selectedIndex;

  final List<Map<String, dynamic>> candidates = [
    {
      "name": "Ayşe Kaya",
      "score": 87,
      "correct": 17,
      "wrong": 3,
      "status": "Pending",
    },
    {
      "name": "Burak Demir",
      "score": 74,
      "correct": 15,
      "wrong": 5,
      "status": "Pending",
    },
    {
      "name": "Zeynep Arslan",
      "score": 61,
      "correct": 12,
      "wrong": 8,
      "status": "Pending",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Interview Results")),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            // ================= LEADERBOARD =================
            Expanded(
              flex: 2,
              child: ListView.builder(
                itemCount: candidates.length,
                itemBuilder: (context, index) {
                  final c = candidates[index];

                  return ListTile(
                    leading: CircleAvatar(
                      child: Text(c["name"][0]),
                    ),
                    title: Text(c["name"]),
                    trailing: Text("${c["score"]}"),
                    selected: selectedIndex == index,
                    onTap: () {
                      setState(() {
                        selectedIndex = index;
                      });
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // ================= DETAIL =================
            if (selectedIndex != null)
              _buildDetailCard(candidates[selectedIndex!]),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(Map<String, dynamic> c) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        children: [
          Text(
            c["name"],
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          Text("Score: ${c["score"]}"),

          const SizedBox(height: AppSpacing.md),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _stat("Correct", c["correct"], Colors.green),
              _stat("Wrong", c["wrong"], Colors.red),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  onPressed: () {
                    _sendDecision("Accepted");
                  },
                  child: const Text("Accept"),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  onPressed: () {
                    _sendDecision("Rejected");
                  },
                  child: const Text("Reject"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          "$value",
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(label),
      ],
    );
  }

  void _sendDecision(String decision) {
    Get.defaultDialog(
      title: decision,
      middleText: "Decision sent (mock)",
      textConfirm: "OK",
      onConfirm: () => Get.back(),
    );
  }
}