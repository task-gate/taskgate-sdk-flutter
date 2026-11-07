# Changelog

## 1.0.13 - 2026-11-07

* iOS: Swift Package Manager support, so apps without CocoaPods can use the
  plugin. The plugin's Swift code moved to `ios/taskgate_sdk/Sources/`; the
  podspec still works for CocoaPods apps.

## 1.0.12 - 2026-11-07

* Add `CompletionStatus.changeTask`: sends the user back to TaskGate to pick
  another task when they can't do yours (for example, it needs a
  subscription). The blocked app stays blocked.
* `getPendingTask()` no longer returns a task that was finished with
  `changeTask`.

## 1.0.11 - 2026-01-04

* Release version 1.0.11

## 1.0.10 - 2026-01-04

* Release version 1.0.10

## 1.0.9 - 2026-01-04

* Release version 1.0.9

## 1.0.8 - 2026-01-04

* Release version 1.0.8

## 1.0.7 - 2026-01-01

* Release version 1.0.7

## 1.1.0 - 2026-01-01

### Fixed

- **Cold Start Race Condition**: `taskStream` now replays the pending task to new subscribers, solving the issue where tasks were lost when native SDK fired before Flutter subscribed
- **Android Build Failure**: Fixed package import from `co.taskgate.sdk` to `com.taskgate.sdk` to match the native SDK's actual package
- **Stale Task on iOS Warm Start**: Task state is now properly cleared after `reportCompletion()`, preventing stale tasks from being replayed on subsequent starts

### Improved

- Added session tracking to prevent duplicate task emissions
- Added `_lastCompletedSessionId` tracking to filter out stale tasks from completed sessions

## 1.0.6 - 2026-01-01

- Release version 1.0.6

## 1.0.5 - 2026-01-01

- Release version 1.0.5

## 1.0.4 - 2026-01-01

- Release version 1.0.4

## 1.0.3 - 2026-01-01

- Release version 1.0.3

## 1.0.2 - 2026-01-01

- Release version 1.0.2

## 1.0.1 - 2026-01-01

- Release version 1.0.1

## 1.0.0

- Initial release
- iOS and Android support
- Stream-based task delivery
- Automatic lifecycle management
- Cold start and warm start support
