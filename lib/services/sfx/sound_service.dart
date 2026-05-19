//  --------------- DOCUMENTATION ----------------
//
// HOW TO ADD A NEW SOUND EFFECT:
//
//  STEP 1: Drop your .mp3 file into:
//              assets/sfx/your_sound.mp3
//  STEP 2: Register it in the SoundEffect enum at the bottom of this file:
//              enum SoundEffect {
//                timerWarning('sfx/timer_warning.mp3'),
//                correctAnswer('sfx/correct.mp3'),
//                wrongAnswer('sfx/wrong.mp3'),
//                yourSound('sfx/your_sound.mp3'), ← add here
//              }
//  STEP 3: (Optional) Override its default config:
//              SoundService.configure(
//                effect: SoundEffect.yourSound,
//                config: SoundConfig(volume: 0.5, cooldownMs: 200),
//              );
//  STEP 4: Play it anywhere in the codebase:
//              ...
//              await SoundService.play(SoundEffect.yourSound);
//              ...
//
// GLOBAL CONTROLS
//
//  Enable / disable all sounds:
//    SoundService.setEnabled(false);   // mute
//    SoundService.setEnabled(true);    // unmute
//
//  Change master volume (0.0 – 1.0):
//    SoundService.setVolume(0.75);
//
//  Stop whatever is currently playing:
//    await SoundService.stop();
//
//  Release resources on app exit:
//    SoundService.dispose();
//
//  Reinitialize after dispose (e.g. after login/logout cycle):
//    SoundService.reinitialize();
//
//  Persist user preferences to disk:
//    await SoundService.persistPreferences();
//
//  Load saved preferences on startup:
//    await SoundService.loadPreferences();
//
//  Pre-cache all sound assets to avoid first-play stutter:
//    await SoundService.warmUp();
//
//  Play a looping sound (e.g. ambient, heartbeat):
//    await SoundService.playLooping(SoundEffect.timerWarning);
//    await SoundService.stopLoop();
//
//  Mute / unmute an entire sound category:
//    SoundService.setCategoryEnabled(SoundCategory.feedback, false);
//
// -------------- IMPORTANT NOTES ---------------
//
//  - Sound files MUST be in .mp3 format for cross-platform compatibility.
//
//  - Keep individual file sizes under 500 KB to avoid frame-drops on low-end
//    devices. Use tools like FFmpeg to compress if needed:
//      ffmpeg -i input.wav -b:a 64k output.mp3
//
//  - File names must NOT contain Turkish characters or spaces. Use underscores.
//
//  - The service uses an audio pool (default: 4 players) to support overlapping
//    sounds. Rapid successive calls no longer cut off previous audio.
//
//  - Cooldown is enforced per SoundEffect to prevent event-spam (e.g. a timer
//    tick firing every 100 ms). Default cooldown is 80 ms.
//
//  - The fade engine uses a secondary AudioPlayer so fade operations never
//    interrupt the main playback channel.
//
//  - The play queue is FIFO. Items respect cooldown and global enabled state
//    at the moment they are dequeued, not when they were originally enqueued.
//
//  - Haptic feedback is best-effort. Unsupported platforms silently ignore it.
//
//  - User preferences (enabled, volume, haptic) are persisted via
//    SharedPreferences. Call [loadPreferences] once at app startup and
//    [persistPreferences] whenever you change a setting.

import 'dart:async';
import 'dart:math' as math;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ──────────────────────────────────────────────
//  Sound Category
// ──────────────────────────────────────────────

/// Logical grouping for sound effects.
/// Use [SoundService.setCategoryEnabled] to mute / unmute an entire category
/// without touching individual effect configs.
enum SoundCategory {
  /// Short UI interaction sounds (button taps, swipes, toggles).
  ui,

  /// Result-oriented feedback (correct / wrong answer, achievement).
  feedback,

  /// Ambient or atmospheric loops (heartbeat countdown, background hum).
  ambient,

  /// Alerts and notifications (timer warning, error tone).
  notification,
}

// ──────────────────────────────────────────────
//  Haptic Pattern
// ──────────────────────────────────────────────

/// Vibration intensity played alongside a sound effect.
enum HapticPattern {
  none,
  light,
  medium,
  heavy,
  selection,
  doubleMedium,
  tripleAscending,
}

// ──────────────────────────────────────────────
//  Fade Curve
// ──────────────────────────────────────────────

/// Volume ramp shape applied during fade-in / fade-out operations.
enum FadeCurve {
  linear,
  easeIn,
  easeOut,
  easeInOut,
}

// ──────────────────────────────────────────────
//  Configuration
// ──────────────────────────────────────────────

/// Pass an instance of [SoundConfig] to [SoundService.configure] to override
/// per-effect settings, or set the master volume via [SoundService.setVolume].

class SoundConfig {

  /// Audio playback volume for this particular effect (0.0 – 1.0).
  final double volume;

  /// Minimum milliseconds that must elapse between two consecutive plays of
  /// the same [SoundEffect]. Calls arriving sooner than this threshold are
  /// silently dropped. Useful for rapid-fire events like button taps.
  final int cooldownMs;

  /// Whether this specific effect is enabled, regardless of the global toggle.
  /// Set to [false] to permanently silence a single effect without touching
  /// any other configuration.
  final bool effectEnabled;

  /// Duration of the fade-in ramp used by [SoundService.playWithFade].
  final Duration fadeInDuration;

  /// Duration of the fade-out ramp used by [SoundService.fadeOutAndStop].
  final Duration fadeOutDuration;

  /// Haptic pattern fired alongside [SoundService.play].
  final HapticPattern hapticPattern;

  /// When true, effect is queued instead of interrupting the current sound.
  final bool queueIfBusy;

  /// The logical category this effect belongs to. Category-level mute/unmute
  /// is checked at play time alongside the global and per-effect toggles.
  final SoundCategory category;

  /// Whether this effect should use a dedicated pool player (concurrent) or
  /// the primary shared player. When [true] the effect will never interrupt
  /// other currently-playing sounds.
  final bool concurrent;

  const SoundConfig({
    this.volume = 1.0,
    this.cooldownMs = 80,
    this.effectEnabled = true,
    this.fadeInDuration = const Duration(milliseconds: 150),
    this.fadeOutDuration = const Duration(milliseconds: 200),
    this.hapticPattern = HapticPattern.medium,
    this.queueIfBusy = false,
    this.category = SoundCategory.feedback,
    this.concurrent = false,
  });

