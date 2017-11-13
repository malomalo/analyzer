require File.expand_path("../lib/analyzer/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "analyzer"
  s.version     = Analyzer::VERSION
  s.licenses    = ['MIT']
  s.authors     = ["Jon Bracy"]
  s.email       = ["jonbracy@gmail.com"]
  s.homepage    = "https://github.com/malomalo/analyzer"
  s.summary     = %q{A Performance analyzer for Ruby}
  s.metadata    = { "source_code_uri" => "https://github.com/malomalo/analyzer" }
  
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.required_ruby_version = '>= 2'
  s.requirements << 'gnuplot'
  
  s.add_runtime_dependency 'benchmark-ips', '~> 2.7'
end
