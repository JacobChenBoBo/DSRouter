Pod::Spec.new do |s|
  version = "0.1.1"
  s.name         = “DSRouter”
  s.version      = version
  s.summary      = "A native in-app URL router for iOS."
  s.homepage     = "https://github.com/JacobChenBoBo/DSRouter.git"
  s.author       = { “JacobChenBoBo” => “JacobChenBo@outlook.com” }
  s.source       = { :git => "https://github.com/JacobChenBoBo/DSRouter.git", :tag => version }
  s.platform     = :ios, '5.0'
  s.source_files = ‘DSRouter/DSRouter.{h,m}’
  s.requires_arc = true
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
end
