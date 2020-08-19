
Pod::Spec.new do |s|
  s.name             = 'LZDependencyControllerkit'
  s.version          = '0.4.2'
  s.summary          = 'LZDependencyControllerkit.'
  s.description      = <<-DESC
  控制器控件：
  1.TabBarController
  2.WebViewController
  3.StartPageController
                       DESC
  s.homepage         = 'https://github.com/liLeiBest'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'lilei' => 'lilei_hapy@163.com' }
  s.source           = { :git => 'https://github.com/liLeiBest/LZDependencyControllerkit.git', :tag => s.version.to_s }

  s.ios.deployment_target 	= '9.0'
  s.frameworks 				= 'UIKit', 'Foundation'
  s.source_files 			= 'LZDependencyControllerkit/Classes/LZDependencyControllerkit.h'
  s.public_header_files		= 'LZDependencyControllerkit/Classes/LZDependencyControllerkit.h'
  
  s.dependency 'LZDependencyToolkit'
  
  s.subspec 'TabBarController' do |tabBarController|
	  tabBarController.source_files			= 'LZDependencyControllerkit/Classes/TabBarController/**/*.{h,m}'
	  tabBarController.public_header_files 	= 'LZDependencyControllerkit/Classes/TabBarController/**/*.h'
  end
  
  s.subspec 'WebViewController' do |webViewController|
	  webViewController.source_files		= 'LZDependencyControllerkit/Classes/WebViewController/**/*.{h,m}'
	  webViewController.public_header_files = 'LZDependencyControllerkit/Classes/WebViewController/**/*.h'
	  webViewController.frameworks = 'WebKit'
  end

  s.subspec 'StartPageController' do |startPageController|
      startPageController.source_files        =
      'LZDependencyControllerkit/Classes/StartPageController/**/*.{h,m}',
#      'LZDependencyControllerkit/Classes/StartPageController/Controller/**/*.{storyboard}',
      ''
      startPageController.public_header_files = 'LZDependencyControllerkit/Classes/StartPageController/**/*.h'
      startPageController.resource            = 'LZDependencyControllerkit/Classes/StartPageController/Resources/LZStartPageController.bundle'
  end
  
  pch_AF = <<-EOS
  
  //static NSString * const LZDependencyControllerkitBundle = @"LZDependencyControllerkitResourceBundle";
  
  #import <LZDependencyToolkit/LZDependencyToolkit.h>
  
  EOS
  s.prefix_header_contents = pch_AF
  
end
