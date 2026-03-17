import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../../../models/duel_enums.dart';
import '../../../../models/duel_match.dart';
import '../../../../services/firebase/firebase_duel_game_service.dart';
import '../duel_game_page.dart';

class PrivateRoomController extends GetxController {
  final _service = FirebaseDuelGameService();

  final currentTab = 0.obs; // 0: Create, 1: Join
  
  // Create Room variables
  final macroCategories = <String>[
    'Mixed',
    'Programming',
    'Algorithms',
    'Data & AI',
    'Systems',
    'Soft Skills',
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
  
  StreamSubscription<DuelMatch>? _matchSubscription;

  @override
  void onClose() {
    _matchSubscription?.cancel();
    _service.dispose();
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

      final String finalUsername = (user.displayName != null && user.displayName!.trim().isNotEmpty)
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
      Get.snackbar('Hata', 'Oda oluşturulamadı: $e', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isCreating.value = false;
    }
  }

  Future<void> joinRoom() async {
    if (isJoining.value) return;
    if (joinPassword.value.trim().isEmpty) {
      Get.snackbar('Uyarı', 'Lütfen geçerli bir şifre girin.', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isJoining.value = true;
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in");

      final String finalUsername = (user.displayName != null && user.displayName!.trim().isNotEmpty)
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
      Get.snackbar('Hata', 'Odaya katılamadı: $e', snackPosition: SnackPosition.BOTTOM);
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
      if (isHost.value && updatedMatch.players.length == 5 && updatedMatch.status == DuelStatus.waiting) {
        startGame();
      }
    }, onError: (err) {
      Get.snackbar('Hata', 'Bağlantı koptu: $err', snackPosition: SnackPosition.BOTTOM);
    });
  }

  Future<void> startGame() async {
    if (!isHost.value) return;
    final currentMatch = match.value;
    if (currentMatch == null) return;
    if (currentMatch.players.length < 2) {
      Get.snackbar('Uyarı', 'Oyunu başlatmak için en az 2 oyuncu olmalı.', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      await _service.startPrivateRoom(currentMatch.matchId);
    } catch (e) {
      Get.snackbar('Hata', 'Oyun başlatılamadı: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }
}
