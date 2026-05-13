import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/streak.dart';

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
      }
    });
  }

  User? get user => firebaseUser.value;
}
