module Shopifydev
  class Template
    
    attr_accessor :shop
    
    def initialize(shop)
      @shop = shop
    end
    
    def download(root=nil)
      root ||= Dir.pwd      
      logger.info("Downloading all pages from #{shop.credentials['url']}")
    end
  end  
end
