import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/streak.dart';

import '../pages/profile/controllers/profile_controller.dart';
import 'progress_controller.dart';
import '../pages/home/controllers/home_controller.dart';
import '../pages/interview/controllers/interview_dashboard_controller.dart';
import '../pages/hr/controllers/hr_dashboard_controller.dart';
import '../pages/hr/controllers/hr_interviews_controller.dart';
import '../pages/hr/controllers/hr_job_postings_controller.dart';
import '../pages/hr/controllers/hr_settings_controller.dart';
import '../pages/interview/controllers/applications_controller.dart';
import '../pages/interview/controllers/interview_results_controller.dart';
import '../pages/home/controllers/leaderboard_controller.dart';
import 'bookmark_controller.dart';
import '../pages/practice/controllers/practice_controller.dart';
import '../pages/library/controllers/library_controller.dart';

class AuthController extends GetxController {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  Rxn<User> firebaseUser = Rxn<User>();
  RxBool isLoading = true.obs;
  RxBool isHr = false.obs;

  bool _streakChecked = false; // 🔥 SADECE 1 KEZ KONTROL

  @override
  void onInit() {
    super.onInit();

    firebaseUser.bindStream(_auth.authStateChanges());

    ever(firebaseUser, (User? user) async {
      if (user != null) {
        isLoading.value = true; // Rol kontrolü bitene kadar loading
        print("✅ AuthController: Logged in as ${user.email}");

        // 1. HR kontrolü yap
        final hrDoc = await _db.collection("hr_users").doc(user.uid).get();
        isHr.value = hrDoc.exists;

        // 2. Streak kontrolü (Sadece adaylar için)
        if (!isHr.value && !_streakChecked) {
          _streakChecked = true;
          await Streak.checkAndResetStreakIfNeeded(user.uid);
          print("🔥 Streak app start kontrolü yapıldı");
        }
        
        isLoading.value = false;
      } else {
        print("✅ AuthController: Logged out");
        isHr.value = false;
        _streakChecked = false;
        isLoading.value = false;
        clearUserControllers();
      }
    });
  }

  void clearUserControllers() {
    try { Get.delete<ProfileController>(force: true); } catch (_) {}
    try { Get.delete<ProgressController>(force: true); } catch (_) {}
    try { Get.delete<HomeController>(force: true); } catch (_) {}
    try { Get.delete<InterviewDashboardController>(force: true); } catch (_) {}
    try { Get.delete<HRDashboardController>(force: true); } catch (_) {}
    try { Get.delete<HRInterviewsController>(force: true); } catch (_) {}
    try { Get.delete<HrJobPostingsController>(force: true); } catch (_) {}
    try { Get.delete<HrSettingsController>(force: true); } catch (_) {}
    try { Get.delete<ApplicationsController>(force: true); } catch (_) {}
    try { Get.delete<InterviewResultsController>(force: true); } catch (_) {}
    try { Get.delete<LeaderboardController>(force: true); } catch (_) {}
    try { Get.delete<BookmarkController>(force: true); } catch (_) {}
    try { Get.delete<PracticeController>(force: true); } catch (_) {}
    try { Get.delete<LibraryController>(force: true); } catch (_) {}
    print("🧹 [Auth] Cleared all user-specific controllers from memory.");
  }

  User? get user => firebaseUser.value;
}
