# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "bnicovideo/version"

Gem::Specification.new do |s|
  s.name        = "bnicovideo"
  s.version     = Bnicovideo::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["MH35"]
  s.email       = ["contact@mh35.info"]
  s.homepage    = ""
  s.summary     = %q{Get niconico douga video information using browser's cookie}
  s.description = %q{Get niconico douga video information using browser's cookie}

  s.rubyforge_project = "bnicovideo"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
