/// Task completion status
enum CompletionStatus {
  /// User completed task and wants to open the blocked app
  open('open'),

  /// User completed task but wants to stay focused
  focus('focus'),

  /// User cancelled the task
  cancelled('cancelled'),

  /// User can't do this task (for example, it needs a subscription) and wants
  /// to pick another task in TaskGate. The app stays blocked.
  changeTask('change_task');

  final String value;
  const CompletionStatus(this.value);

  @override
  String toString() => value;
}
