import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants/text_styles.dart';
import '../../../widgets/app_avatar.dart';
import '../controllers/home_controller.dart';

/// Header: Kullanıcı avatarı + "Hi, Name!"
/// - photoUrl null ise default ikon gösterir.
/// - Firestore'dan giriş yapan kullanıcının "name" alanını çeker.
class UserGreetingTitle extends StatelessWidget {
  final VoidCallback? onAvatarTap;

  const UserGreetingTitle({
    super.key,
    this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    final hc = Get.find<HomeController>();

    return Obx(() {
      final user = hc.user.value;

      if (user == null) {
        return Text(
          "Loading...",
          style: AppTextStyles.bodySmall,
        );
      }

      return Row(
        children: [
          GestureDetector(
            onTap: onAvatarTap,
            child: AppAvatar(
              avatarPath: user.avatar,
              name: user.name,
              surname: user.surname,
              size: 40,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Hi, ${user.name}!',
            style: AppTextStyles.headline,
          ),
        ],
      );
    });
  }
}