  /// Returns a copy of this config with the given fields overridden.
  SoundConfig copyWith({
    double? volume,
    int? cooldownMs,
    bool? effectEnabled,
    Duration? fadeInDuration,
    Duration? fadeOutDuration,
    HapticPattern? hapticPattern,
    bool? queueIfBusy,
    SoundCategory? category,
    bool? concurrent,
  }) {
    return SoundConfig(
      volume: volume ?? this.volume,
      cooldownMs: cooldownMs ?? this.cooldownMs,
      effectEnabled: effectEnabled ?? this.effectEnabled,
      fadeInDuration: fadeInDuration ?? this.fadeInDuration,
      fadeOutDuration: fadeOutDuration ?? this.fadeOutDuration,
      hapticPattern: hapticPattern ?? this.hapticPattern,
      queueIfBusy: queueIfBusy ?? this.queueIfBusy,
      category: category ?? this.category,
      concurrent: concurrent ?? this.concurrent,
    );
  }

  @override
  String toString() =>
      'SoundConfig(volume: $volume, cooldownMs: $cooldownMs, '
      'effectEnabled: $effectEnabled, category: ${category.name}, '
      'fadeIn: ${fadeInDuration.inMilliseconds}ms, '
      'fadeOut: ${fadeOutDuration.inMilliseconds}ms, '
      'haptic: ${hapticPattern.name}, queueIfBusy: $queueIfBusy, '
      'concurrent: $concurrent)';
}

// ──────────────────────────────────────────────
//  Internal – Structured Logger
// ──────────────────────────────────────────────

/// Lightweight structured-logging helper used only inside [SoundService].
/// In debug builds, messages are printed via [debugPrint] (throttled).
/// In release builds, all output is suppressed automatically.

class _SoundLogger {
  const _SoundLogger._();

  // Change to false to suppress all SoundService logs even in debug builds.
  static const bool _loggingEnabled = true;

  static void info(String message) =>
      _write('ℹ️ [SoundService]', message);

  static void warn(String message) =>
      _write('⚠️ [SoundService]', message);

  static void error(String message, [Object? err]) {
    _write('❌ [SoundService]', err != null ? '$message | $err' : message);
  }

  static void _write(String prefix, String message) {
    if (kDebugMode && _loggingEnabled) {
      debugPrint('$prefix $message');
    }
  }
}

// ──────────────────────────────────────────────
//  Internal – Cooldown Tracker
// ──────────────────────────────────────────────

/// Tracks the last-played timestamp for each [SoundEffect] to enforce
/// per-effect cooldowns. Stored as epoch-milliseconds for minimal overhead.
class _SoundCooldown {

  _SoundCooldown._();

  static final Map<SoundEffect, int> _lastPlayed = {};

  /// Returns [true] if [effect] may be played right now (cooldown elapsed).
  static bool canPlay(SoundEffect effect, int cooldownMs) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final last = _lastPlayed[effect] ?? 0;
    return (now - last) >= cooldownMs;
  }

  /// Records the current timestamp as the last-played time for [effect].
  static void record(SoundEffect effect) {
    _lastPlayed[effect] = DateTime.now().millisecondsSinceEpoch;
  }

  /// Clears the cooldown state for a specific [effect], allowing it to play
  /// immediately on the next call regardless of elapsed time.
  static void reset(SoundEffect effect) {
    _lastPlayed.remove(effect);
  }

  /// Clears cooldown state for all registered effects.
  static void resetAll() {
    _lastPlayed.clear();
  }

  /// Returns remaining cooldown in ms for [effect]. Returns 0 if ready.
  static int remainingMs(SoundEffect effect, int cooldownMs) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final last = _lastPlayed[effect] ?? 0;
    final elapsed = now - last;
    return elapsed >= cooldownMs ? 0 : cooldownMs - elapsed;
  }

}

// ──────────────────────────────────────────────
//  Internal – Audio Pool (Concurrent Playback)
// ──────────────────────────────────────────────

/// A round-robin pool of [AudioPlayer] instances that enables overlapping
/// sound effects. When a caller requests a player, the pool returns the next
/// idle one. If all players are busy, the oldest one is recycled (its current
/// audio is stopped first).
///
/// The pool size is configurable but defaults to [_defaultPoolSize].

class _AudioPool {

  _AudioPool._();

  static const int _defaultPoolSize = 4;

  static final List<AudioPlayer> _players = [];
  static int _nextIndex = 0;
  static bool _initialized = false;

  /// Creates the underlying player instances. Safe to call multiple times;
  /// subsequent calls are no-ops if the pool is already live.
  static void initialize({int size = _defaultPoolSize}) {
    if (_initialized) return;
    for (int i = 0; i < size; i++) {
      _players.add(AudioPlayer());
    }
    _initialized = true;
    _SoundLogger.info('Audio pool initialized with $size players.');
  }

  /// Returns the next [AudioPlayer] in round-robin order.
  /// Callers should [stop] it before playing if needed.
  static AudioPlayer acquire() {
    if (!_initialized) initialize();
    final player = _players[_nextIndex % _players.length];
    _nextIndex++;
    return player;
  }

  /// Returns all pool players for warm-up purposes.
  static List<AudioPlayer> get allPlayers {
    if (!_initialized) initialize();
    return List.unmodifiable(_players);
  }

  /// Returns the number of players currently in the [PlayerState.playing] state.
  static int get activePlayers {
    int count = 0;
    for (final p in _players) {
      if (p.state == PlayerState.playing) count++;
    }
    return count;
  }

  /// Stops all pool players.
  static Future<void> stopAll() async {
    for (final p in _players) {
      try {
        await p.stop();
      } catch (_) {}
    }
  }

  /// Releases every player in the pool.
  static void dispose() {
    for (final p in _players) {
      try {
        p.dispose();
      } catch (_) {}
    }
    _players.clear();
    _nextIndex = 0;
    _initialized = false;
  }

  /// Recreates the pool after a [dispose] call.
  static void reinitialize({int size = _defaultPoolSize}) {
    dispose();
    _initialized = false;
    initialize(size: size);
  }
}

// ──────────────────────────────────────────────
//  Internal – Fade Engine
// ──────────────────────────────────────────────

/// Performs smooth volume ramps on a dedicated [AudioPlayer].
/// Volume is stepped at [_stepIntervalMs]-ms intervals using a [Timer.periodic].
class _FadeEngine {

  _FadeEngine._();

  static AudioPlayer _fadePlayer = AudioPlayer();

  // 16 ms ≈ 60 fps. Smaller = smoother but more timer overhead.
  static const int _stepIntervalMs = 16;

  static Timer? _activeTimer;

