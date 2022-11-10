require File.expand_path("../lib/dregex/version", __FILE__)

Gem::Specification.new do |s|
  s.name         = "dregex"
  s.version      = Dregex::VERSION
  s.summary      = "Regex parser"
  s.description  = "A regex parser implemented in pure Ruby"
  s.authors      = ["Daniel Holz"]
  s.email        = "dgholz@gmail.com"
  s.homepage     = "http://github.com/dgholz/dregex"
  s.metadata     = { "source_code_uri" => "https://github.com/dgholz/dregex" }
  s.files        = Dir["{lib}/**/*.rb", "bin/*"]
  s.require_path = "lib"
  s.executables  = ["dregex"]

  s.add_development_dependency "rake", "~> 12.0"
  s.add_development_dependency "minitest", ">= 5.8"
  s.add_development_dependency "minitest-reporters", ">= 1.1"
  s.add_development_dependency "minitest-skip"

  s.add_dependency "slop"

  s.license       = "MIT"
end
