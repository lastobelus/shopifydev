class ProductCacheUpdater
  include Sidekiq::Worker
  include Sidekiq::Status::Worker
  
  def perform(shop_id, throttle=0)
    shop = ::Shop.find(shop_id)
    
    num = 0
    done = 0
    created_ids = []
    updated_ids = []
    loop do
      last_update = ProductCache.maximum(:shopify_updated_at)
      last_update ||= 10.years.ago
      products = []

      shop.with_shopify_session do
        products = ShopifyAPI::Product.find(:all,
          params: {limit: false, updated_at_min: last_update.to_s(:db)}
        )
      end
      
      break if products.length < 1
    
      num += products.length
      at done, num
      products.each_with_index do |product, ix|
        product_cache = nil
        begin
          product_cache = ProductCache.find_or_create_by(shopify_product_id: product.id) do |p|
            p.shop = shop
          end
          created_ids << product.id
        rescue ActiveRecord::RecordNotUnique
          retry
        end
        product_cache.shopify_title = product.title
        product_cache.shopify_handle = product.handle
        product_cache.shopify_product_type = product.product_type
        product_cache.shopify_vendor = product.vendor
        product_cache.shopify_updated_at = product.updated_at
        
        if product_cache.changed?
          updated_ids << product.id unless created_ids.include?(product.id)
          product_cache.save!
        end
        store created_ids: created_ids.join(',')
        store updated_ids: updated_ids.join(',')
        done += 1
        at done, num
        sleep throttle
      end
    end
    store created_ids: created_ids.join(',')
    store updated_ids: updated_ids.join(',')
  end
end