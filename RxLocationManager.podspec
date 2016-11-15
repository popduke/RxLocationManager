Pod::Spec.new do |spec|
    spec.name = "RxLocationManager"
    spec.version = "1.1.0"
    spec.summary = "Reactive Style Location Manager for iOS, macOS, watchOS, tvOS"
    spec.description = "If you programs in functional reactive style in iOS, RxLocationManager makes location management a lot easier comparing to CLLocationManager"
    spec.homepage = "https://github.com/popduke/RxLocationManager"
    spec.license = { type: 'MIT', file: 'LICENSE.md' }
    spec.authors = { "Yonny Hao" => 'popduke@gmail.com' }

    spec.ios.deployment_target = '8.0'
    spec.osx.deployment_target = '10.10'
    spec.watchos.deployment_target = '2.0'
    spec.tvos.deployment_target = '9.0'

    spec.frameworks  = "Foundation", "CoreLocation"
    spec.requires_arc = true
    spec.source = { git: "https://github.com/popduke/RxLocationManager.git", tag: spec.version.to_s }
    spec.source_files = 'sources/*.{h,swift}'

    spec.dependency "RxSwift", "~> 3.0"
end
