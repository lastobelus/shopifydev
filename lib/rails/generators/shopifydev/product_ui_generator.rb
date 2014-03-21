require 'rails/generators/base'

module Shopifydev
  class ProductUiGenerator < Rails::Generators::Base
    desc "Creates a UI for editing product list (via ProductCache). Provides partials for adding custom fields."
    source_root File.expand_path('../templates', __FILE__)

    def generate_views
      template "views/product_caches/_app_fields_header.html.slim", "app/views/product_caches/_app_fields_header.html.slim"
      template "views/product_caches/_app_fields.html.slim", "app/views/product_caches/_app_fields.html.slim"
      template "views/product_caches/index.html.slim", "app/views/product_caches/index.html.slim"
    end
    
    def generate_controller
      template "controllers/product_caches_controller.rb", "app/controllers/product_caches_controller.rb"
    end
    
    def add_inline_error_helper
      template "helpers/inline_error_helper.rb", "app/helpers/inline_error_helper.rb" 
    end
    
    def routes
      route %Q{
  resources :product_caches, only: [:index] do
    collection do
      get 'page/:page', action: :index
      put 'update_multiple'
    end
  end
}
    end
  end
end
