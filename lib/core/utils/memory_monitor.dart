import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Simple memory monitor for debug builds.
///
/// Logs current memory usage via Timeline events.
/// Only active in debug mode — no-op in release builds.
abstract final class MemoryMonitor {
  /// Logs a memory checkpoint with the given [label].
  static void checkpoint(String label) {
    if (!kDebugMode) return;
    developer.log(
      'Memory checkpoint: $label',
      name: 'MemoryMonitor',
    );
    developer.Timeline.instantSync('Memory: $label');
  }
}
