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
//  - The service uses a single shared AudioPlayer instance. Rapid successive
//    calls will stop the previous sound before starting the next one.
//    If you need overlapping sounds, create a separate AudioPlayer per effect.
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

import 'dart:async';
import 'dart:math' as math;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

// Haptic Pattern

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

// Fade Curve

/// Volume ramp shape applied during fade-in / fade-out operations.
enum FadeCurve {
  linear,
  easeIn,
  easeOut,
  easeInOut,
}

// Configuration

/// Pass an instance of [SoundConfig] to [SoundService.configure] to override per-effect settings, or set the master volume via [SoundService.setVolume].\

class SoundConfig {

  /// Audio playback volume for this particular effect (0.0 – 1.0).
  final double volume;

  /// Minimum milliseconds that must elapse between two consecutive plays of the same [SoundEffect]. Calls arriving sooner than this threshold are silently dropped. Useful for rapid-fire events like button taps.
  final int cooldownMs;

  /// Whether this specific effect is enabled, regardless of the global toggle.
  /// Set to [false] to permanently silence a single effect without touching
  final bool effectEnabled;

  /// Duration of the fade-in ramp used by [SoundService.playWithFade].
  final Duration fadeInDuration;

  /// Duration of the fade-out ramp used by [SoundService.fadeOutAndStop].
  final Duration fadeOutDuration;

  /// Haptic pattern fired alongside [SoundService.play].
  final HapticPattern hapticPattern;

  /// When true, effect is queued instead of interrupting the current sound.
  final bool queueIfBusy;

  const SoundConfig({
    this.volume = 1.0,
    this.cooldownMs = 80,
    this.effectEnabled = true,
    this.fadeInDuration = const Duration(milliseconds: 150),
    this.fadeOutDuration = const Duration(milliseconds: 200),
    this.hapticPattern = HapticPattern.medium,
    this.queueIfBusy = false,
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
  }) {
    return SoundConfig(
      volume: volume ?? this.volume,
      cooldownMs: cooldownMs ?? this.cooldownMs,
      effectEnabled: effectEnabled ?? this.effectEnabled,
      fadeInDuration: fadeInDuration ?? this.fadeInDuration,
      fadeOutDuration: fadeOutDuration ?? this.fadeOutDuration,
      hapticPattern: hapticPattern ?? this.hapticPattern,
      queueIfBusy: queueIfBusy ?? this.queueIfBusy,
    );
  }

  @override
  String toString() =>
      'SoundConfig(volume: $volume, cooldownMs: $cooldownMs, effectEnabled: $effectEnabled, '
      'fadeIn: ${fadeInDuration.inMilliseconds}ms, fadeOut: ${fadeOutDuration.inMilliseconds}ms, '
      'haptic: ${hapticPattern.name}, queueIfBusy: $queueIfBusy)';
}

// Internal Debugging Helpers

/// Lightweight structured-logging helper used only inside [SoundService].
/// In debug builds, messages are printed to the console.

class _SoundLogger {
  const _SoundLogger._();

  // Change to false to suppress all SoundService logs in debug builds.
  static const bool _loggingEnabled = true;

  static void info(String message) =>
      _write('ℹ️ [SoundService]', message);

  static void warn(String message) =>
      _write('⚠️ [SoundService]', message);

  static void error(String message, [Object? err]) {
    _write('❌ [SoundService]', err != null ? '$message | $err' : message);
  }

  static void _write(String prefix, String message) {
    // ignore: avoid_print
    if (_loggingEnabled) print('$prefix $message');
  }
}

/// Tracks the last-played timestamp for each [SoundEffect] to enforce per-effect cooldowns. Stored as epoch-milliseconds for minimal overhead.
class _SoundCooldown {

  _SoundCooldown._();

  static final Map<SoundEffect, int> _lastPlayed = {};

  /// Returns [true] if [effect] may be played right now (cooldown has elapsed and its allowed right now).
  static bool canPlay(SoundEffect effect, int cooldownMs) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final last = _lastPlayed[effect] ?? 0;
    return (now - last) >= cooldownMs;
  }

  /// Records the current timestamp as the last-played time for [effect].
  static void record(SoundEffect effect) {
    _lastPlayed[effect] = DateTime.now().millisecondsSinceEpoch;
  }

  /// Clears the cooldown state for a specific [effect], allowing it to play immediately on the next call regardless of elapsed time.
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

// Fade Engine

/// Performs smooth volume ramps on a dedicated [AudioPlayer].
/// Volume is stepped at [_stepIntervalMs]-ms intervals using a [Timer.periodic].
class _FadeEngine {

  _FadeEngine._();

  static final AudioPlayer _fadePlayer = AudioPlayer();

