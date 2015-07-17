# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sindup/version'

Gem::Specification.new do |gem|
  gem.name          = "sindup"
  gem.version       = Sindup::VERSION::STRING.dup
  gem.authors       = ["Jean-Guillaume BURET"]
  gem.email         = ["jg.buret@gmail.com"]
  gem.summary       = %q{Gem to wrap sindup.com API.}
  gem.description   = %q{Gem to wrap sindup.com API}
  gem.homepage      = "https://github.com/etrnljg/sindup"
  gem.license       = "MIT"

  gem.files         = Dir['lib/**/*.rb']
  gem.executables   = gem.files.grep(%r{^bin/}) { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|gem|features)/})
  gem.require_paths = %w[ lib ]

  gem.add_dependency "oauth2", "~> 1.0.0"
  gem.add_dependency "mechanize"

  gem.add_development_dependency "bundler", "~> 1.7"
  gem.add_development_dependency "rake", "~> 10.0"
end
