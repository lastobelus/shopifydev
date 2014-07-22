# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'shopifydev/version'

Gem::Specification.new do |gem|
  gem.name          = "shopifydev"
  gem.version       = Shopifydev::VERSION
  gem.authors       = ["Michael Johnston"]
  gem.email         = ["lastobelus@mac.com"]
  gem.description   = %q{Abstracts out and port to ruby the functionality of the shopify textmate bundle for use in other editors. Provides a shopify console with the ability to switch between configured shops, using either custom app or oauth token style authentication. Provides caches of objects and convenience methods for fetching them.}
  gem.summary       = %q{ Tools for using SCM with shopify. Not Rails 4.0 ready. }
  gem.homepage      = "https://github.com/lastobelus/shopifydev"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  
  gem.add_dependency "json", ">= 1.8.0"

  gem.add_dependency 'activeresource'
  gem.add_dependency 'railties'
  gem.add_dependency 'activesupport'

  gem.add_dependency "shopify_api", ">= 3.2.0"
  gem.add_dependency "ruby-filemagic", ">= 0.4.2"
  gem.add_dependency "gli", ">= 2.5.2"

  # for console
  gem.add_dependency 'oj'
  gem.add_dependency 'dalli'
  gem.add_dependency 'shydra'
  gem.add_dependency 'shopify_unlimited'
  gem.add_dependency 'pry'
  gem.add_dependency 'term-ansicolor'
  gem.add_dependency 'awesome_print'

  # for generators
  gem.add_development_dependency "rake"

  # for fixtures
  gem.add_dependency 'ffaker'
  
end
