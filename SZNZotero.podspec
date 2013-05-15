Pod::Spec.new do |s|
  s.name         = "SZNZotero"
  s.version      = "1.0"
  s.summary      = "Objective-C client for the Zotero API."
  s.homepage     = "https://github.com/shazino/SZNZotero"
  s.license      = 'MIT'
  s.author       = { 'shazino' => 'contact@shazino.com' }
#  s.source       = { :git => "https://github.com/shazino/SZNZotero.git", :tag => '1.0' }

  s.source_files = 'SZNZotero/SZN*'
  s.requires_arc = true

  s.ios.deployment_target = '5.0'
  s.ios.frameworks = 'Security'

  s.osx.deployment_target = '10.7'

  s.dependency 'AFOAuth1Client', '0.2.0'
  s.dependency 'TBXML', '1.5'

  s.subspec 'google-toolbox-mac' do |gtm|
    gtm.source_files = 'SZNZotero/GTMDefines.h', 'SZNZotero/GTMNSString+HTML.{h,m}'
    gtm.requires_arc = false
  end
end
