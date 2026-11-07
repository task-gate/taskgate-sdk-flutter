import Flutter
import UIKit
import TaskGateSDK

public class TaskGateSdkPlugin: NSObject, FlutterPlugin {
    private var channel: FlutterMethodChannel?
    private var registrar: FlutterPluginRegistrar?
    private var lastDeliveredSessionId: String? // Track to prevent duplicates
    private var providerId: String?
    // The native SDK keeps the callback link private, so the plugin keeps its
    // own copy for results the native SDK doesn't know (change_task).
    private var callbackUrl: String?
    // A session the plugin finished itself; the native SDK still holds it.
    private var completedSessionId: String?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "taskgate_sdk", binaryMessenger: registrar.messenger())
        let instance = TaskGateSdkPlugin()
        instance.channel = channel
        instance.registrar = registrar
        registrar.addMethodCallDelegate(instance, channel: channel)
        registrar.addApplicationDelegate(instance)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "initialize":
            guard let args = call.arguments as? [String: Any],
                  let providerId = args["providerId"] as? String else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "providerId is required", details: nil))
                return
            }
            initialize(providerId: providerId)
            result(nil)
            
        case "getPendingTask":
            if let taskInfo = TaskGateSDK.shared.getPendingTask(),
               taskInfo.sessionId != completedSessionId {
                result(taskInfoToDict(taskInfo))
            } else {
                result(nil)
            }
            
        case "reportCompletion":
            guard let args = call.arguments as? [String: Any],
                  let status = args["status"] as? String else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "status is required", details: nil))
                return
            }
            reportCompletion(status: status)
            result(nil)
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func initialize(providerId: String) {
        self.providerId = providerId
        TaskGateSDK.shared.initialize(providerId: providerId)
        
        // Set up callback to forward to Flutter
        TaskGateSDK.shared.setTaskCallback { [weak self] taskInfo in
            guard let self = self else { return }
            
            // Prevent duplicate deliveries
            if self.lastDeliveredSessionId == taskInfo.sessionId ||
                self.completedSessionId == taskInfo.sessionId {
                print("[TaskGateSdkPlugin] Ignoring duplicate task: \(taskInfo.sessionId)")
                return
            }
            
            self.lastDeliveredSessionId = taskInfo.sessionId
            self.channel?.invokeMethod("onTaskReceived", arguments: self.taskInfoToDict(taskInfo))
        }
    }
    
    private func reportCompletion(status: String) {
        if status == "change_task" {
            reportChangeTask()
            return
        }
        let completionStatus: TaskGateSDK.CompletionStatus
        switch status {
        case "open":
            completionStatus = .open
        case "focus":
            completionStatus = .focus
        case "cancelled":
            completionStatus = .cancelled
        default:
            completionStatus = .cancelled
        }
        
        // Clear tracking state to prevent stale tasks on next start
        lastDeliveredSessionId = nil
        callbackUrl = nil
        
        TaskGateSDK.shared.reportCompletion(completionStatus)
    }

    /// Opens TaskGate's callback link with status=change_task, built the same
    /// way as the native SDK's reportCompletion.
    private func reportChangeTask() {
        guard let task = TaskGateSDK.shared.getPendingTask(),
              task.sessionId != completedSessionId,
              let callback = callbackUrl,
              var components = URLComponents(string: callback) else {
            print("[TaskGateSdkPlugin] change_task: no pending task")
            return
        }
        var queryItems = components.queryItems ?? []
        queryItems.append(URLQueryItem(name: "status", value: "change_task"))
        if let providerId = providerId {
            queryItems.append(URLQueryItem(name: "provider_id", value: providerId))
        }
        queryItems.append(URLQueryItem(name: "session_id", value: task.sessionId))
        queryItems.append(URLQueryItem(name: "task_id", value: task.taskId))
        components.queryItems = queryItems
        guard let url = components.url else { return }
        DispatchQueue.main.async {
            UIApplication.shared.open(url)
        }
        completedSessionId = task.sessionId
        lastDeliveredSessionId = nil
        callbackUrl = nil
        print("[TaskGateSdkPlugin] Completed: change_task")
    }

    /// Keeps the callback link of a TaskGate task link the SDK accepted.
    private func handle(url: URL) -> Bool {
        let handled = TaskGateSDK.shared.handleURL(url)
        if handled {
            callbackUrl = URLComponents(url: url, resolvingAgainstBaseURL: true)?
                .queryItems?.first(where: { $0.name == "callback_url" })?.value
        }
        return handled
    }
    
    private func taskInfoToDict(_ taskInfo: TaskGateSDK.TaskInfo) -> [String: Any?] {
        return [
            "taskId": taskInfo.taskId,
            "sessionId": taskInfo.sessionId,
            "appName": taskInfo.appName,
            "additionalParams": taskInfo.additionalParams
        ]
    }
    
    // MARK: - Application Delegate Methods
    
    public func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return handle(url: url)
    }
    
    public func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]) -> Void) -> Bool {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
              let url = userActivity.webpageURL else {
            return false
        }
        return handle(url: url)
    }
}
