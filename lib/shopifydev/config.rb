require 'active_support/core_ext/hash'

module Shopifydev
  module Config
    def self.config
      YAML::load(File.open(File.expand_path('~/.shopifydev.yaml'))).with_indifferent_access
    end
  end
end
