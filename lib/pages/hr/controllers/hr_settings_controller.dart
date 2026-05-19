import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HrSettingsController extends GetxController {
  final companyName = "Loading...".obs;
  final companyEmail = "Loading...".obs;

  @override
  void onInit() {
    super.onInit();
    _fetchHrInfo();
  }

  Future<void> _fetchHrInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      companyEmail.value = user.email ?? "";
      try {
        final doc = await FirebaseFirestore.instance.collection('hr_users').doc(user.uid).get();
        if (doc.exists) {
          final data = doc.data()!;
          final name = data['name'] ?? "";
          final surname = data['surname'] ?? "";
          final cName = data['companyName'] ?? "";

          if (cName == "Company" && name.isNotEmpty) {
            companyName.value = "$name $surname".trim();
          } else {
            companyName.value = cName.isNotEmpty ? cName : "Company Name";
          }
        }
      } catch (e) {
        print("Error fetching hr info: $e");
      }
    }
  }
}
