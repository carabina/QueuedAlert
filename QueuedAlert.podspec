Pod::Spec.new do |s|
  s.name             = 'QueuedAlert'
  s.version          = "1.0.0"
  s.summary          = "UIAlertController in queue"
  s.homepage         = "https://github.com/Meniny/QueuedAlert"
  s.license          = { :type => "MIT", :file => "LICENSE" }
  s.author           = 'Elias Abel'
  s.source           = { :git => "https://github.com/Meniny/QueuedAlert.git", :tag => s.version.to_s }
  s.social_media_url = 'https://meniny.cn/'
  s.source_files     = "QueuedAlert/**/*.swift"
  s.requires_arc     = true
  s.ios.deployment_target = "8"
  s.description  = "Make UIAlertController in queue"
  s.module_name = 'QueuedAlert'
end