  /// Starts [effect] on the fade player at volume 0, ramps up to
  /// [targetVolume] over [duration].
  static Future<void> fadeIn({
    required SoundEffect effect,
    required double targetVolume,
    required Duration duration,
    FadeCurve curve = FadeCurve.linear,
  }) async {
    _cancelActive();

    await _fadePlayer.stop();
    await _fadePlayer.setVolume(0.0);
    await _fadePlayer.play(AssetSource(effect.path));

    final steps = math.max(1, duration.inMilliseconds ~/ _stepIntervalMs);
    int currentStep = 0;

    _activeTimer = Timer.periodic(
      Duration(milliseconds: _stepIntervalMs),
      (timer) async {
        currentStep++;
        final t = currentStep / steps;
        final vol = (_applyCurve(t, curve) * targetVolume).clamp(0.0, 1.0);
        await _fadePlayer.setVolume(vol);
        if (currentStep >= steps) {
          timer.cancel();
        }
      },
    );
  }

  /// Ramps the fade player's volume down to 0 over [duration], then stops
  /// playback.
  static Future<void> fadeOut({
    required Duration duration,
    double fromVolume = 1.0,
    FadeCurve curve = FadeCurve.linear,
  }) async {
    _cancelActive();

    final steps = math.max(1, duration.inMilliseconds ~/ _stepIntervalMs);
    int currentStep = 0;
    final completer = Completer<void>();

    _activeTimer = Timer.periodic(
      Duration(milliseconds: _stepIntervalMs),
      (timer) async {
        currentStep++;
        final t = currentStep / steps;
        final vol = (fromVolume * (1.0 - _applyCurve(t, curve))).clamp(0.0, 1.0);
        await _fadePlayer.setVolume(vol);
        if (currentStep >= steps) {
          timer.cancel();
          await _fadePlayer.stop();
          if (!completer.isCompleted) completer.complete();
        }
      },
    );

    return completer.future;
  }

  /// Maps a linear [t] ∈ [0,1] through the selected [curve].
  static double _applyCurve(double t, FadeCurve curve) {
    switch (curve) {
      case FadeCurve.linear:
        return t.clamp(0.0, 1.0);
      case FadeCurve.easeIn:
        return (t * t).clamp(0.0, 1.0);
      case FadeCurve.easeOut:
        return (1.0 - (1.0 - t) * (1.0 - t)).clamp(0.0, 1.0);
      case FadeCurve.easeInOut:
        return (t * t * (3.0 - 2.0 * t)).clamp(0.0, 1.0);
    }
  }

  static void _cancelActive() {
    if (_activeTimer?.isActive ?? false) _activeTimer!.cancel();
  }

  /// Releases the fade player. Called from [SoundService.dispose].
  static void dispose() {
    _cancelActive();
    _fadePlayer.dispose();
  }

  /// Recreates the fade player after a [dispose] call.
  static void reinitialize() {
    _fadePlayer = AudioPlayer();
  }
}

// ──────────────────────────────────────────────
//  Internal – Play Queue
// ──────────────────────────────────────────────

/// FIFO queue for sequential sound playback.
/// Items are played one after the other using [AudioPlayer.onPlayerComplete].
class _SoundQueue {

  _SoundQueue._();

  static final List<_QueueItem> _items = [];
  static bool _isProcessing = false;
  static StreamSubscription<void>? _completionSub;

  /// Adds [effect] to the back of the queue.
  static void enqueue(SoundEffect effect, {SoundConfig? configOverride}) {
    _items.add(_QueueItem(effect: effect, configOverride: configOverride));
    _maybeStartProcessing();
  }

  /// Removes all pending items from the queue without affecting what is
  /// currently playing.
  static void clear() {
    _items.clear();
  }

  /// Returns the number of effects waiting in the queue.
  static int get length => _items.length;

  /// Returns true if there are no pending effects.
  static bool get isEmpty => _items.isEmpty;

  /// Returns an unmodifiable snapshot of the queue's current contents.
  static List<SoundEffect> get snapshot =>
      List.unmodifiable(_items.map((i) => i.effect));

  static void _maybeStartProcessing() {
    if (_isProcessing || _items.isEmpty) return;
    _processNext();
  }

  static Future<void> _processNext() async {
    if (_items.isEmpty) {
      _isProcessing = false;
      return;
    }
    _isProcessing = true;

    final item = _items.removeAt(0);

    // Delegate to the main service so all guards (enabled, cooldown, etc.)
    // apply.
    await SoundService._playInternal(
      item.effect,
      configOverride: item.configOverride,
    );

    _completionSub?.cancel();
    _completionSub = SoundService._player.onPlayerComplete.listen((_) {
      _completionSub?.cancel();
      _processNext();
    });
  }

  static void dispose() {
    _completionSub?.cancel();
    _items.clear();
    _isProcessing = false;
  }
}

class _QueueItem {
  const _QueueItem({required this.effect, this.configOverride});
  final SoundEffect effect;
  final SoundConfig? configOverride;
}

// ──────────────────────────────────────────────
//  Internal – Haptic Engine
// ──────────────────────────────────────────────

/// Fires the appropriate [HapticFeedback] call for a given [HapticPattern].
/// All calls are wrapped in a try-catch so platforms lacking vibration support
/// never throw.
class _HapticEngine {

  _HapticEngine._();

  static Future<void> trigger(HapticPattern pattern) async {
    try {
      switch (pattern) {
        case HapticPattern.none:
          return;
        case HapticPattern.light:
          await HapticFeedback.lightImpact();
        case HapticPattern.medium:
          await HapticFeedback.mediumImpact();
        case HapticPattern.heavy:
          await HapticFeedback.heavyImpact();
        case HapticPattern.selection:
          await HapticFeedback.selectionClick();
        case HapticPattern.doubleMedium:
          await HapticFeedback.mediumImpact();
          await Future<void>.delayed(const Duration(milliseconds: 80));
          await HapticFeedback.mediumImpact();
        case HapticPattern.tripleAscending:
          await HapticFeedback.lightImpact();
          await Future<void>.delayed(const Duration(milliseconds: 70));
          await HapticFeedback.mediumImpact();
          await Future<void>.delayed(const Duration(milliseconds: 70));
          await HapticFeedback.heavyImpact();
      }
    } catch (e) {
      _SoundLogger.error('Haptic feedback failed.', e);
    }
  }
}

// ──────────────────────────────────────────────
//  Internal – Looping Engine
// ──────────────────────────────────────────────

/// Manages a dedicated [AudioPlayer] for looping playback. Only one loop can
/// be active at a time — calling [start] while a loop is running replaces it.
class _LoopEngine {

  _LoopEngine._();

  static AudioPlayer _loopPlayer = AudioPlayer();
  static SoundEffect? _currentEffect;
  static StreamSubscription<void>? _completeSub;

