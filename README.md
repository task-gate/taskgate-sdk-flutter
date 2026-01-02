# TaskGate SDK for Flutter

[![pub package](https://img.shields.io/pub/v/taskgate_sdk.svg)](https://pub.dev/packages/taskgate_sdk)

TaskGate SDK allows Flutter apps to integrate with [TaskGate](https://taskgate.co) to receive task requests and report task completion status.

## Features

- 🚀 Simple Dart API
- 📱 iOS and Android support
- ⚡ Stream-based task delivery
- 🔄 Handles cold start and warm start scenarios
- ⏰ Automatic lifecycle management


![Demo](https://github.com/user-attachments/assets/cadb9e88-6062-4061-8ffa-d6f68fbffda3)

▶️ **Watch full demo video:**  
https://taskgate.co/mock/demo2.mp4

## Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  taskgate_sdk: ^1.1.0
```

Then run:

```bash
flutter pub get
```

## Platform Setup

### iOS

#### 1. Add TaskGateSDK dependency

The SDK is automatically included via CocoaPods. Make sure your `ios/Podfile` has:

```ruby
platform :ios, '13.0'
```

#### 2. Configure Universal Links

Add your associated domain in Xcode:

1. Open `ios/Runner.xcworkspace`
2. Select your target → Signing & Capabilities
3. Add "Associated Domains" capability
4. Add `applinks:yourdomain.com`

Create an `.well-known/apple-app-site-association` file on your server:

```json
{
  "applinks": {
    "apps": [],
    "details": [
      {
        "appIDs": ["TEAM_ID.your.bundle.id"],
        "paths": ["/taskgate/*"]
      }
    ]
  }
}
```

### Android

#### 1. Add TaskGate SDK to your app's build.gradle

The SDK is automatically included. Ensure your `android/app/build.gradle` has:

```groovy
android {
    defaultConfig {
        minSdkVersion 21
    }
}
```

#### 2. Configure App Links

Add to your `AndroidManifest.xml`:

```xml
<activity android:name=".MainActivity">
    <intent-filter android:autoVerify="true">
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data
            android:scheme="https"
            android:host="yourdomain.com"
            android:pathPrefix="/taskgate" />
    </intent-filter>
</activity>
```

Create an `.well-known/assetlinks.json` file on your server:

```json
[
  {
    "relation": ["delegate_permission/common.handle_all_urls"],
    "target": {
      "namespace": "android_app",
      "package_name": "your.package.name",
      "sha256_cert_fingerprints": ["YOUR_SHA256_FINGERPRINT"]
    }
  }
]
```

## Usage

### Initialize the SDK

Initialize early in your app's lifecycle:

```dart
import 'package:taskgate_sdk/taskgate_sdk.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize with your provider ID
  await TaskGateSdk.initialize(providerId: 'your_provider_id');

  runApp(MyApp());
}
```

### Listen for Tasks

Use the stream to receive task notifications. The stream automatically replays any pending task from cold start:

```dart
class _MyAppState extends State<MyApp> {
  StreamSubscription<TaskInfo>? _taskSubscription;

  @override
  void initState() {
    super.initState();

    // Listen for incoming tasks (auto-replays pending task on cold start)
    _taskSubscription = TaskGateSdk.taskStream.listen((task) {
      print('Received task: ${task.taskId}');
      _navigateToTask(task);
    });
  }

  void _navigateToTask(TaskInfo task) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TaskScreen(task: task),
      ),
    );
  }

  @override
  void dispose() {
    _taskSubscription?.cancel();
    super.dispose();
  }
}
```

### Report Completion

When the user completes a task:

```dart
// User completed task and wants to open the blocked app
await TaskGateSdk.reportCompletion(CompletionStatus.open);

// User completed task but wants to stay focused
await TaskGateSdk.reportCompletion(CompletionStatus.focus);

// User cancelled the task
await TaskGateSdk.reportCompletion(CompletionStatus.cancelled);
// or use the convenience method:
await TaskGateSdk.cancelTask();
```

## API Reference

### TaskGateSdk

| Method                     | Description                              |
| -------------------------- | ---------------------------------------- |
| `initialize(providerId)`   | Initialize the SDK with your provider ID |
| `taskStream`               | Stream of incoming task requests         |
| `getPendingTask()`         | Get pending task (for cold start)        |
| `reportCompletion(status)` | Report task completion                   |
| `cancelTask()`             | Cancel the current task                  |
| `hasActiveSession()`       | Check if a task session is active        |
| `currentTask`              | Get the current cached task              |
| `dispose()`                | Clean up SDK resources                   |

### TaskInfo

| Property           | Type                  | Description               |
| ------------------ | --------------------- | ------------------------- |
| `taskId`           | `String`              | Unique task identifier    |
| `sessionId`        | `String`              | Session identifier        |
| `callbackUrl`      | `String`              | URL to return to TaskGate |
| `appName`          | `String?`             | Name of blocked app       |
| `additionalParams` | `Map<String, String>` | Additional parameters     |

### CompletionStatus

| Value       | Description                           |
| ----------- | ------------------------------------- |
| `open`      | User completed task, open blocked app |
| `focus`     | User completed task, stay focused     |
| `cancelled` | User cancelled the task               |

## Example

See the [example](example/) directory for a complete sample app.

## Becoming a Partner

Visit **[taskgate.co](https://taskgate.co)** to learn more about partnership opportunities.

**[Contact us](https://taskgate.co/contact-us)** to register and get your `providerId`.

---

## Support

- **Website:** [taskgate.co](https://taskgate.co)
- **Contact:** [taskgate.co/contact-us](https://taskgate.co/contact-us)
- **Docs:** [taskgate.co/partnership](https://taskgate.co/partnership)

---

## License

MIT License - See [LICENSE](LICENSE) file for details.

---

**Made with ❤️ for TaskGate Partners**
