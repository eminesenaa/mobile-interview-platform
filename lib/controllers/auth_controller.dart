import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthController extends GetxController {
  final _auth = FirebaseAuth.instance;

  Rxn<User> firebaseUser = Rxn<User>();
  RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    firebaseUser.bindStream(_auth.authStateChanges());

    ever(firebaseUser, (user) {
      isLoading.value = false;
      if (user != null) {
        print("✅ AuthController: Logged in as ${user.email}");
      } else {
        print("✅ AuthController: Logged out");
      }
    });
  }

  User? get user => firebaseUser.value;
}