  /// Starts [effect] in a continuous loop at [volume].
  static Future<void> start(SoundEffect effect, double volume) async {
    await stop();
    _currentEffect = effect;

    await _loopPlayer.setVolume(volume.clamp(0.0, 1.0));
    await _loopPlayer.setReleaseMode(ReleaseMode.loop);
    await _loopPlayer.play(AssetSource(effect.path));

    _SoundLogger.info('Loop started: ${effect.name}');
  }

  /// Stops the current loop, if any.
  static Future<void> stop() async {
    _completeSub?.cancel();
    _completeSub = null;
    if (_currentEffect != null) {
      try {
        await _loopPlayer.stop();
        await _loopPlayer.setReleaseMode(ReleaseMode.release);
      } catch (e) {
        _SoundLogger.error('Failed to stop loop.', e);
      }
      _SoundLogger.info('Loop stopped: ${_currentEffect!.name}');
      _currentEffect = null;
    }
  }

  /// Adjusts the loop volume on-the-fly without restarting the loop.
  static Future<void> setVolume(double volume) async {
    await _loopPlayer.setVolume(volume.clamp(0.0, 1.0));
  }

  /// Returns the currently-looping effect, or null if nothing is looping.
  static SoundEffect? get currentEffect => _currentEffect;

  /// Returns true if a loop is currently active.
  static bool get isLooping => _currentEffect != null;

  /// Releases the loop player. Called from [SoundService.dispose].
  static void dispose() {
    _completeSub?.cancel();
    _completeSub = null;
    _currentEffect = null;
    _loopPlayer.dispose();
  }

  /// Recreates the loop player after a [dispose] call.
  static void reinitialize() {
    _loopPlayer = AudioPlayer();
    _currentEffect = null;
  }
}

// ──────────────────────────────────────────────
//  Internal – Preferences Persistence
// ──────────────────────────────────────────────

/// Handles reading and writing user sound preferences to
/// [SharedPreferences]. Keys are prefixed with `sound_` to avoid collisions.
class _SoundPrefs {

  _SoundPrefs._();

  static const String _keyEnabled = 'sound_enabled';
  static const String _keyVolume = 'sound_master_volume';
  static const String _keyHaptic = 'sound_haptic_enabled';
  static const String _keyCategoryPrefix = 'sound_category_';

  /// Saves the current user preferences to disk.
  static Future<void> save({
    required bool enabled,
    required double masterVolume,
    required bool hapticEnabled,
    required Map<SoundCategory, bool> categoryStates,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyEnabled, enabled);
      await prefs.setDouble(_keyVolume, masterVolume);
      await prefs.setBool(_keyHaptic, hapticEnabled);

      for (final entry in categoryStates.entries) {
        await prefs.setBool(
          '$_keyCategoryPrefix${entry.key.name}',
          entry.value,
        );
      }

      _SoundLogger.info('Preferences saved to disk.');
    } catch (e) {
      _SoundLogger.error('Failed to save preferences.', e);
    }
  }

  /// Loads previously saved preferences and returns them as a map.
  /// Returns null for each field that has no stored value (first launch).
  static Future<_LoadedPrefs> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final categoryStates = <SoundCategory, bool>{};
      for (final cat in SoundCategory.values) {
        final val = prefs.getBool('$_keyCategoryPrefix${cat.name}');
        if (val != null) categoryStates[cat] = val;
      }

      return _LoadedPrefs(
        enabled: prefs.getBool(_keyEnabled),
        masterVolume: prefs.getDouble(_keyVolume),
        hapticEnabled: prefs.getBool(_keyHaptic),
        categoryStates: categoryStates,
      );
    } catch (e) {
      _SoundLogger.error('Failed to load preferences.', e);
      return const _LoadedPrefs();
    }
  }
}

/// Container for values read from [SharedPreferences].
/// Fields are nullable to distinguish "not yet set" from an explicit value.
class _LoadedPrefs {
  final bool? enabled;
  final double? masterVolume;
  final bool? hapticEnabled;
  final Map<SoundCategory, bool> categoryStates;

  const _LoadedPrefs({
    this.enabled,
    this.masterVolume,
    this.hapticEnabled,
    this.categoryStates = const {},
  });
}

// ══════════════════════════════════════════════
//  SoundService  (Public API)
// ══════════════════════════════════════════════

/// Centralized, singleton-style service for playing UI sound effects.
/// All methods are static so no instantiation or injection is required.

/// Play a one-shot sound effect
/// await SoundService.play(SoundEffect.correctAnswer);

/// Silence all sounds (e.g. user toggled the mute button)
/// SoundService.setEnabled(false);

/// Restore sounds
/// SoundService.setEnabled(true);

/// Query current mute state
/// if (SoundService.isEnabled) { … }

/// Change master volume
/// SoundService.setVolume(0.6);

/// Stop whatever is currently playing
/// await SoundService.stop();

/// Play with fade-in
/// await SoundService.playWithFade(SoundEffect.correctAnswer);

/// Cross-fade between two effects
/// await SoundService.crossFade(from: SoundEffect.timerWarning, to: SoundEffect.correctAnswer);

/// Enqueue multiple sounds to play back-to-back
/// SoundService.enqueue([SoundEffect.timerWarning, SoundEffect.correctAnswer]);

/// Play a looping ambient sound
/// await SoundService.playLooping(SoundEffect.timerWarning);

/// Trigger haptic independently of any sound
/// await SoundService.triggerHaptic(HapticPattern.heavy);

/// Persist user preferences to disk
/// await SoundService.persistPreferences();

/// Load user preferences from disk (call once on startup)
/// await SoundService.loadPreferences();

/// Pre-cache all sound assets to eliminate first-play latency
/// await SoundService.warmUp();

/// Clean up when the app closes
/// SoundService.dispose();

class SoundService {

  // ─── State ──────────────────────────────────

  /// The primary shared [AudioPlayer] instance.
  /// Effects that do NOT have [SoundConfig.concurrent] set to true pass
  /// through this player. A new call stops any in-progress audio before
  /// starting playback.
  // ignore: library_private_types_in_public_api
  static AudioPlayer _player = AudioPlayer();

  /// Master enabled flag. When [false] no audio is routed to any player.
  static bool _enabled = true;

  /// Master volume level applied to every effect (0.0 – 1.0).
  static double _masterVolume = 1.0;

  /// Per-effect configuration overrides. Effects not present in this map use
  /// [_defaultConfig] instead.
  static final Map<SoundEffect, SoundConfig> _effectConfigs = {};

  /// Fallback config used for any effect that has not been explicitly configured.
  static const SoundConfig _defaultConfig = SoundConfig();

