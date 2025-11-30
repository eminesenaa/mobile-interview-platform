// ===================== File: modules_tab.dart =====================

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../constants/constants.dart';
import '../controllers/library_controller.dart';
import '../../practice/widgets/training_module_card.dart';
import 'empty_state.dart';

class LibraryModulesTab extends StatelessWidget {
  const LibraryModulesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<LibraryController>();

    // 🔥 All tabdaki mimarinin birebir aynısı
    return Obx(() {
      final items = c.filterModules(c.modules);

      if (items.isEmpty) {
        return const LibraryEmptyState(
          title: 'No modules yet',
          subtitle: 'Your saved training modules will appear here.',
          icon: Icons.school_outlined,
        );
      }

      return ListView.separated(
        // Düzeltme: ListView.separated padding'ini sadece yatay (horizontal) tutuyoruz.
        // Dikey (vertical) padding'i LibraryPage'deki TabBarView'ın üstündeki Padding yönetiyor.
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        physics: const BouncingScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, __) =>
        const SizedBox(height: AppSpacing.sm),
        itemBuilder: (_, i) {
          final m = items[i];
          return TrainingModuleCard(
            module: m,
            // Modül detayına gitme özelliği ekleniyor
            onTap: () => c.navigateToModuleDetail(m),
          );
        },
      );
    });
  }
}