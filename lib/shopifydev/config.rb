require 'active_support/core_ext/hash'
require 'singleton'

module Shopifydev
  module Config
    class Data
      include Singleton

      def datafilepath
        File.expand_path('~/.shopifydev.data')
      end

      def write
        File.open(datafilepath, 'w'){ |f| YAML.dump(data, f) }
      end

      def data
        data ||= YAML::load(File.open(
          datafilepath
        )).with_indifferent_access
      end

      def []=(key,value)
        data[key] = value
        write
      end

      def [](key)        
        data[key]
      end
    end

    def self.config
      YAML::load(File.open(File.expand_path('~/.shopifydev.yaml'))).with_indifferent_access
    end
  end
end
