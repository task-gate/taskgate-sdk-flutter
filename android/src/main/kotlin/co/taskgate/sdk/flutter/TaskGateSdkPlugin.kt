package co.taskgate.sdk.flutter

import android.app.Activity
import android.content.Intent
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
import com.taskgate.sdk.TaskGateSDK

/**
 * TaskGateSdkPlugin - Flutter plugin for TaskGate SDK
 */
class TaskGateSdkPlugin : FlutterPlugin, MethodCallHandler, ActivityAware,
    PluginRegistry.NewIntentListener {
    
    private lateinit var channel: MethodChannel
    private var activity: Activity? = null
    private var activityBinding: ActivityPluginBinding? = null
    private var lastDeliveredSessionId: String? = null // Track to prevent duplicates
    
    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "taskgate_sdk")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "initialize" -> {
                val providerId = call.argument<String>("providerId")
                if (providerId != null) {
                    initialize(providerId)
                    result.success(null)
                } else {
                    result.error("INVALID_ARGUMENT", "providerId is required", null)
                }
            }
            "getPendingTask" -> {
                val taskInfo = TaskGateSDK.getPendingTask()
                if (taskInfo != null) {
                    result.success(taskInfoToMap(taskInfo))
                } else {
                    result.success(null)
                }
            }
            "reportCompletion" -> {
                val status = call.argument<String>("status")
                if (status != null) {
                    reportCompletion(status)
                    result.success(null)
                } else {
                    result.error("INVALID_ARGUMENT", "status is required", null)
                }
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun initialize(providerId: String) {
        val act = activity
        if (act != null) {
            TaskGateSDK.initialize(act.application, providerId)

            // Set up callback to forward to Flutter
            TaskGateSDK.setTaskCallback { taskInfo ->
                // Prevent duplicate deliveries
                if (lastDeliveredSessionId == taskInfo.sessionId) {
                    android.util.Log.d("TaskGateSdkPlugin", "Ignoring duplicate task: ${taskInfo.sessionId}")
                    return@setTaskCallback
                }
                
                lastDeliveredSessionId = taskInfo.sessionId
                channel.invokeMethod("onTaskReceived", taskInfoToMap(taskInfo))
            }

            // Handle initial intent if app was cold started via deep link
            handleIntent(act.intent)
        }
    }

    private fun reportCompletion(status: String) {
        val completionStatus = when (status) {
            "open" -> TaskGateSDK.CompletionStatus.OPEN
            "focus" -> TaskGateSDK.CompletionStatus.FOCUS
            "cancelled" -> TaskGateSDK.CompletionStatus.CANCELLED
            else -> TaskGateSDK.CompletionStatus.CANCELLED
        }
        
        // Clear tracking state to prevent stale tasks on next start
        lastDeliveredSessionId = null
        
        TaskGateSDK.reportCompletion(completionStatus)
    }

    private fun handleIntent(intent: Intent?): Boolean {
        if (intent?.data != null) {
            val handled = TaskGateSDK.handleIntent(intent)
            if (handled) {
                // Task info is now pending, will be delivered via callback or getPendingTask
                return true
            }
        }
        return false
    }

    private fun taskInfoToMap(taskInfo: TaskGateSDK.TaskInfo): Map<String, Any?> {
        return mapOf(
            "taskId" to taskInfo.taskId,
            "sessionId" to taskInfo.sessionId,
            "appName" to taskInfo.appName,
            "additionalParams" to taskInfo.additionalParams
        )
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    // ActivityAware implementation
    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        activityBinding = binding
        binding.addOnNewIntentListener(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activityBinding?.removeOnNewIntentListener(this)
        activity = null
        activityBinding = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
        activityBinding = binding
        binding.addOnNewIntentListener(this)
    }

    override fun onDetachedFromActivity() {
        activityBinding?.removeOnNewIntentListener(this)
        activity = null
        activityBinding = null
    }

    // NewIntentListener implementation (for warm start)
    override fun onNewIntent(intent: Intent): Boolean {
        return handleIntent(intent)
    }
}
