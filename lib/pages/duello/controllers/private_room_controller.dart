import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../models/duel_enums.dart';
import '../../../../models/duel_match.dart';
import '../../../../services/firebase/firebase_duel_game_service.dart';
import '../duel_game_page.dart';

class PrivateRoomController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final _service = FirebaseDuelGameService();

  final currentTab = 0.obs; // 0: Create, 1: Join

  // Create Room variables
  final macroCategories = [
    "Mixed",
    "Programming",
    "Algorithms",
    "Data & AI",
    "Databases",
    "Systems",
    "Soft Skills",
  ];
  final selectedIndex = 0.obs;

  String get selectedCategory => macroCategories[selectedIndex.value];

  final generatedPassword = ''.obs;
  final isCreating = false.obs;

  // Join Room variables
  final joinPassword = ''.obs;
  final isJoining = false.obs;

  // Shared state once connected
  final match = Rxn<DuelMatch>();
  final isHost = false.obs;

  late AnimationController lockAnimController;
  late Animation<double> _scaleAnimation;
  final lockScale = 1.0.obs;

  StreamSubscription<DuelMatch>? _matchSubscription;

  @override
  void onInit() {
    super.onInit();

    lockAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.15).animate(
      CurvedAnimation(
        parent: lockAnimController,
        curve: Curves.easeInOut,
      ),
    );

    _scaleAnimation.addListener(() {
      lockScale.value = _scaleAnimation.value;
    });

    lockAnimController.repeat(reverse: true); // 🔥 LOOP
  }

  @override
  void onClose() {
    _matchSubscription?.cancel();
    _service.dispose();
    lockAnimController.dispose();
    _matchSubscription?.cancel();
    super.onClose();
  }

  void switchTab(int index) {
    currentTab.value = index;
    // Reset states when switching tabs
    generatedPassword.value = '';
    joinPassword.value = '';
    match.value = null;
    isHost.value = false;
  }

  void selectCategory(int index) {
    selectedIndex.value = index;
  }

  Future<void> createRoom() async {
    if (isCreating.value) return;
    isCreating.value = true;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in");

      final String finalUsername =
          (user.displayName != null && user.displayName!.trim().isNotEmpty)
              ? user.displayName!
              : (user.email?.split('@').first ?? 'Host');

      final result = await _service.createPrivateRoom(
        category: selectedCategory,
        userId: user.uid,
        username: finalUsername,
        avatarUrl: user.photoURL,
      );

      generatedPassword.value = result['password']!;
      isHost.value = true;

      // No need to query `joinPrivateRoom` since `createPrivateRoom` already places
      // the host into the `players` array. We just need the instantiated `matchId`.
      // The fastest way is to query the room, or we can just return it from creation.

      _listenToMatch(result['matchId']!);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to create room.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.white.withOpacity(0.15),
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
        borderRadius: 14,
      );
    } finally {
      isCreating.value = false;
    }
  }

  Future<void> joinRoom() async {
    if (isJoining.value) return;
    if (joinPassword.value.trim().isEmpty) {
      Get.snackbar(
        'Warning',
        'Please enter a valid room code.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.white.withOpacity(0.15),
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
        borderRadius: 14,
      );
      return;
    }

    isJoining.value = true;
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in");

      final String finalUsername =
          (user.displayName != null && user.displayName!.trim().isNotEmpty)
              ? user.displayName!
              : (user.email?.split('@').first ?? 'Player');

      final matchId = await _service.joinPrivateRoom(
        password: joinPassword.value.toUpperCase().trim(),
        userId: user.uid,
        username: finalUsername,
        avatarUrl: user.photoURL,
      );

      isHost.value = false;
      _listenToMatch(matchId);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to join room.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.white.withOpacity(0.15),
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
        borderRadius: 14,
      );
    } finally {
      isJoining.value = false;
    }
  }

  void _listenToMatch(String matchId) {
    _matchSubscription?.cancel();
    _matchSubscription = _service.listenToMatch(matchId).listen((updatedMatch) {
      match.value = updatedMatch;

      // If the match status changes to inProgress, navigate to game page!
      if (updatedMatch.status == DuelStatus.inProgress) {
        _matchSubscription?.cancel();
        Get.off(() => const DuelGamePage(), arguments: updatedMatch);
      }

      // Auto-start if max players reached
      if (isHost.value &&
          updatedMatch.players.length == 5 &&
          updatedMatch.status == DuelStatus.waiting) {
        startGame();
      }
    }, onError: (err) {
      Get.snackbar(
        'Error',
        'Connection lost.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.white.withOpacity(0.15),
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
        borderRadius: 14,
      );
    });
  }

  Future<void> startGame() async {
    if (!isHost.value) return;
    final currentMatch = match.value;
    if (currentMatch == null) return;
    if (currentMatch.players.length < 2) {
      Get.snackbar(
        'Warning',
        'At least 2 players are required to start.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.white.withOpacity(0.15),
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
        borderRadius: 14,
      );
      return;
    }

    try {
      await _service.startPrivateRoom(currentMatch.matchId);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to start the game.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.white.withOpacity(0.15),
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
        borderRadius: 14,
      );
    }
  }
}
