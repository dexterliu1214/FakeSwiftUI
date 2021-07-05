#
# Be sure to run `pod lib lint FakeSwiftUI.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'FakeSwiftUI'
  s.version          = '0.1.0'
  s.summary          = 'A short description of FakeSwiftUI.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/youga/FakeSwiftUI'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'youga' => 'dexterliu1214@gmail.com' }
  s.source           = { :git => 'https://github.com/youga/FakeSwiftUI.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
  s.swift_version = '5.0'
  s.ios.deployment_target = '11.0'

  s.source_files = 'Sources/FakeSwiftUI/Classes/**/*.swift'
  
  # s.resource_bundles = {
  #   'FakeSwiftUI' => ['FakeSwiftUI/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
   s.frameworks = 'UIKit'
#   s.dependency 'AFNetworking', '~> 2.3'
   s.dependency 'RxSwift', '~> 5.1'
   s.dependency 'RxCocoa', '~> 5.1'
   s.dependency 'RxBinding'
   s.dependency 'RxAnimated'
   s.dependency 'RxGesture'
   s.dependency 'RxDataSources'
end
