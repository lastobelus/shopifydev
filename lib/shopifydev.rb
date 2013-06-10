require_relative "shopifydev/version"
require_relative "shopifydev/config"
require_relative "shopifydev/shop"
require_relative "shopifydev/template"
require_relative "shopifydev/asset"
require_relative "shopifydev/commands"
require_relative "shopifydev/faker"
require_relative "shopifydev/railtie" if defined?(Rails)

module Shopifydev
end
