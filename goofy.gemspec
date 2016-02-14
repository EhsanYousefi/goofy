Gem::Specification.new do |s|
  s.name              = "goofy"
  s.version           = "1.0.0"
  s.summary           = "Microframework for web applications"
  s.description       = "Goofy is a microframework for web applications(heavily based on Cuba)."
  s.authors           = ["Ehsan Yousefi"]
  s.email             = ["ehsan.yousefi@live.com"]
  s.homepage          = "https://github.com/EhsanYousefi/goofy"
  s.license           = "MIT"

  s.files = `git ls-files`.split("\n")
  s.require_paths = ["lib"]
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }

  s.add_dependency "rack", "~> 1.6.0"
  s.add_dependency "prong", '~> 1.0'
  s.add_dependency "require_all"
  s.add_dependency "psych"
  s.add_dependency "wisper"
  s.add_dependency "racksh"
  s.add_dependency "shotgun"
  s.add_development_dependency "cutest"
  s.add_development_dependency "rack-test"
  s.add_development_dependency "tilt"

end
