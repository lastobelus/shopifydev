require 'shydra'

module Shopifydev
  module ShopifyAPI
    module ConsumeAPI
      class Report
        attr_accessor :level, :msg
        def initialize(hash)
          @level = hash.first.first
          @msg = hash.first.last
        end
      end
      def self.consume(num=nil)
        report = []
        num ||= 1
        num = num.to_i
        report << Report.new(info: "consuming api calls until only #{num} are left...")
        yield report.last if block_given?
        res = Shydra::Resources::Product.new.run
        pids = res.data.map{|r| r['id']}
        used, max = res.headers['HTTP_X_SHOPIFY_SHOP_API_CALL_LIMIT'].split('/').map(&:to_i)
        report << Report.new(debug: "used: #{used.inspect} max: #{max.inspect}")
        yield report.last if block_given?
        h = Shydra::Hydra.new(max_concurrency: 50)
        to_consume = max - used - num - 2
        report << Report.new(debug: "queueing to_consume: #{to_consume.inspect} requests")
        yield report.last if block_given?
        if to_consume > 0
          to_consume.times{ h.queue(Shydra::Resources::Product.new(id: pids.sample)) }
          h.run
          ::ShopifyAPI::Shop.current
        end
        report << Report.new(status: "credit_left: #{::ShopifyAPI.credit_left}")
        yield report.last if block_given?

        return report
      end
    end
  end
end