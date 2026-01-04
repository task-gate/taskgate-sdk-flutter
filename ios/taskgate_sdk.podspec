#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint taskgate_sdk.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'taskgate_sdk'
  s.version          = '1.0.0'
  s.summary          = 'TaskGate SDK for Flutter - integrate with TaskGate to receive tasks'
  s.description      = <<-DESC
TaskGate SDK allows partner apps to integrate with TaskGate to receive task requests
and report task completion status.
                       DESC
  s.homepage         = 'https://taskgate.co'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'TaskGate' => 'support@taskgate.co' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'TaskGateSDK', '~> 1.0.6'
  s.platform         = :ios, '13.0'
  
  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
