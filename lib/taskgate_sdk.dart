/// TaskGate SDK for Flutter
///
/// A Flutter plugin that allows partner apps to integrate with TaskGate.
///
/// ## Usage
///
/// ```dart
/// import 'package:taskgate_sdk/taskgate_sdk.dart';
///
/// // Initialize the SDK
/// await TaskGateSdk.initialize(providerId: 'your_provider_id');
///
/// // Listen for incoming tasks
/// TaskGateSdk.taskStream.listen((task) {
///   print('Received task: ${task.taskId}');
///   // Navigate to task screen
/// });
///
/// // Check for pending task (cold start)
/// final pendingTask = await TaskGateSdk.getPendingTask();
/// if (pendingTask != null) {
///   // Handle the pending task
/// }
///
/// // Report completion
/// await TaskGateSdk.reportCompletion(CompletionStatus.open);
/// ```
library taskgate_sdk;

export 'src/taskgate_sdk.dart';
export 'src/task_info.dart';
export 'src/completion_status.dart';
