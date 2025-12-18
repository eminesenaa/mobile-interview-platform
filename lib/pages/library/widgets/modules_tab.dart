// ===================== File: lib/pages/library/widgets/modules_tab.dart =====================

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../constants/constants.dart';
import '../controllers/library_controller.dart';
import '../../practice/widgets/training_module_card.dart';
import 'empty_state.dart'; // Projenizde mevcut olan empty state widget'ı

class LibraryModulesTab extends StatelessWidget {
  const LibraryModulesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<LibraryController>();

    return Obx(() {
      // 1. Yükleniyor durumu (Backend'den veri bekleniyorsa)
      if (c.isLoadingModules.value) {
        return const Center(child: CircularProgressIndicator());
      }

      // 2. Filtrelenmiş ve backend'den gelmiş liste
      final items = c.filterModules(c.modules);

      // 3. Liste boş durumu
      if (items.isEmpty) {
        // Arama yapılıyorsa farklı, hiç veri yoksa farklı mesaj
        if (c.searchQuery.value.isNotEmpty) {
           return const LibraryEmptyState(
            title: 'No results found',
            subtitle: 'Try adjusting your search terms.',
            icon: Icons.search_off,
          );
        }
        
        return const LibraryEmptyState(
          title: 'No started plans',
          subtitle: 'Training plans you start will appear here.',
          icon: Icons.school_outlined,
        );
      }

      // 4. Modül listesi
      return ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        physics: const BouncingScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (_, i) {
          final module = items[i];
          
          // Controller üzerindeki Map'ten bu modülün progress verisini çekiyoruz
          final userProgress = c.modulesProgressMap[module.id];
          final progressRatio = userProgress?.progress ?? 0.0;

          return TrainingModuleCard(
            module: module,
            progress: progressRatio, // 🔥 Gerçek ilerleme yüzdesi buraya gidiyor
            onTap: () => c.navigateToModuleDetail(module),
          );
        },
      );
    });
  }
}