Pod::Spec.new do |s|

  s.name         = "Toolbar"
  s.version      = "0.0.4"
  s.summary      = "Awesome autolayout Toolbar"

  # This description is used to generate tags and improve search results.
  #   * Think: What does it do? Why did you write it? What is the focus?
  #   * Try to keep it short, snappy and to the point.
  #   * Write the description between the DESC delimiters below.
  #   * Finally, don't worry about the indent, CocoaPods strips it!
  s.description  = <<-DESC
  This toolbar is made with Autolayout.
  It works more interactively than UIToolbar.
                   DESC

  s.homepage     = "https://github.com/1amageek/Toolbar"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "1amageek" => "tmy0x3@icloud.com" }
  s.platform     = :ios, "9.0"
  s.ios.deployment_target = "9.0"
  s.source       = { :git => "https://github.com/1amageek/Toolbar.git", :tag => "#{s.version}" }
  s.source_files  = "Classes", "Toolbar/**/*.{swift}"


end
