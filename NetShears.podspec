Pod::Spec.new do |s|

  s.name         = "NetShears"
  s.version      = "3.2.1"
  s.summary      = "iOS Network interceptor framework written in Swift"

  s.description  = <<-DESC
                   NetShears adds a Request interceptor mechanisms to be able to modify the HTTP/HTTPS Request before being sent . This mechanism can be used to implement authentication policies, add headers to a request , add log trace or even redirect requests.
                   DESC

  s.homepage     = "https://github.com/divar-ir/NetShears"
  s.screenshots  = "https://raw.githubusercontent.com/divar-ir/NetShears/master/logo.png"

  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.authors            = { "Mehdi Mirzaie" => "mehdiimrz@gmail.com" }
  s.social_media_url   = "https://github.com/mehdiimrz"

  s.swift_versions = ['5.3']
  s.ios.deployment_target = '9.0'

  s.source       = { :git => "https://github.com/divar-ir/NetShears.git", :tag => s.version }
  s.source_files  = ["Sources/**/*.swift"]

  s.resource_bundles = {
    'NetShears' => ['Sources/**/*.storyboard', 'Sources/**/*.xib']
  }
  s.frameworks  = "Foundation"

end
