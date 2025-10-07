// ===================== File: lib/pages/home/progress_page.dart =====================
// Purpose: Kullanıcının ilerlemesini gösterir (XP, Level, Accuracy, Streak, vb.)
// Data: ProgressController + Firestore streak listener
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:interview_project/controllers/progress_controller.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  final pc = Get.find<ProgressController>();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Rxn<Map<String, dynamic>> streakData = Rxn<Map<String, dynamic>>();

  @override
  void initState() {
    super.initState();
    _listenToStreak();
  }

  void _listenToStreak() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    _db.collection('users').doc(uid).snapshots().listen((doc) {
      if (doc.exists) {
        final data = doc.data();
        if (data != null && data['streak'] != null) {
          streakData.value = Map<String, dynamic>.from(data['streak']);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Progress')),
      body: Obx(() {
        final p = pc.progress.value;

        final xpInLevel = p.xpInLevel;
        final xpCap = p.xpCapInLevel;
        final levelProgress = p.levelProgress;

        final accuracy = p.questionStats.total == 0
            ? "0"
            : ((p.questionStats.accuracy) * 100).toStringAsFixed(0);

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ---- Level Progress ----
            Text(
              'Level ${p.level} • $xpInLevel/$xpCap XP',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: LinearProgressIndicator(
                value: levelProgress.clamp(0, 1),
                minHeight: 14,
                backgroundColor: Colors.grey[300],
              ),
            ),
            const SizedBox(height: 20),

            // ---- Quick Stats ----
            Text('Quick Stats',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _StatPill(label: 'Total XP', value: '${pc.totalXp.value}'),
                _StatPill(label: 'Today', value: '+${p.todayEarnedXp} XP'),
                _StatPill(label: 'This Week', value: '+${p.weeklyEarnedXp} XP'),
                _StatPill(label: 'Accuracy', value: '$accuracy%'),
                _StatPill(
                  label: 'Solved',
                  value:
                      '${p.questionStats.correct}/${p.questionStats.total}',
                ),

                // 🔥 Firestore’dan Streak
                Obx(() {
                  final s = streakData.value;
                  if (s == null) {
                    return const _StatPill(label: 'Streak', value: '—');
                  }
                  final count = s['streakCount'] ?? 0;
                  final longest = s['longestStreak'] ?? 0;
                  return _StatPill(
                    label: 'Streak',
                    value: '$count 🔥 (max $longest)',
                  );
                }),

                _StatPill(label: 'Saved', value: '${pc.savedCount.value}'),
              ],
            ),
          ],
        );
      }),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  const _StatPill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: Theme.of(context).dividerColor.withOpacity(.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value,
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
          const SizedBox(width: 8),
          Text(label, style: Theme.of(context).textTheme.labelLarge),
        ],
      ),
    );
  }
}
