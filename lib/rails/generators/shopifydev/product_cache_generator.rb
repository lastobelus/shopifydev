require 'rails/generators/base'

module Shopifydev
  class ProductCacheGenerator < Rails::Generators::Base
    desc "Creates a ProductCache model and a sidekiq worker to populate it."
    source_root File.expand_path('../templates', __FILE__)

    def generate_product_cache
      generate 'migration ProductCache shop:references shopify_product_id:integer shopify_title:string shopify_handle:string shopify_product_type:string shopify_vendor:string shopify_updated_at:datetime'
    end
    
    def generate_worker
      template "sidekiq_status_initializer.rb", 'config/initializers/sidekiq_status_initializer.rb'
      template "product_cache_updater.rb", "app/workers/product_cache_updater.rb"
    end
  end
end