  // 16 ms ≈ 60 fps. Smaller = smoother but more timer overhead.
  static const int _stepIntervalMs = 16;

  static Timer? _activeTimer;

  /// Starts [effect] on the fade player at volume 0, ramps up to [targetVolume] over [duration].
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

  /// Ramps the fade player's volume down to 0 over [duration], then stops playback.
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
}

// Play Queue

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

  /// Removes all pending items from the queue without affecting what is currently playing.
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

    // Delegate to the main service so all guards (enabled, cooldown, etc.) apply.
    await SoundService._playInternal(item.effect, configOverride: item.configOverride);

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

// Haptic Engine

/// Fires the appropriate [HapticFeedback] call for a given [HapticPattern].
/// All calls are wrapped in a try-catch so platforms lacking vibration support never throw.
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

// SoundService (API)

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

/// Trigger haptic independently of any sound
/// await SoundService.triggerHaptic(HapticPattern.heavy);

/// Clean up when the app closes
/// SoundService.dispose();

class SoundService {

  /// The single shared [AudioPlayer] instance.
  /// All effects pass through this player; a new call stops any in-progress audio automatically via [stop] before starting playback.
  // ignore: library_private_types_in_public_api
  static final AudioPlayer _player = AudioPlayer();

  /// Master enabled flag. When [false] no audio is routed to [_player].
  static bool _enabled = true;

  /// Master volume level applied to every effect (0.0 – 1.0).
  static double _masterVolume = 1.0;

  /// Per-effect configuration overrides. Effects not present in this map use [_defaultConfig] instead.
  static final Map<SoundEffect, SoundConfig> _effectConfigs = {};

  /// Fallback config used for any effect that has not been explicitly configured.
  static const SoundConfig _defaultConfig = SoundConfig();

  /// Whether [dispose] has already been called. Guards against double-disposal.
  static bool _disposed = false;

  /// Master haptic toggle. When [false] no haptic is fired alongside [play].
  static bool _hapticEnabled = true;

  // Configuration API

  /// Enable or disable all sound effects globally.
  static void setEnabled(bool enabled) {
    _enabled = enabled;
    _SoundLogger.info('Sound ${enabled ? 'enabled' : 'disabled'}.');
  }

  /// Returns [true] if the service is currently set to play sounds.
  static bool get isEnabled => _enabled;

