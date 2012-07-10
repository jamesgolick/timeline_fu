# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "timeline_fu/version"

Gem::Specification.new do |s|
  s.name        = "timeline_fu"
  s.version     = TimelineFu::VERSION
  s.authors     = ["James Golick", "Mathieu Martin", "Francois Beausoleil"]
  s.email       = ["james@giraffesoft.ca"]
  s.homepage    = "http://github.com/giraffesoft/timeline_fu"
  s.summary     = %q{Easily build timelines, much like GitHub's news feed}
  s.description = %q{Easily build timelines, much like GitHub's news feed}

  s.has_rdoc = true

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
