require 'rails/railtie'
require 'shopifydev'
module Shopifydev
  class Railtie < Rails::Railtie
    railtie_name :shopifydev

    rake_tasks do
      load "rails/tasks/shops.rake"
    end
  end
end