  /// Whether [dispose] has already been called. Guards against double-disposal.
  static bool _disposed = false;

  /// Master haptic toggle. When [false] no haptic is fired alongside [play].
  static bool _hapticEnabled = true;

  /// Per-category enabled state. Categories not in this map default to [true].
  static final Map<SoundCategory, bool> _categoryEnabled = {};

  /// Whether [warmUp] has been called and completed at least once.
  static bool _warmedUp = false;

  /// Broadcast controller for playback state changes. External code can listen
  /// via [SoundService.onPlaybackStateChanged].
  static final StreamController<SoundPlaybackEvent> _playbackController =
      StreamController<SoundPlaybackEvent>.broadcast();

  // ─── Configuration API ─────────────────────

  /// Enable or disable all sound effects globally.
  static void setEnabled(bool enabled) {
    _enabled = enabled;
    _SoundLogger.info('Sound ${enabled ? 'enabled' : 'disabled'}.');

    // If disabling, stop all active playback.
    if (!enabled) {
      stop();
      _LoopEngine.stop();
    }
  }

  /// Returns [true] if the service is currently set to play sounds.
  static bool get isEnabled => _enabled;

  /// Sets the master playback volume applied to every sound effect.
  /// Note: This does NOT affect already-playing audio on the primary player.
  /// It DOES adjust the loop player in real time.
  static void setVolume(double volume) {
    _masterVolume = volume.clamp(0.0, 1.0);
    _SoundLogger.info('Master volume set to $_masterVolume.');

    // Update loop volume in real time so ambient sounds react immediately.
    if (_LoopEngine.isLooping) {
      final loopEffect = _LoopEngine.currentEffect;
      if (loopEffect != null) {
        final cfg = configFor(loopEffect);
        _LoopEngine.setVolume((_masterVolume * cfg.volume).clamp(0.0, 1.0));
      }
    }
  }

  /// Returns the current master volume (0.0 – 1.0).
  static double get masterVolume => _masterVolume;

  /// Enable or disable haptic feedback globally.
  static void setHapticEnabled(bool enabled) {
    _hapticEnabled = enabled;
    _SoundLogger.info('Haptic ${enabled ? 'enabled' : 'disabled'}.');
  }

  /// Returns [true] if haptic feedback is globally active.
  static bool get isHapticEnabled => _hapticEnabled;

  /// Enable or disable an entire [SoundCategory].
  /// All effects belonging to a disabled category are silently skipped at
  /// play time.
  static void setCategoryEnabled(SoundCategory category, bool enabled) {
    _categoryEnabled[category] = enabled;
    _SoundLogger.info(
      'Category ${category.name} ${enabled ? 'enabled' : 'disabled'}.',
    );

    // If disabling the ambient category, stop any active loop in that category.
    if (!enabled && category == SoundCategory.ambient && _LoopEngine.isLooping) {
      final current = _LoopEngine.currentEffect;
      if (current != null && configFor(current).category == category) {
        _LoopEngine.stop();
      }
    }
  }

  /// Returns whether [category] is currently enabled. Defaults to [true].
  static bool isCategoryEnabled(SoundCategory category) {
    return _categoryEnabled[category] ?? true;
  }

  /// Registers a custom [SoundConfig] for a specific [effect].
  /// Call this during app initialization (e.g. in `main.dart`) to set
  /// per-effect volume or cooldown overrides once, then forget about them.

  static void configure({
    required SoundEffect effect,
    required SoundConfig config,
  }) {
    _effectConfigs[effect] = config;
    _SoundLogger.info('Configured ${effect.name} → $config');
  }

  /// Registers configs for multiple effects at once. Convenience wrapper
  /// around [configure] for bulk initialization in `main.dart`.
  static void configureAll(Map<SoundEffect, SoundConfig> configs) {
    for (final entry in configs.entries) {
      _effectConfigs[entry.key] = entry.value;
    }
    _SoundLogger.info('Batch-configured ${configs.length} effects.');
  }

  /// Returns the resolved [SoundConfig] for [effect], falling back to
  /// [_defaultConfig] if no override has been registered.
  static SoundConfig configFor(SoundEffect effect) {
    return _effectConfigs[effect] ?? _defaultConfig;
  }

  // ─── Persistence API ───────────────────────

  /// Saves the current [enabled], [masterVolume], [hapticEnabled], and
  /// category states to [SharedPreferences].
  /// Call this whenever the user changes a sound setting so it survives
  /// app restarts.
  static Future<void> persistPreferences() async {
    await _SoundPrefs.save(
      enabled: _enabled,
      masterVolume: _masterVolume,
      hapticEnabled: _hapticEnabled,
      categoryStates: Map<SoundCategory, bool>.from(_categoryEnabled),
    );
  }

  /// Loads previously saved preferences from [SharedPreferences] and applies
  /// them. Call once during app startup (e.g. in `main()` before `runApp`).
  /// Values that were never saved are left at their current (default) state.
  static Future<void> loadPreferences() async {
    final prefs = await _SoundPrefs.load();

    if (prefs.enabled != null) _enabled = prefs.enabled!;
    if (prefs.masterVolume != null) {
      _masterVolume = prefs.masterVolume!.clamp(0.0, 1.0);
    }
    if (prefs.hapticEnabled != null) _hapticEnabled = prefs.hapticEnabled!;

    for (final entry in prefs.categoryStates.entries) {
      _categoryEnabled[entry.key] = entry.value;
    }

    _SoundLogger.info(
      'Preferences loaded → enabled=$_enabled, '
      'vol=$_masterVolume, haptic=$_hapticEnabled, '
      'categories=${_categoryEnabled.entries.map((e) => '${e.key.name}:${e.value}').join(', ')}',
    );
  }

  // ─── Warm-Up / Preload API ─────────────────

  /// Pre-caches audio data for the specified [effects] (or all effects if
  /// omitted) to eliminate cold-start latency on the first [play] call.
  ///
  /// Internally, each effect is played at volume 0 for ~1 ms then stopped.
  /// This forces the platform's audio decoder to load the asset into memory.
  ///
  /// Safe to call multiple times; subsequent calls are fast no-ops.
  static Future<void> warmUp([List<SoundEffect>? effects]) async {
    if (_disposed) return;
    if (_warmedUp && effects == null) return;

    final targets = effects ?? SoundEffect.values;
    _SoundLogger.info('Warming up ${targets.length} effect(s)…');

    for (final effect in targets) {
      try {
        final tempPlayer = AudioPlayer();
        await tempPlayer.setVolume(0.0);
        await tempPlayer.play(AssetSource(effect.path));
        // Give the decoder a moment to initialize, then stop and discard.
        await Future<void>.delayed(const Duration(milliseconds: 50));
        await tempPlayer.stop();
        tempPlayer.dispose();
      } catch (e) {
        _SoundLogger.warn('Warm-up failed for ${effect.name}: $e');
      }
    }

    _warmedUp = true;
    _SoundLogger.info('Warm-up complete.');
  }

