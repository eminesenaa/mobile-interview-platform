// ===================== File: lib/pages/library/library_page.dart =====================
// MODÜLER HALE GETİRİLMİŞ — SADE, ANLAŞILIR, HOME/PRACTICE STANDARDINA UYGUN

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:interview_project/pages/library/widgets/filter_chips_bar.dart';
import 'package:interview_project/pages/library/widgets/multi_select_bar.dart';
import '../../constants/constants.dart';

// Controller
import 'controllers/library_controller.dart';

// Yeni modüler widgetlar
import 'widgets/segmented_tab_bar.dart';
import 'widgets/search_bar.dart';
import 'widgets/all_tab.dart';
import 'widgets/collections_tab.dart';
import 'widgets/modules_tab.dart';

class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LibraryController());

    return Scaffold(
      backgroundColor: AppColors.background,

      // ========== Uygulama genel AppBar standardı ==========
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        title: Text(
          'My Library',
          style: AppTextStyles.headline,
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [
            // 🔥 KRİTİK DÜZELTME: Segmented Tab Bar ve Search Bar'ı
            Container(
              // Arka planı Scaffold'un App bar'ının rengiyle aynı yapın
              // (AppColors.surface, genelde beyaz).
              color: AppColors.surface,
              child: Column(
                mainAxisSize: MainAxisSize.min, // Sadece içeriği kadar yer kapla
                children: [
                  // ========== Üstteki segment tab ==========
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.md,
                      AppSpacing.md,
                      AppSpacing.sm,
                    ),
                    child: LibrarySegmentedTabBar(
                      controller: controller.tabController,
                    ),
                  ),

                  // ========== Arama barı ==========
                  const Padding(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      0,
                      AppSpacing.md,
                      AppSpacing.md,
                    ),
                    child: Column(
                      children: [
                        LibrarySearchBar(),
                        LibraryMultiSelectBar(),
                        LibraryFilterChipsBar(),
                      ],
                    ),

                  ),
                ],
              ),
            ),

            // ========== İçerik (TabBarView) ==========
            // 🔥 KRİTİK: Üst padding eklendi (scroll artık header'ın altından başlıyor)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: TabBarView(
                  controller: controller.tabController,
                  physics: const BouncingScrollPhysics(),
                  children: const [
                    LibraryAllTab(),
                    LibraryCollectionsTab(),
                    LibraryModulesTab(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
