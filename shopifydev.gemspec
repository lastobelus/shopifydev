# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'shopifydev/version'

Gem::Specification.new do |gem|
  gem.name          = "shopifydev"
  gem.version       = Shopifydev::VERSION
  gem.authors       = ["Michael Johnston"]
  gem.email         = ["lastobelus@mac.com"]
  gem.description   = %q{Tools for using SCM with shopify.}
  gem.summary       = %q{Abstract out and port to ruby the functionality of the shopify textmate bundle for use in other editors.}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  
  gem.add_dependency "shopify_api", ">= 3.0.0"
  gem.add_dependency "ruby-filemagic", ">= 0.4.2"
  gem.add_dependency "gli", ">= 2.5.2"

  # for console
  gem.add_dependency 'oj'  
  gem.add_dependency 'dalli'
  gem.add_dependency 'shydra'
  gem.add_dependency 'pry'
  
  gem.add_development_dependency "rake"
end
