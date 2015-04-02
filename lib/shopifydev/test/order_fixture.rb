require 'ffaker'
module Shopifydev
  module Test
    class OrderFixture

      attr_accessor :shop, :address_defaults, :order_defaults
  
      # Create a test fixture given a shop object
      def initialize(shop=nil)
        @shop = shop
        @shop ||= CurrentShop.new
        @address_defaults = {}
        @order_defaults = {}
      end
  

      def set_test_defaults!
        @address_defaults = {
          first_name: "Webify",
          last_name: "Test"
        }
        @order_defaults = {
          email: "test@webifytechnology.com"
        }
      end
    
      def products
        @products ||= shop.with_shopify_session do
          ::ShopifyAPI::Product.find(:all, params: {limit: false})
        end
      end
    
      def variants
        @variants ||= products.map(&:variants).flatten
      end
    
      def line_item_attrs(opts={})
        product = nil
        variant = nil
        if opts[:product_id]
          product = products.find{|prod| prod.id.to_s == opts[:product_id].to_s}
          raise "don't know about a product with id #{opts[:product_id]}" if product.nil?
        end

        if opts[:variant_id]
          variant = variants.find{|v| v.id.to_s == opts[:variant_id].to_s}
          variant ||= product.variants.sample if product
          raise "don't know about a variant with id #{opts[:variant_id]}" if variant.nil?
        end
        variant ||= products.sample.variants.sample

        q = opts[:quantity]
        q ||= (rand() > 0.3) ? 1 : (rand(3) + 1)
        {
          price: variant.price,
          quantity: q,
          variant_id: variant.id
        }
      end

      def line_items_attrs(opts={})
        num = opts.delete(:num_line_items)
        if line_item_opts = opts.delete(:line_items)
          num = line_item_opts.length
        end
      
        num ||= (rand() > 0.4) ? 1 : (rand(2) + 2)
        line_item_opts ||= []
        while line_item_opts.length < num
          line_item_opts << {}
        end
        out = []
        num.times { |i| out << line_item_attrs(line_item_opts[i]) }
        out
      end

      def us_address_attrs(opts={})
        require_relative 'valid_zip'
        place = ValidZip.valid_place
        first_name = ::FFaker::Name.first_name
        last_name  = ::FFaker::Name.last_name
        attrs = {
          first_name:   first_name,
          last_name:    last_name,
          address1:     ::FFaker::AddressUS.street_address,
          phone:        ::FFaker::PhoneNumber.phone_number,
          city:         place[:city],
          province:     place[:state],
          country:      "US",
          zip:          place[:zip]
        }.deep_merge(@address_defaults).deep_merge(opts)
        attrs[:name] = [attrs[:first_name], attrs[:last_name]].join(' ')
        attrs
      end

      def cad_address_attrs(opts={})
        require_relative 'valid_postal_code'
        place = ValidPostalCode.valid_place
        first_name = ::FFaker::Name.first_name
        last_name  = ::FFaker::Name.last_name
        attrs = {
          first_name:   first_name,
          last_name:    last_name,
          address1:     ::FFaker::AddressCA.street_address,
          phone:        ::FFaker::PhoneNumber.phone_number,
          city:         place[:city],
          province:     place[:province],
          country:      "CA",
          zip:          place[:postal_code]
        }.deep_merge(@address_defaults).deep_merge(opts)
        attrs[:name] = [attrs[:first_name], attrs[:last_name]].join(' ')
        attrs
      end

      def address_attrs(opts=nil)
        case opts
        when 'cad', 'CAD', 'ca', 'CA', :cad
          cad_address_opts(opts)
        when 'us', 'US', :us
          cad_address_opts(opts)
        when Hash
          country = opts[:country]
          case country.downcase
          when 'ca', 'cad', 'canada'
            cad_address_attrs(opts)
          when 'us', 'united states'
            us_address_attrs(opts)
          else
            [cad_address_attrs(opts), us_address_attrs(opts)].sample
          end
        else
          [cad_address_attrs, us_address_attrs].sample
        end
      end
      
      def order_attrs(opts={})
        address = opts.delete(:address)
        address = address_attrs(address) if address
        billing_address = opts.delete(:billing_address)
        billing_address = address_attrs(billing_address) if billing_address
        billing_address ||= address
        billing_address ||= address_attrs
        
        shipping_address = opts.delete(:shipping_address)
        shipping_address = address_attrs(shipping_address) if shipping_address
        shipping_address ||= address
        shipping_address ||= address_attrs

        opts.delete(:address)
        {
          line_items: line_items_attrs(opts),
          billing_address: billing_address,
          shipping_address: shipping_address,
          financial_status: 'paid',
          email: ::FFaker::Internet.email
        }.deep_merge(@order_defaults).deep_merge(opts)
      end

      def orders
        @orders ||= shop.with_shopify_session do
          ::ShopifyAPI::Order.find(:all, params: {limit: false})
        end
      end
    
      def new_order(opts={})
        period = opts.delete(:in_period)
        case period
        when Range
          opts[:created_at] = period.first + rand(period.last - period.first)
        when Hash
          opts[:created_at] = period[:created_at_min]
          opts[:created_at] += rand(period[:created_at_max] - period[:created_at_min]) if period[:created_at_max].present?
        when Time, Date
          opts[:created_at] = period
        end
        opts[:fulfillment_status] = "fulfilled" if opts.delete(:fulfilled)
        opts = order_attrs(opts)
        order = nil
        shop.with_shopify_session do
          # still have to be in a session even if not saving, because of utter lameness
          order = ::ShopifyAPI::Order.new(opts)
        end
        order
      end

      def create_order!(opts={})
        order = new_order(opts)
        shop.with_shopify_session do
          # still have to be in a session even if not saving, because of utter lameness
          saved = order.save
          raise order.errors.full_messages.join("\n") unless saved
        end
        order
      end
      
      def create_orders!(opts={})
        num = opts.delete(:num) || 1
        orders = []
        num.times do
          order = create_order!(opts)
          orders << order
          opts[:created_at] = Time.parse(order.created_at) + rand(60) + 10 if opts[:created_at].present?
        end
        orders
      end

      def fulfill(orders)
        orders = [orders].flatten
        orders.each do |order|
          order_id = nil
          if order.is_a?(::ShopifyAPI::Order)
            next if order.fulfillment_status == "fulfilled"
            order_id = order.id
          else
            order_id = order.to_i
          end
          ::ShopifyAPI::Fulfillment.create({
            tracking_number: nil,
            order_id: order_id
          })
        end
      end

    end
  end
end