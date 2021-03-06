lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "duty/version"

Gem::Specification.new do |spec|
  spec.name          = "duty"
  spec.version       = Duty::VERSION
  spec.authors       = ["Jan Owiesniak"]
  spec.email         = ["owiesniak@mailbox.org"]

  spec.summary       = "Extendable Task Manager"
  spec.description   = "Duty provides a CLI for high-level tasks"
  spec.homepage      = "https://github.com/JanOwiesniak/duty"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.executables   = spec.files.grep(%r{^bin\/}) { |f| File.basename(f) }

  spec.require_paths = ["lib"]

  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.8"
end