  /// Returns [true] if [warmUp] has been called and completed at least once.
  static bool get isWarmedUp => _warmedUp;

  // ─── Playback API ──────────────────────────

  /// Plays [effect] asynchronously.
  ///
  /// The call is a no-op if:
  ///  - the service is globally disabled ([setEnabled(false)]),
  ///  - the effect's own config has [SoundConfig.effectEnabled] set to [false],
  ///  - the effect's [SoundCategory] has been disabled,
  ///  - the cooldown for this effect has not yet elapsed,
  ///  - [dispose] has already been called.
  ///
  /// If [SoundConfig.concurrent] is true, the effect is played on a pool
  /// player and will never interrupt other active sounds. Otherwise, any
  /// currently-playing sound on the primary player is stopped first.
  ///
  /// Errors (missing file, codec failure, etc.) are caught and logged; the
  /// caller will never receive an unhandled exception from this method.

  static Future<void> play(SoundEffect effect) async {
    final config = configFor(effect);

    // If this effect prefers to queue when the player is busy, do so.
    if (config.queueIfBusy) {
      final state = _player.state;
      if (state == PlayerState.playing) {
        _SoundQueue.enqueue(effect, configOverride: config);
        return;
      }
    }

    await _playInternal(effect);
  }

  /// Plays [effect] without awaiting completion.
  /// Identical to [play] but returns immediately. Prefer this when calling
  /// from synchronous code where you don't care about await semantics.
  static void playSync(SoundEffect effect) {
    play(effect).ignore();
  }

  /// Core playback shared by [play], the queue processor, and the fade engine.
  static Future<void> _playInternal(
    SoundEffect effect, {
    SoundConfig? configOverride,
  }) async {
    // ── Early-exit guards ──
    if (_disposed) {
      _SoundLogger.warn('play() called after dispose(). Ignoring.');
      return;
    }
    if (!_enabled) return;

    final config = configOverride ?? configFor(effect);

    if (!config.effectEnabled) {
      _SoundLogger.info('Effect ${effect.name} is individually disabled.');
      return;
    }

    // Category-level guard.
    if (!isCategoryEnabled(config.category)) {
      _SoundLogger.info(
        'Effect ${effect.name} skipped – category '
        '${config.category.name} is disabled.',
      );
      return;
    }

    if (!_SoundCooldown.canPlay(effect, config.cooldownMs)) {
      _SoundLogger.info(
        'Effect ${effect.name} skipped – cooldown '
        '(${config.cooldownMs} ms) not elapsed.',
      );
      return;
    }

    // Fire haptic concurrently with audio for tightest possible sync.
    if (_hapticEnabled) {
      _HapticEngine.trigger(config.hapticPattern).ignore();
    }

    // Compute effective volume.
    final effectiveVolume = (_masterVolume * config.volume).clamp(0.0, 1.0);

    try {
      // 🔹 BACKEND NOTE: Safety check for missing assets (e.g. tab_switch.mp3)
      // The try-catch block below ensures that if an asset is missing or 
      // the audio engine fails, the app continues to function normally.
      
      if (config.concurrent) {
        // ── Concurrent path: use pool player ──
        final poolPlayer = _AudioPool.acquire();
        await poolPlayer.stop();
        await poolPlayer.setVolume(effectiveVolume);
        await poolPlayer.play(AssetSource(effect.path));
        _SoundLogger.info(
          'Playing ${effect.name} (pool) at volume $effectiveVolume.',
        );
      } else {
        // ── Primary path: use shared player ──
        await _player.stop();
        await _player.setVolume(effectiveVolume);
        await _player.play(AssetSource(effect.path));
        _SoundLogger.info(
          'Playing ${effect.name} at volume $effectiveVolume.',
        );
      }

      _SoundCooldown.record(effect);

      // Broadcast playback event.
      _playbackController.add(SoundPlaybackEvent(
        effect: effect,
        state: SoundPlaybackState.started,
        volume: effectiveVolume,
      ));
    } catch (e) {
      // ❌ BACKEND: Explicitly log missing asset errors to Logcat
      _SoundLogger.error('SoundService: Playback failed for ${effect.name}. Path: ${effect.path}', e);

      _playbackController.add(SoundPlaybackEvent(
        effect: effect,
        state: SoundPlaybackState.error,
        volume: effectiveVolume,
      ));
    }
  }

  /// Stops any currently-playing sound effect immediately on the primary
  /// player, the pool, and the loop engine.
  static Future<void> stop() async {
    if (_disposed) return;
    try {
      await _player.stop();
      await _AudioPool.stopAll();
      _SoundLogger.info('Playback stopped.');
    } catch (e) {
      _SoundLogger.error('Failed to stop playback.', e);
    }
  }

  /// Stops only the primary player without touching pool or loop players.
  static Future<void> stopPrimary() async {
    if (_disposed) return;
    try {
      await _player.stop();
    } catch (e) {
      _SoundLogger.error('Failed to stop primary player.', e);
    }
  }

  // ─── Loop API ──────────────────────────────

  /// Starts [effect] in a continuous loop.
  ///
  /// Only one loop can be active at a time. Calling this while a loop is
  /// already running replaces it with the new effect.
  ///
  /// Respects global enabled state and category toggle. Does NOT respect
  /// cooldown (loops are long-running by nature).
  static Future<void> playLooping(SoundEffect effect) async {
    if (_disposed || !_enabled) return;

    final config = configFor(effect);
    if (!config.effectEnabled) return;
    if (!isCategoryEnabled(config.category)) return;

    final vol = (_masterVolume * config.volume).clamp(0.0, 1.0);
    await _LoopEngine.start(effect, vol);

    _playbackController.add(SoundPlaybackEvent(
      effect: effect,
      state: SoundPlaybackState.loopStarted,
      volume: vol,
    ));
  }

  /// Stops the currently-looping sound, if any.
  static Future<void> stopLoop() async {
    if (_disposed) return;

    final wasLooping = _LoopEngine.currentEffect;
    await _LoopEngine.stop();

    if (wasLooping != null) {
      _playbackController.add(SoundPlaybackEvent(
        effect: wasLooping,
        state: SoundPlaybackState.loopStopped,
        volume: 0,
      ));
    }
  }

  /// Returns the currently-looping [SoundEffect], or null.
  static SoundEffect? get currentLoop => _LoopEngine.currentEffect;

