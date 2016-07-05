Pod::Spec.new do |spec|
spec.name = "RxLocationManager"
spec.version = "1.0.0"
spec.summary = "Reactive Wrapper for CLLocationManager"
spec.homepage = "https://github.com/popduke/RxLocationManager"
spec.license = { type: 'MIT', file: 'LICENSE' }
spec.authors = { "Your Name" => 'popduke@gmail.com' }

spec.platform =
spec.requires_arc = true
spec.source = { git: "https://github.com/popduke/RxLocationManager.git", tag: "v#{spec.version}", submodules: true }
spec.source_files = "Sources/**/*.{h,swift}"

spec.dependency "ReactiveX/RxSwift", "~> 2.0"
end