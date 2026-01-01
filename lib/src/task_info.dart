/// Task information received from TaskGate
class TaskInfo {
  /// The unique task identifier
  final String taskId;

  /// The session identifier for this task request
  final String sessionId;

  /// The callback URL to return to TaskGate
  final String callbackUrl;

  /// The name of the app that was blocked (optional)
  final String? appName;

  /// Additional parameters passed with the task
  final Map<String, String> additionalParams;

  const TaskInfo({
    required this.taskId,
    required this.sessionId,
    required this.callbackUrl,
    this.appName,
    this.additionalParams = const {},
  });

  factory TaskInfo.fromMap(Map<dynamic, dynamic> map) {
    return TaskInfo(
      taskId: map['taskId'] as String? ?? '',
      sessionId: map['sessionId'] as String? ?? '',
      callbackUrl: map['callbackUrl'] as String? ?? '',
      appName: map['appName'] as String?,
      additionalParams: Map<String, String>.from(
        (map['additionalParams'] as Map<dynamic, dynamic>?) ?? {},
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'taskId': taskId,
      'sessionId': sessionId,
      'callbackUrl': callbackUrl,
      'appName': appName,
      'additionalParams': additionalParams,
    };
  }

  @override
  String toString() {
    return 'TaskInfo(taskId: $taskId, sessionId: $sessionId, appName: $appName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TaskInfo &&
        other.taskId == taskId &&
        other.sessionId == sessionId;
  }

  @override
  int get hashCode => taskId.hashCode ^ sessionId.hashCode;
}
