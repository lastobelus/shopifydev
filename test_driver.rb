require_relative "lib/shopifydev.rb"
require "shopify_api"

class TestDriver
  attr_accessor :devshop

  def initialize
    @devshop = Shopifydev::Shop.new(credentials)
  end

  def credentials
    unless @credentials
      @credentials = YAML::load(
        File.open(
          File.join(File.dirname(__FILE__), '.shopifydev.yaml')))
    end

    @credentials
  end

end

if __FILE__ == $PROGRAM_NAME
  test_shop = TestDriver.new
  test_shop.devshop.template.download

  # upload a new asset by file name
  test_shop.devshop.asset('assets/example.css').upload
  test_shop.devshop.asset('assets/example.png').upload
end

