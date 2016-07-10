Pod::Spec.new do |spec|
spec.name = "RxLocationManager"
spec.version = "1.0.0"
spec.summary = "Reactive Wrapper for CLLocationManager"
spec.homepage = "https://github.com/popduke/RxLocationManager"
spec.license = { type: 'MIT', file: 'LICENSE' }
spec.authors = { "Your Name" => 'popduke@gmail.com' }

spec.ios.deployment_target = '8.0'
spec.osx.deployment_target = '10.9'
spec.watchos.deployment_target = '2.0'
spec.tvos.deployment_target = '9.0'

spec.frameworks  = "Foundation", "CoreLocation"
spec.requires_arc = true
spec.source = { git: "https://github.com/popduke/RxLocationManager.git", tag: "v#{spec.version}", submodules: true }
spec.source_files = "Sources/**/*.{h,swift}"

spec.dependency "RxSwift", "~> 2.0"
end