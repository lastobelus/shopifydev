require "logger"
require "shopify_api"

module Shopifydev
  class Shop
    attr_accessor :credentials, :logger
  
    def initialize(credentials)
      @credentials = credentials
      @logger = Logger.new(STDOUT)
    
      ShopifyAPI::Base.site = "https://" + 
        credentials['api_key'] + ':' + 
        credentials['password'] + '@' + 
        credentials['url'] + '/admin' 
      logger.debug("set shopify site to #{ShopifyAPI::Base.site}")
    end
  
    def template
      @template ||= Template.new(self)
    end
  
  end
end
