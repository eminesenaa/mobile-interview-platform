import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:interview_project/constants/colors.dart';
import 'package:interview_project/pages/profile/profile_settings_page.dart';
import 'package:interview_project/pages/profile/widgets/wave_clipper.dart';
import 'controllers/profile_controller.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(ProfileController());

    const headerColor = primaryColor;

    return Scaffold(
      backgroundColor: headlineColor,
      appBar: AppBar(
        backgroundColor: headerColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () => Get.to(() => const ProfileSettingsPage()),
          ),
        ],
      ),
      body: Obx(() {
        if (c.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (c.error.value != null) {
          return Center(child: Text('Error: ${c.error.value}'));
        }

        final fullName = '${c.name.value} ${c.surname.value}'.trim();

        return SingleChildScrollView(
          child: Column(
            children: [
              // HEADER ALANI
              ClipPath(
                clipper: WaveClipper(),
                child: Container(
                  width: double.infinity,
                  color: headerColor,
                  padding: const EdgeInsets.symmetric(vertical: 48),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // --- PROFİL RESMİ + KAMERA BUTONU ---
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.white,
                            backgroundImage: (c.photoUrl.value != null &&
                                c.photoUrl.value!.isNotEmpty)
                                ? NetworkImage(c.photoUrl.value!)
                                : null,
                            child: (c.photoUrl.value == null ||
                                    c.photoUrl.value!.isEmpty)
                                ? const Icon(Icons.person,
                                    size: 40, color: Colors.black45)
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () async {
                                await c.pickAndUploadProfilePhoto();
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                                child: const Icon(Icons.camera_alt,
                                    size: 18, color: Colors.blue),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        fullName.isEmpty ? 'Guest' : fullName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Level ${c.level.value}',
                        style: const TextStyle(
                          color: Colors.white70, // isim beyaz, level daha grimsi
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          letterSpacing: .2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // BEYAZ İÇERİK
              Container(
                width: double.infinity,
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // örnek içerikler
                    Row(
                      children: [
                        _StatBox(
                            title: "Level",
                            value: "${c.level.value}",
                            icon: Icons.emoji_events),
                        const SizedBox(width: 12),
                        _StatBox(
                            title: "Total XP",
                            value: "${c.totalXp.value}",
                            icon: Icons.bolt),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text("Actions",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    ListTile(
                      leading: const Icon(Icons.query_stats_rounded),
                      title: const Text("View Detailed Progress"),
                      subtitle:
                          const Text("Open the full analytics dashboard"),
                      onTap: c.goToProgress,
                    ),
                    ListTile(
                      leading: const Icon(Icons.assignment_turned_in_rounded),
                      title: const Text("Interview Results"),
                      subtitle:
                          const Text("See results submitted by companies"),
                      onTap: c.goToInterviewResults,
                    ),
                    ListTile(
                      leading: const Icon(Icons.edit_rounded),
                      title: const Text("Edit Profile"),
                      subtitle:
                          const Text("Name, email, username, password"),
                      onTap: () => Get.to(() => const ProfileSettingsPage()),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  const _StatBox({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20),
            const SizedBox(height: 4),
            Text(value,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            Text(title,
                style: const TextStyle(
                    fontSize: 12, color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}
