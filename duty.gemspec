lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "duty/version"

Gem::Specification.new do |spec|
  spec.name          = "Duty"
  spec.version       = Duty::VERSION
  spec.authors       = ["Jan Owiesniak"]
  spec.email         = ["jowiesniak@gmail.com"]

  spec.summary       = "High-level repository operations"
  spec.description   = "Duty provides high-level repository operations for common git tasks"
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