  /// Returns [true] if a sound is currently looping.
  static bool get isLooping => _LoopEngine.isLooping;

  // ─── Fade API ──────────────────────────────

  /// Plays [effect] with a smooth fade-in ramp.
  /// The fade duration and curve are taken from the effect's [SoundConfig]
  /// unless explicitly overridden here.
  static Future<void> playWithFade(
    SoundEffect effect, {
    Duration? fadeInDuration,
    FadeCurve curve = FadeCurve.easeOut,
  }) async {
    if (_disposed || !_enabled) return;

    final config = configFor(effect);
    if (!config.effectEnabled) return;
    if (!isCategoryEnabled(config.category)) return;
    if (!_SoundCooldown.canPlay(effect, config.cooldownMs)) return;

    final targetVolume = (_masterVolume * config.volume).clamp(0.0, 1.0);
    final duration = fadeInDuration ?? config.fadeInDuration;

    if (_hapticEnabled) {
      _HapticEngine.trigger(config.hapticPattern).ignore();
    }

    await _FadeEngine.fadeIn(
      effect: effect,
      targetVolume: targetVolume,
      duration: duration,
      curve: curve,
    );

    _SoundCooldown.record(effect);
  }

  /// Fades out the currently-playing sound over [duration] then stops it.
  static Future<void> fadeOutAndStop(
    Duration duration, {
    FadeCurve curve = FadeCurve.easeIn,
  }) async {
    if (_disposed) return;
    await _FadeEngine.fadeOut(duration: duration, curve: curve);
  }

  /// Performs a sequential cross-fade: fades out current sound, then fades
  /// in [to]. Both legs use [duration] as their ramp length.
  static Future<void> crossFade({
    required SoundEffect to,
    Duration duration = const Duration(milliseconds: 300),
    FadeCurve outCurve = FadeCurve.easeIn,
    FadeCurve inCurve = FadeCurve.easeOut,
  }) async {
    if (_disposed || !_enabled) return;
    await _FadeEngine.fadeOut(duration: duration, curve: outCurve);
    await playWithFade(to, fadeInDuration: duration, curve: inCurve);
  }

  // ─── Queue API ─────────────────────────────

  /// Adds [effects] to the back of the FIFO play queue.
  /// Items are played sequentially, each waiting for the previous to complete.
  static void enqueue(List<SoundEffect> effects) {
    for (final effect in effects) {
      _SoundQueue.enqueue(effect);
    }
  }

  /// Removes all pending items from the queue without interrupting the
  /// currently-playing sound.
  static void clearQueue() => _SoundQueue.clear();

  /// Stops the currently-playing sound AND removes all queued items.
  static Future<void> stopAndClearQueue() async {
    _SoundQueue.clear();
    await stop();
  }

  /// Returns the number of effects currently waiting in the queue.
  static int get queueLength => _SoundQueue.length;

  /// Returns an unmodifiable snapshot of the queue's current contents.
  static List<SoundEffect> get queueSnapshot => _SoundQueue.snapshot;

  // ─── Haptic API ────────────────────────────

  /// Triggers [pattern] immediately, independent of any sound effect.
  /// Respects the global [_hapticEnabled] toggle.
  static Future<void> triggerHaptic(HapticPattern pattern) async {
    if (!_hapticEnabled) return;
    await _HapticEngine.trigger(pattern);
  }

  // ─── Playback State Stream ─────────────────

  /// A broadcast stream of [SoundPlaybackEvent]s.
  /// Subscribe to this to react to sound state changes in the UI (e.g. show
  /// a volume indicator, animate a speaker icon, etc.).
  static Stream<SoundPlaybackEvent> get onPlaybackStateChanged =>
      _playbackController.stream;

  /// Returns the current state of the primary player.
  static PlayerState get primaryPlayerState => _player.state;

  /// Returns the number of pool players currently playing audio.
  static int get activePoolPlayers => _AudioPool.activePlayers;

  // ─── Cooldown Utilities ────────────────────

  /// Manually resets the cooldown timer for [effect], allowing it to play
  /// immediately on the next [play] call even if the normal cooldown has not
  /// yet elapsed. Useful in test code or after a scene transition.
  static void resetCooldown(SoundEffect effect) {
    _SoundCooldown.reset(effect);
  }

  /// Resets cooldown state for every registered [SoundEffect].
  static void resetAllCooldowns() {
    _SoundCooldown.resetAll();
    _SoundLogger.info('All effect cooldowns reset.');
  }

  /// Returns the remaining cooldown in ms for [effect]. Returns 0 if ready.
  static int cooldownRemainingMs(SoundEffect effect) {
    final config = configFor(effect);
    return _SoundCooldown.remainingMs(effect, config.cooldownMs);
  }

  // ─── Lifecycle ─────────────────────────────

  /// Releases the underlying [AudioPlayer] resources.
  /// Should be called once when the application is shutting down.
  /// After this call, [play] and [stop] become no-ops and log a warning.
  ///
  /// To use the service again (e.g. after a logout/login cycle), call
  /// [reinitialize].
  static void dispose() {
    if (_disposed) {
      _SoundLogger.warn('dispose() called more than once. Skipping.');
      return;
    }
    _SoundQueue.dispose();
    _FadeEngine.dispose();
    _LoopEngine.dispose();
    _AudioPool.dispose();
    _player.dispose();
    _disposed = true;
    _SoundLogger.info('SoundService disposed.');
  }

  /// Recreates all internal players after a prior [dispose] call.
  /// Call this when the service needs to come back to life (e.g. user re-opens
  /// the app or logs back in).
  ///
  /// No-op if the service was never disposed.
  static void reinitialize() {
    if (!_disposed) {
      _SoundLogger.warn('reinitialize() called but service is still alive.');
      return;
    }

    _player = AudioPlayer();
    _FadeEngine.reinitialize();
    _LoopEngine.reinitialize();
    _AudioPool.reinitialize();
    _disposed = false;
    _warmedUp = false;

    _SoundLogger.info('SoundService reinitialized.');
  }

  /// Call from a [WidgetsBindingObserver.didChangeAppLifecycleState] handler
  /// to automatically pause / resume audio when the app goes to background.
  static bool _wasEnabledBeforePause = true;

