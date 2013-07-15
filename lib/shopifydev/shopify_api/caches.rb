module Shopifydev
  module ShopifyAPI
    module DirtyCache
      def site=(uri)
        ::ShopifyAPI.dirty!
        super uri
      end
    end
  end
end

module ShopifyAPI
  class Base
    puts "include Shopifydev::ShopifyAPI::DirtyCache"
    extend Shopifydev::ShopifyAPI::DirtyCache
  end
end

module ShopifyAPI
  class << self

    def cache_status(cache, show_opts=false)
      dirty?
      subset = ''
      opts = ''
      length = Color.black{'unloaded'}
      since = ''
      unless cache.nil?
        if !show_opts && (cache.params.keys.to_set != Set[:limit])
          subset = Color.red('!')
        end
        if show_opts
          opts = cache.params.map{|k, v| Color.magenta{k.to_s} + Color.black{':'} + Color.green{v.to_s}}.join(Color.black{', '})
          opts = "\n  #{opts}"
        end
        length = (cache.length > 0) ? "#{cache.length.to_s}#{subset} #{Color.black{cache.label}}" : 'empty'
        since = "#{Color.black{'on:'}}#{cache.since.strftime("%a %H:%M:%S")}"
      end
      "#{length.ljust(18)} #{since}#{opts}"
    end

    def caches(show_opts=false)
      return if warn_site
      dirty?
      puts <<-EOF
#{Color.blue{'products'}}:           #{cache_status(@@products, show_opts)}
#{Color.blue{'variants'}}:           #{cache_status(@@variants, show_opts)}
#{Color.blue{'metafields'}}:         #{cache_status(@@metafields, show_opts)}
#{Color.blue{'orders'}}:             #{cache_status(@@orders, show_opts)}
#{Color.blue{'customers'}}:          #{cache_status(@@customers, show_opts)}
#{Color.blue{'custom_collections'}}: #{cache_status(@@custom_collections, show_opts)}
#{Color.blue{'smart_collections'}}:  #{cache_status(@@smart_collections, show_opts)}
EOF
    end

    def dirty?
      @@products ||= nil
      @@variants ||= nil
      @@metafields ||= nil
      @@orders ||= nil
      @@customers ||= nil
      @@custom_collections ||= nil
      @@smart_collections ||= nil
    end

    def dirty!
      @@products = nil
      @@variants = nil
      @@metafields = nil
      @@orders = nil
      @@customers = nil
      @@custom_collections = nil
      @@smart_collections = nil
    end

    def add_cache_methods(obj, opts, entity)
      obj.singleton_class.class_eval{define_method(:label){entity.collection_name}}
      obj.singleton_class.class_eval{define_method(:since=){|t| @since = t }}
      obj.singleton_class.class_eval{define_method(:since){ @since }}
      obj.singleton_class.class_eval{attr_accessor :params}
      obj.since = Time.now
      obj.singleton_class.class_eval{define_method(:r) { |msg = 'reloading'| 
        puts "#{msg}..."
        self.replace(entity.find(:all, params: self.params))
        self.since = Time.now
        puts "#{self.length} records."
        nil
      }}
    end

    def warn_site
      if ::ShopifyAPI::Base.site.nil? || ::ShopifyAPI::Base.site.blank?
        puts "No active Shopify session"
        true
      else
        false
      end
    end

    def fetch_cache(entity, opts, obj)
      msg = nil
      refresh = opts.delete(:r)
      if obj.nil? || refresh
        obj = []
        add_cache_methods(obj, opts, entity)
        obj.params = opts
        msg = refresh ? "reloading #{entity.collection_name}" : "loading #{entity.collection_name}"
        obj.r(msg)
      elsif (obj.params != opts)
        msg = "reloading #{entity.collection_name} with new params..."
        obj.params = opts
        obj.r(msg)
      end
      obj
    end

    def products(opts={limit: 250})
      return if warn_site
      @@products ||= nil
      @@products = fetch_cache(ShopifyAPI::Product, opts, @@products)
      @@products
    end

    def variants(opts={limit: 250})
      return if warn_site
      @@variants ||= nil
      @@variants = fetch_cache(ShopifyAPI::Variant, opts, @@variants)
      @@variants

    end

    def orders(opts={limit: 250})
      return if warn_site
      @@orders ||= nil
      @@orders = fetch_cache(ShopifyAPI::Order, opts, @@orders)
      @@orders
    end

    def customers(opts={limit: 250})
      return if warn_site
      @@customers ||= nil
      @@customers = fetch_cache(ShopifyAPI::Customer, opts, @@customers)
      @@customers
    end

    def metafields(opts={limit: 250})
      return if warn_site
      @@metafields ||= nil
      @@metafields = fetch_cache(ShopifyAPI::Metafield, opts, @@metafields)
      @@metafields
    end

    def custom_collections(opts={limit: 250})
      return if warn_site
      @@custom_collections ||= nil
      @@custom_collections = fetch_cache(ShopifyAPI::CustomCollection, opts, @@custom_collections)
      @@custom_collections
    end

    def smart_collections(opts={limit: 250})
      return if warn_site
      @@smart_collections ||= nil
      @@smart_collections = fetch_cache(ShopifyAPI::SmartCollection, opts, @@smart_collections)
      @@smart_collections
    end




  end
end