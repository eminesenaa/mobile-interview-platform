import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// AppBar başlığı: Kullanıcı avatarı + "Hi, Name!"
/// - photoUrl null ise default ikon gösterir.
/// - Firestore'dan giriş yapan kullanıcının "name" alanını çeker.
class UserGreetingTitle extends StatelessWidget {
  final VoidCallback? onAvatarTap;

  const UserGreetingTitle({
    super.key,
    this.onAvatarTap,
  });

  Future<Map<String, dynamic>> _getUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return {'name': 'Misafir', 'photoUrl': null};

    final snap =
        await FirebaseFirestore.instance.collection("users").doc(uid).get();
    final data = snap.data() ?? {};
    return {
      'name': data['name'] ?? 'Kullanıcı',
      'photoUrl': data['photoUrl'], // Firestore’da varsa avatar linki
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _getUserData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Yükleniyor...");
        }
        if (snapshot.hasError) {
          return const Text("Hata oluştu");
        }

        final name = snapshot.data?['name'] ?? 'Kullanıcı';
        final photoUrl = snapshot.data?['photoUrl'];

        return Row(
          children: [
            InkWell(
              onTap: onAvatarTap,
              borderRadius: BorderRadius.circular(20),
              child: CircleAvatar(
                radius: 18,
                backgroundColor:
                    Theme.of(context).colorScheme.primary.withOpacity(.12),
                backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                    ? NetworkImage(photoUrl)
                    : null,
                child: (photoUrl == null || photoUrl.isEmpty)
                    ? Icon(Icons.person,
                        color: Theme.of(context).colorScheme.primary)
                    : null,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Hi, $name!',
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
          ],
        );
      },
    );
  }
}