  static void handleAppLifecycle(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        _wasEnabledBeforePause = _enabled;
        if (_enabled) {
          _enabled = false;
          _LoopEngine.stop();
          _SoundLogger.info('App backgrounded – audio paused.');
        }
      case AppLifecycleState.resumed:
        if (_wasEnabledBeforePause) {
          _enabled = true;
          _SoundLogger.info('App resumed – audio restored.');
        }
      default:
        break;
    }
  }

  // ─── Diagnostics / Debug Helpers ───────────

  /// Returns a human-readable snapshot of the current service state.
  /// Useful for logging or displaying in a debug panel.
  static String diagnostics() {
    final buffer = StringBuffer();
    buffer.writeln('── SoundService diagnostics ──────────────────────');
    buffer.writeln('  enabled       : $_enabled');
    buffer.writeln('  masterVolume  : $_masterVolume');
    buffer.writeln('  hapticEnabled : $_hapticEnabled');
    buffer.writeln('  disposed      : $_disposed');
    buffer.writeln('  warmedUp      : $_warmedUp');
    buffer.writeln('  looping       : ${_LoopEngine.isLooping ? _LoopEngine.currentEffect?.name ?? '?' : 'none'}');
    buffer.writeln('  poolActive    : ${_AudioPool.activePlayers}');
    buffer.writeln('  queueLength   : ${_SoundQueue.length}');
    buffer.writeln('  queue         : ${_SoundQueue.snapshot.map((e) => e.name).join(', ')}');
    buffer.writeln('  categories:');
    for (final cat in SoundCategory.values) {
      buffer.writeln('    ${cat.name} : ${isCategoryEnabled(cat) ? 'enabled' : 'DISABLED'}');
    }
    buffer.writeln('  effect configs:');
    if (_effectConfigs.isEmpty) {
      buffer.writeln('    (none – all effects use default config)');
    } else {
      for (final entry in _effectConfigs.entries) {
        buffer.writeln('    ${entry.key.name} → ${entry.value}');
      }
    }
    buffer.writeln('  cooldowns:');
    for (final effect in SoundEffect.values) {
      final config = configFor(effect);
      final rem = _SoundCooldown.remainingMs(effect, config.cooldownMs);
      buffer.writeln('    ${effect.name} : ${rem == 0 ? 'ready' : '${rem}ms remaining'}');
    }
    buffer.writeln('──────────────────────────────────────────────────');
    return buffer.toString();
  }
}

// ──────────────────────────────────────────────
//  Playback State Events
// ──────────────────────────────────────────────

/// Represents a discrete playback state change broadcast by [SoundService].
class SoundPlaybackEvent {
  /// The effect that triggered this event.
  final SoundEffect effect;

  /// The new playback state.
  final SoundPlaybackState state;

  /// The effective volume at the time of the event.
  final double volume;

  const SoundPlaybackEvent({
    required this.effect,
    required this.state,
    required this.volume,
  });

  @override
  String toString() =>
      'SoundPlaybackEvent(${effect.name}, ${state.name}, vol=$volume)';
}

/// Possible states broadcast via [SoundService.onPlaybackStateChanged].
enum SoundPlaybackState {
  /// A one-shot effect has started playing.
  started,

  /// A looping effect has started playing.
  loopStarted,

  /// A looping effect has been stopped.
  loopStopped,

  /// Playback failed due to an error.
  error,
}

// ──────────────────────────────────────────────
//  SoundEffect Enum
// ──────────────────────────────────────────────

enum SoundEffect {

  // ── Existing ───────────────────────────────

  /// PLAYED WHEN: Played during the final 10 seconds of an exam timer countdown.
  /// PLAYED WHERE: [exam_controller.dart], [duel_game_controller.dart]
  timerWarning('sfx/timer_warning.mp3'),

  /// PLAYED WHEN: Plays when the AI evaluator grades a user's answer as correct / incorrect.
  /// PLAYED WHERE: [mcq_controller.dart], [short_answer_controller.dart],
  ///              [fill_blank_controller.dart], [coding_controller.dart],
  ///              [duel_game_controller.dart]
  correctAnswer('sfx/correct.mp3'),
  wrongAnswer('sfx/wrong.mp3'),

  // ── Exam ───────────────────────────────────

  /// PLAYED WHEN: After AI evaluation completes and exam is submitted.
  /// PLAYED WHERE: [exam_controller.dart → submit()]
  examComplete('sfx/exam_complete.mp3'),

  /// PLAYED WHEN: User flags / un-flags a question during an exam.
  /// PLAYED WHERE: [exam_controller.dart → toggleFlag()]
  flagToggle('sfx/flag_toggle.mp3'),

  /// PLAYED WHEN: User navigates to the next or previous question.
  /// PLAYED WHERE: [exam_controller.dart → next(), prev()]
  swipe('sfx/swipe.mp3'),

  // ── Duel ───────────────────────────────────

  /// PLAYED WHEN: Matchmaking finds an opponent.
  /// PLAYED WHERE: [matchmaking_controller.dart]
  matchFound('sfx/match_found.mp3'),

  /// PLAYED WHEN: Duel ends and local player wins / loses.
  /// PLAYED WHERE: [duel_game_controller.dart → _afterReveal()]
  duelWin('sfx/duel_win.mp3'),
  duelLose('sfx/duel_lose.mp3'),

  /// PLAYED WHEN: Player taps an option in a duel round (before reveal).
  /// PLAYED WHERE: [duel_game_controller.dart → selectOption()]
  buttonTap('sfx/button_tap.mp3'),

  // ── UI ─────────────────────────────────────

  /// PLAYED WHEN: User switches tabs on the bottom navigation bar.
  /// PLAYED WHERE: [app_bottom_nav_bar.dart]
  tabSwitch('sfx/tab_switch.mp3'),

  /// PLAYED WHEN: User bookmarks or un-bookmarks a question.
  /// PLAYED WHERE: [bookmark_controller.dart → toggleBookmark()]
  bookmarkAdd('sfx/bookmark_add.mp3'),
  bookmarkRemove('sfx/bookmark_remove.mp3'),

  // ── Progress ───────────────────────────────

  /// PLAYED WHEN: User reaches a new level (XP milestone).
  /// PLAYED WHERE: [progress_controller.dart → _listenUserProgress()]
  levelUp('sfx/level_up.mp3'),

  // ── Auth ───────────────────────────────────

  /// PLAYED WHEN: Successful login / sign-in.
  /// PLAYED WHERE: [login_controller.dart → login(), loginWithGoogle(), loginWithApple()]
  loginSuccess('sfx/login_success.mp3'),

  /// PLAYED WHEN: Login attempt fails or an error occurs.
  /// PLAYED WHERE: [login_controller.dart → catch blocks]
  error('sfx/error.mp3');

  const SoundEffect(this.path);
  final String path;

  /// Convenience getter returning the file name without directory prefix.
  String get fileName => path.split('/').last;

  /// Convenience getter returning the file extension (without the dot).
  String get extension => fileName.contains('.') ? fileName.split('.').last : '';

}
