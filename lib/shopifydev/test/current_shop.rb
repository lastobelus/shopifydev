module Shopifydev
  module Test
    class CurrentShop
      def with_shopify_session
        yield
      end
    end
  end
end