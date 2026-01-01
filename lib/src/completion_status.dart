/// Task completion status
enum CompletionStatus {
  /// User completed task and wants to open the blocked app
  open('open'),

  /// User completed task but wants to stay focused
  focus('focus'),

  /// User cancelled the task
  cancelled('cancelled');

  final String value;
  const CompletionStatus(this.value);

  @override
  String toString() => value;
}
