Pod::Spec.new do |s|

  s.name         = "GenumKit"
  s.version      = "0.8.0"
  s.summary      = "A tool to build constants using enums for your UIImage, Storyboards, Assets, Colors, and more"

  s.description  = <<-DESC
                   GenumKit is a framework to build constants using enums for:
                    - UIImages from your Assets Catalogs
                    - Storyboards, to instantiate scenes and identify segues using constants
                    - UIColors, to have named colors using an enums
                    - Localizable.strings so that you can format your localized text way easier!

                   This framework is used by the swiftgen Command Line tool
                   DESC

  s.homepage     = "https://github.com/SwiftGen/SwiftGen"
  s.license      = "MIT"
  s.author       = { "Olivier Halligon" => "olivier@halligon.net" }
  s.social_media_url = "https://twitter.com/aligatr"

  s.platform = :osx, '10.9'

  s.source       = { :git => "https://github.com/SwiftGen/SwiftGen.git", :tag => s.version.to_s }

  s.source_files = "**/*.swift"

  s.dependency 'Stencil'
  s.framework  = "Foundation"
end
