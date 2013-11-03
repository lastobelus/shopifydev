require "logger"
require "shopify_api"

module Shopifydev
  class Shop
    attr_accessor :credentials, :logger, :project_root

    def initialize(credentials)
      @credentials = credentials
      @logger = Logger.new(STDOUT)

      ShopifyAPI::Base.clear_session
      if credentials['token']
        session = ShopifyAPI::Session.new(credentials['url'], credentials['token'])
        session.valid?  # returns true
        ShopifyAPI::Base.activate_session(session)
      else
        ShopifyAPI::Base.site = "https://" + 
          credentials['api_key'] + ':' + 
          credentials['password'] + '@' + 
          credentials['url'] + '/admin' 
        logger.debug("set shopify site to #{ShopifyAPI::Base.site}")
      end
    end

    def project_root
      @project_root ||= ENV['PATCHIFY_ROOT'] || begin
                          if credentials['project_root_variable']
                              ENV[credentials['project_root_variable']] || credentials['project_root']
                          else
                            credentials['project_root']
                          end
                        end
    end

    def template
      @template ||= Template.new(self, project_root)
    end

    def asset(path)
      Asset.new(self, path, project_root)
    end

  end
end
