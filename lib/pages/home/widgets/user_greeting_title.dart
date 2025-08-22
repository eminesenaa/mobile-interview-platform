import 'package:flutter/material.dart';

/// AppBar başlığı: Kullanıcı avatarı + "Hi, Name!"
/// - photoUrl null ise default ikon gösterir.
/// - İleride UserController'dan beslenir.
class UserGreetingTitle extends StatelessWidget {
  final String name;
  final String? photoUrl;
  final VoidCallback? onAvatarTap;

  const UserGreetingTitle({
    super.key,
    required this.name,
    this.photoUrl,
    this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: onAvatarTap,
          borderRadius: BorderRadius.circular(20),
          child: CircleAvatar(
            radius: 18,
            backgroundColor:
            Theme.of(context).colorScheme.primary.withOpacity(.12),
            backgroundImage:
            photoUrl != null && photoUrl!.isNotEmpty ? NetworkImage(photoUrl!) : null,
            child: (photoUrl == null || photoUrl!.isEmpty)
                ? Icon(Icons.person, color: Theme.of(context).colorScheme.primary)
                : null,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'Hi, $name!',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
