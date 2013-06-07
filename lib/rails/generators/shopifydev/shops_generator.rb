require 'rails/generators/base'

module Shopifydev
  class ShopsGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    def rake_task
      copy_file "shops.rake", "lib/tasks/shops.rake"
    end
  end
end
