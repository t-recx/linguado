# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'linguado/version'

Gem::Specification.new do |spec|
  spec.name          = "linguado"
  spec.version       = Linguado::VERSION
  spec.authors       = ["João Bruno"]
  spec.email         = ["bruno.joao@live.com.pt"]

  spec.summary       = "Learn languages from your terminal"
  spec.description   = "Learn languages from your terminal"
  spec.homepage      = "https://github.com/t-recx/linguado"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "text"
  spec.add_dependency "tty-prompt"
  spec.add_dependency "tty-progressbar"
  spec.add_dependency "tty-cursor"
  spec.add_dependency "tty-screen"
  spec.add_dependency "sqlite3"
  spec.add_dependency "sequel"
  spec.add_dependency "artii"

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "minitest-reporters"
  spec.add_development_dependency "minitest-hooks"
  spec.add_development_dependency "guard"
  spec.add_development_dependency "guard-minitest"
end
