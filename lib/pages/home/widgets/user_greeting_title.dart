import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../constants/colors.dart';
import '../../../constants/text_styles.dart';

/// Header: Kullanıcı avatarı + "Hi, Name!"
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
          return Text(
            "Yükleniyor...",
            style: AppTextStyles.bodySmall,
          );
        }
        if (snapshot.hasError) {
          return Text(
            "Hata oluştu",
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
          );
        }

        final name = snapshot.data?['name'] ?? 'Kullanıcı';
        final photoUrl = snapshot.data?['photoUrl'];

        return Row(
          children: [
            InkWell(
              onTap: onAvatarTap,
              borderRadius: BorderRadius.circular(20),
              child: CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.surfaceMuted,
                backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                    ? NetworkImage(photoUrl)
                    : null,
                child: (photoUrl == null || photoUrl.isEmpty)
                    ? PhosphorIcon(
                        PhosphorIcons.user(PhosphorIconsStyle.fill),
                        color: AppColors.primary,
                        size: 22,
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Hi, $name!',
              style: AppTextStyles.headline,
            ),
          ],
        );
      },
    );
  }
}
