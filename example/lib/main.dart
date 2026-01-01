import 'dart:async';

import 'package:flutter/material.dart';
import 'package:taskgate_sdk/taskgate_sdk.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize TaskGate SDK
  await TaskGateSdk.initialize(providerId: 'example_provider');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TaskGate SDK Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  StreamSubscription<TaskInfo>? _taskSubscription;
  TaskInfo? _currentTask;

  @override
  void initState() {
    super.initState();

    // Listen for incoming tasks
    _taskSubscription = TaskGateSdk.taskStream.listen(_handleTask);

    // Check for pending task on cold start
    _checkPendingTask();
  }

  Future<void> _checkPendingTask() async {
    final task = await TaskGateSdk.getPendingTask();
    if (task != null) {
      _handleTask(task);
    }
  }

  void _handleTask(TaskInfo task) {
    setState(() {
      _currentTask = task;
    });

    // Navigate to task screen
    if (mounted) {
      Navigator.of(context)
          .push(
        MaterialPageRoute(
          builder: (_) => TaskScreen(task: task),
        ),
      )
          .then((_) {
        setState(() {
          _currentTask = null;
        });
      });
    }
  }

  @override
  void dispose() {
    _taskSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TaskGate SDK Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.task_alt,
              size: 80,
              color: Colors.blue,
            ),
            const SizedBox(height: 24),
            const Text(
              'TaskGate SDK Ready',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              _currentTask != null
                  ? 'Active task: ${_currentTask!.taskId}'
                  : 'Waiting for task from TaskGate...',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class TaskScreen extends StatelessWidget {
  final TaskInfo task;

  const TaskScreen({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Task'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Task: ${task.taskId}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (task.appName != null)
                      Text(
                        'Blocked App: ${task.appName}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      'Session: ${task.sessionId}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Complete your task here...',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () => _completeTask(context, CompletionStatus.open),
              icon: const Icon(Icons.check_circle),
              label: const Text('Done - Open App'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => _completeTask(context, CompletionStatus.focus),
              icon: const Icon(Icons.psychology),
              label: const Text('Done - Stay Focused'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () =>
                  _completeTask(context, CompletionStatus.cancelled),
              icon: const Icon(Icons.cancel),
              label: const Text('Cancel'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _completeTask(
      BuildContext context, CompletionStatus status) async {
    await TaskGateSdk.reportCompletion(status);
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }
}
