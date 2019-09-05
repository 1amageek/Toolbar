Pod::Spec.new do |s|

  s.name         = "Toolbar"
  s.version      = "0.7.2"
  s.summary      = "Awesome autolayout Toolbar"
  s.description  = <<-DESC
  This toolbar is made with Autolayout.
  It works more interactively than UIToolbar.
                   DESC

  s.homepage     = "https://github.com/1amageek/Toolbar"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "1amageek" => "tmy0x3@icloud.com" }
  s.platform     = :ios, "11.0"
  s.ios.deployment_target = "11.0"
  s.source       = { :git => "https://github.com/1amageek/Toolbar.git", :tag => "#{s.version}" }
  s.source_files  = "Classes", "Toolbar/**/*.{swift}"


end
