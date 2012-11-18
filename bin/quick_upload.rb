require_relative "lib/shopifydev.rb"
require "shopify_api"

class QuickUpload
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
  test_shop = QuickUpload.new

  # upload a new asset by file name
  puts ARGV[0]
  test_shop.devshop.asset(ARGV[0]).upload
end

