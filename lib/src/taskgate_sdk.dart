import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'task_info.dart';
import 'completion_status.dart';

/// TaskGate SDK for Flutter
///
/// Allows partner apps to:
/// - Receive task requests from TaskGate
/// - Report task completion status
class TaskGateSdk {
  static const MethodChannel _channel = MethodChannel('taskgate_sdk');

  static final StreamController<TaskInfo> _taskController =
      StreamController<TaskInfo>.broadcast();

  static bool _initialized = false;
  static TaskInfo? _pendingTask;

  /// Stream of incoming task requests
  ///
  /// Listen to this stream to receive task notifications:
  /// ```dart
  /// TaskGateSdk.taskStream.listen((task) {
  ///   print('Received task: ${task.taskId}');
  /// });
  /// ```
  static Stream<TaskInfo> get taskStream => _taskController.stream;

  /// Initialize the SDK
  ///
  /// Call this early in your app's lifecycle (e.g., in main() or initState).
  ///
  /// - [providerId]: Your unique provider ID (assigned by TaskGate)
  static Future<void> initialize({required String providerId}) async {
    if (_initialized) {
      debugPrint('[TaskGateSdk] Already initialized');
      return;
    }

    // Set up method call handler for native -> Dart calls
    _channel.setMethodCallHandler(_handleMethodCall);

    // Initialize native SDK
    await _channel.invokeMethod('initialize', {'providerId': providerId});

    // Set up lifecycle observer to check for pending tasks on resume
    _setupLifecycleObserver();

    _initialized = true;
    debugPrint('[TaskGateSdk] Initialized for provider: $providerId');

    // Check for any pending task immediately
    await _checkPendingTask();
  }

  /// Get pending task info
  ///
  /// Returns the pending task if one exists, null otherwise.
  /// Useful for cold start scenarios.
  ///
  /// The task persists until [reportCompletion] is called.
  static Future<TaskInfo?> getPendingTask() async {
    _ensureInitialized();

    try {
      final result =
          await _channel.invokeMethod<Map<dynamic, dynamic>?>('getPendingTask');
      if (result != null) {
        final task = TaskInfo.fromMap(result);
        _pendingTask = task;
        debugPrint('[TaskGateSdk] getPendingTask() -> ${task.taskId}');
        return task;
      }
      debugPrint('[TaskGateSdk] getPendingTask() -> null');
      return null;
    } on PlatformException catch (e) {
      debugPrint('[TaskGateSdk] Error getting pending task: ${e.message}');
      return null;
    }
  }

  /// Report task completion to TaskGate
  ///
  /// Call this when the user completes (or cancels) a task.
  ///
  /// - [status]: The completion status (open, focus, or cancelled)
  static Future<void> reportCompletion(CompletionStatus status) async {
    _ensureInitialized();

    try {
      await _channel.invokeMethod('reportCompletion', {'status': status.value});
      _pendingTask = null;
      debugPrint('[TaskGateSdk] Reported completion: ${status.value}');
    } on PlatformException catch (e) {
      debugPrint('[TaskGateSdk] Error reporting completion: ${e.message}');
      rethrow;
    }
  }

  /// Cancel the current task
  ///
  /// Convenience method that calls [reportCompletion] with [CompletionStatus.cancelled]
  static Future<void> cancelTask() async {
    await reportCompletion(CompletionStatus.cancelled);
  }

  /// Check if there's an active task session
  static Future<bool> hasActiveSession() async {
    final task = await getPendingTask();
    return task != null;
  }

  /// Get the current pending task (cached)
  ///
  /// Returns the last known pending task without making a native call.
  /// Use [getPendingTask] to get the latest from native.
  static TaskInfo? get currentTask => _pendingTask;

  /// Dispose of SDK resources
  ///
  /// Call this when you no longer need the SDK (e.g., app termination)
  static void dispose() {
    _taskController.close();
    _channel.setMethodCallHandler(null);
    _initialized = false;
    _pendingTask = null;
    debugPrint('[TaskGateSdk] Disposed');
  }

  // MARK: - Private Methods

  static Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onTaskReceived':
        final args = call.arguments as Map<dynamic, dynamic>;
        final task = TaskInfo.fromMap(args);
        _pendingTask = task;
        _taskController.add(task);
        debugPrint('[TaskGateSdk] Task received via callback: ${task.taskId}');
        break;
      default:
        debugPrint('[TaskGateSdk] Unknown method: ${call.method}');
    }
  }

  static void _setupLifecycleObserver() {
    // Use WidgetsBindingObserver pattern via callback
    final observer = _TaskGateLifecycleObserver(_onAppResumed);
    WidgetsBinding.instance.addObserver(observer);
  }

  static void _onAppResumed() {
    // Check for pending task when app resumes (handles warm start)
    _checkPendingTask();
  }

  static Future<void> _checkPendingTask() async {
    final task = await getPendingTask();
    if (task != null && _pendingTask?.sessionId != task.sessionId) {
      // New task received
      _pendingTask = task;
      _taskController.add(task);
      debugPrint('[TaskGateSdk] New task detected: ${task.taskId}');
    }
  }

  static void _ensureInitialized() {
    if (!_initialized) {
      throw StateError(
        'TaskGateSdk not initialized. Call TaskGateSdk.initialize() first.',
      );
    }
  }
}

/// Internal lifecycle observer
class _TaskGateLifecycleObserver extends WidgetsBindingObserver {
  final VoidCallback onResumed;

  _TaskGateLifecycleObserver(this.onResumed);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      onResumed();
    }
  }
}
