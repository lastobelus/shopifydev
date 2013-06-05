module Shopifydev
  module Config
    def self.load
      YAML::load(File.open(File.expand_path('~/.shopifydev.yaml')))
    end

    def self.config
      @config ||= load
    end

    
  end
end
