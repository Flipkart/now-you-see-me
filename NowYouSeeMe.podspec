Pod::Spec.new do |s|
  s.name             = 'NowYouSeeMe'
  s.version          = '1.0.0'
  s.summary          = 'View tracking framework for iOS'

  s.description      = <<-DESC
'NowYouSeeMe is a view tracking framework written in Swift that can be attached to an instance of UIView or any of its subclasses with a single API written on UIView. Views can also add custom viewability conditions and listeners.'
                       DESC

  s.homepage         = 'https://flipkart.github.io/now-you-see-me/'
  s.license          = { :type => 'Apache, Version 2.0', :file => 'LICENSE' }
  s.author           = { 'naveen-c' => 'naveen.c@flipkart.com' }
  s.source           = { :git => 'https://github.com/Flipkart/now-you-see-me.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'
  s.swift_version = '5'
  
  s.source_files = 'Source/Classes/**/*.{h,m,swift}'
  s.resources = 'Source/**/*.{xcassets,xib,storyboard}'
  
  s.dependency 'FCChatHeads'
  
end
