import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/streak.dart';

class AuthController extends GetxController {
  final _auth = FirebaseAuth.instance;

  Rxn<User> firebaseUser = Rxn<User>();
  RxBool isLoading = true.obs;

  bool _streakChecked = false; // 🔥 SADECE 1 KEZ KONTROL

  @override
  void onInit() {
    super.onInit();

    firebaseUser.bindStream(_auth.authStateChanges());

    ever(firebaseUser, (User? user) async {
      isLoading.value = false;

      if (user != null) {
        print("✅ AuthController: Logged in as ${user.email}");

        // 🔥 STREAK KONTROLÜ – UYGULAMA AÇILIR AÇILMAZ
        if (!_streakChecked) {
          _streakChecked = true;

          await Streak.checkAndResetStreakIfNeeded(user.uid);
          print("🔥 Streak app start kontrolü yapıldı");
        }
      } else {
        print("✅ AuthController: Logged out");
        _streakChecked = false; // logout olursa tekrar izin ver
      }
    });
  }

  User? get user => firebaseUser.value;
}
