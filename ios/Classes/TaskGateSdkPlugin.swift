import Flutter
import UIKit
import TaskGateSDK

public class TaskGateSdkPlugin: NSObject, FlutterPlugin {
    private var channel: FlutterMethodChannel?
    private var registrar: FlutterPluginRegistrar?
    private var lastDeliveredSessionId: String? // Track to prevent duplicates
    
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
            if let taskInfo = TaskGateSDK.shared.getPendingTask() {
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
        TaskGateSDK.shared.initialize(providerId: providerId)
        
        // Set up callback to forward to Flutter
        TaskGateSDK.shared.setTaskCallback { [weak self] taskInfo in
            guard let self = self else { return }
            
            // Prevent duplicate deliveries
            if self.lastDeliveredSessionId == taskInfo.sessionId {
                print("[TaskGateSdkPlugin] Ignoring duplicate task: \(taskInfo.sessionId)")
                return
            }
            
            self.lastDeliveredSessionId = taskInfo.sessionId
            self.channel?.invokeMethod("onTaskReceived", arguments: self.taskInfoToDict(taskInfo))
        }
    }
    
    private func reportCompletion(status: String) {
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
        
        TaskGateSDK.shared.reportCompletion(completionStatus)
    }
    
    private func taskInfoToDict(_ taskInfo: TaskGateSDK.TaskInfo) -> [String: Any?] {
        return [
            "taskId": taskInfo.taskId,
            "sessionId": taskInfo.sessionId,
            "callbackUrl": taskInfo.callbackUrl,
            "appName": taskInfo.appName,
            "additionalParams": taskInfo.additionalParams
        ]
    }
    
    // MARK: - Application Delegate Methods
    
    public func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return TaskGateSDK.shared.handleURL(url)
    }
    
    public func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]) -> Void) -> Bool {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
              let url = userActivity.webpageURL else {
            return false
        }
        return TaskGateSDK.shared.handleURL(url)
    }
}