  /// Sets the master playback volume applied to every sound effect.
  /// Note: This does NOT affect already-playing audio. The new volume takes effect on the next [play] call.
  static void setVolume(double volume) {
    _masterVolume = volume.clamp(0.0, 1.0);
    _SoundLogger.info('Master volume set to $_masterVolume.');
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

  /// Registers a custom [SoundConfig] for a specific [effect].
  /// Call this during app initialization (e.g. in `main.dart`) to set per-effect volume or cooldown overrides once, then forget about them.

  static void configure({
    required SoundEffect effect,
    required SoundConfig config,
  }) {
    _effectConfigs[effect] = config;
    _SoundLogger.info('Configured ${effect.name} → $config');
  }

  /// Returns the resolved [SoundConfig] for [effect], falling back to
  /// [_defaultConfig] if no override has been registered.
  static SoundConfig configFor(SoundEffect effect) {
    return _effectConfigs[effect] ?? _defaultConfig;
  }

  // Playback API

  /// Plays [effect] asynchronously.
  ///
  /// The call is a no-op if:
  ///  - the service is globally disabled ([setEnabled(false)]),
  ///  - the effect's own config has [SoundConfig.effectEnabled] set to [false],
  ///  - the cooldown for this effect has not yet elapsed,
  ///  - [dispose] has already been called.
  ///
  /// Any currently-playing sound is stopped before starting the new one.
  /// Errors (missing file, codec failure, etc.) are caught and logged; the caller will never receive an unhandled exception from this method.

  static Future<void> play(SoundEffect effect) async {
    final config = configFor(effect);

    // If this effect prefers to queue when the player is busy, do so.
    if (config.queueIfBusy) {
      final state = await _player.state;
      if (state == PlayerState.playing) {
        _SoundQueue.enqueue(effect, configOverride: config);
        return;
      }
    }

    await _playInternal(effect);
  }

  /// Plays [effect] without awaiting completion.
  /// Identical to [play] but returns immediately. Prefer this when calling from synchronous code where you don't care about await semantics.
  static void playSync(SoundEffect effect) {
    play(effect).ignore();
  }

  /// Core playback shared by [play], the queue processor, and the fade engine.
  static Future<void> _playInternal(
    SoundEffect effect, {
    SoundConfig? configOverride,
  }) async {
    // Early-exit guards
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

    if (!_SoundCooldown.canPlay(effect, config.cooldownMs)) {
      _SoundLogger.info(
        'Effect ${effect.name} skipped – cooldown (${config.cooldownMs} ms) not elapsed.',
      );
      return;
    }

    // Fire haptic concurrently with audio for tightest possible sync.
    if (_hapticEnabled) {
      _HapticEngine.trigger(config.hapticPattern).ignore();
    }

    // Compute effective volume
    final effectiveVolume = (_masterVolume * config.volume).clamp(0.0, 1.0);

    try {
      await _player.stop();
      await _player.setVolume(effectiveVolume);
      await _player.play(AssetSource(effect.path));
      _SoundCooldown.record(effect);
      _SoundLogger.info('Playing ${effect.name} at volume $effectiveVolume.');
    } catch (e) {

      // Never let audio errors bubble up to the UI layer!!
      _SoundLogger.error('Failed to play ${effect.name}.', e);

    }
  }

  /// Stops any currently-playing sound effect immediately.
  static Future<void> stop() async {
    if (_disposed) return;
    try {
      await _player.stop();
      _SoundLogger.info('Playback stopped.');
    } catch (e) {
      _SoundLogger.error('Failed to stop playback.', e);
    }
  }

  // Fade API

  /// Plays [effect] with a smooth fade-in ramp.
  /// The fade duration and curve are taken from the effect's [SoundConfig] unless explicitly overridden here.
  static Future<void> playWithFade(
    SoundEffect effect, {
    Duration? fadeInDuration,
    FadeCurve curve = FadeCurve.easeOut,
  }) async {
    if (_disposed || !_enabled) return;

    final config = configFor(effect);
    if (!config.effectEnabled) return;
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

  /// Performs a sequential cross-fade: fades out current sound, then fades in [to].
  /// Both legs use [duration] as their ramp length.
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

  // Queue API

  /// Adds [effects] to the back of the FIFO play queue.
  /// Items are played sequentially, each waiting for the previous to complete.
  static void enqueue(List<SoundEffect> effects) {
    for (final effect in effects) {
      _SoundQueue.enqueue(effect);
    }
  }

  /// Removes all pending items from the queue without interrupting the currently-playing sound.
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

  // Haptic API

  /// Triggers [pattern] immediately, independent of any sound effect.
  /// Respects the global [_hapticEnabled] toggle.
  static Future<void> triggerHaptic(HapticPattern pattern) async {
    if (!_hapticEnabled) return;
    await _HapticEngine.trigger(pattern);
  }

  // Cooldown utilities

  /// Manually resets the cooldown timer for [effect], allowing it to play immediately on the next [play] call even if the normal cooldown has not yet elapsed. Useful in test code or after a scene transition.
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

  // Lifecycle

  /// Releases the underlying [AudioPlayer] resources.
  /// Should be called once when the application is shutting down. After this call, [play] and [stop] become no-ops and log a warning.
  static void dispose() {
    if (_disposed) {
      _SoundLogger.warn('dispose() called more than once. Skipping.');
      return;
    }
    _SoundQueue.dispose();
    _FadeEngine.dispose();
    _player.dispose();
    _disposed = true;
    _SoundLogger.info('SoundService disposed.');
  }


  // Diagnostics / debug helpers

  /// Returns a human-readable snapshot of the current service state.
  /// Useful for logging or displaying in a debug panel.
  static String diagnostics() {
    final buffer = StringBuffer();
    buffer.writeln('── SoundService diagnostics ──────────────────────');
    buffer.writeln('  enabled       : $_enabled');
    buffer.writeln('  masterVolume  : $_masterVolume');
    buffer.writeln('  hapticEnabled : $_hapticEnabled');
    buffer.writeln('  disposed      : $_disposed');
    buffer.writeln('  queueLength   : ${_SoundQueue.length}');
    buffer.writeln('  queue         : ${_SoundQueue.snapshot.map((e) => e.name).join(', ')}');
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

// ---- SoundEffect enum -----

enum SoundEffect {

  /// PLAYED WHEN: Played during the final 10 seconds of an exam timer countdown.
  /// PLAYED WHERE: [exam_controller.dart]
  timerWarning('sfx/timer_warning.mp3'),

  /// PLAYED WHEN: Plays when the AI evaluator grades a user's answer as correct / incorrect.
  /// PLAYED WHERE: [mcq_controller.dart] , [short_answer_controller.dart], etc.]
  correctAnswer('sfx/correct.mp3'),
  wrongAnswer('sfx/wrong.mp3');

  const SoundEffect(this.path);
  final String path;

  /// Convenience getter returning the file name without directory prefix.
  String get fileName => path.split('/').last;

  /// Convenience getter returning the file extension (without the dot).
  String get extension => fileName.contains('.') ? fileName.split('.').last : '';

}