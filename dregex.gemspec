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
  s.files        = Dir["{lib}/**/*.rb"]
  s.require_path = "lib"

  s.license       = "MIT"
end
