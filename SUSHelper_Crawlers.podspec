Pod::Spec.new do |s|
  s.name             = 'SUSHelper_Crawlers'
  s.version          = '1.2'
  s.summary          = 'Shared crawler library of SUSHelper App'

  s.homepage         = 'https://github.com/imxieyi/SUSHelper_Crawlers'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Xie Yi' => 'wez733@live.cn' }
  s.source           = { :git => 'https://github.com/imxieyi/SUSHelper_Crawlers.git', :tag => 'v1.2' }

  s.osx.deployment_target = '10.10'
  s.ios.deployment_target = '8.0'
  s.tvos.deployment_target = '9.0'
  s.watchos.deployment_target = '2.0'

  s.source_files = 'SUSHelper_Crawlers/Classes/**/*'

  s.pod_target_xcconfig = { 'HEADER_SEARCH_PATHS' => "$(SDKROOT)/usr/include/libxml2" }
  s.dependency 'Alamofire'
  s.dependency 'Kanna'
  s.dependency 'SwiftyJSON'
end
