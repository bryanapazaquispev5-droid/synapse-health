import 'package:flutter/foundation.dart';

/// Keeps the unregistered demo session only in memory on this device.
class TrialModeSession {
  TrialModeSession._();

  static final ValueNotifier<bool> active = ValueNotifier(false);

  static bool get isActive => active.value;

  static void start() => active.value = true;

  static void end() => active.value = false;
}
