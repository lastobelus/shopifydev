require 'ffaker'
require 'shopify_api'
module Shopifydev
  module Faker
    extend ::Faker::ModuleUtils
    extend self


    def metafield(owner=nil, opts={})
      owner_resource = owner && owner.class.element_name 
      owner_id = owner && owner.id
      metafield = ::ShopifyAPI::Metafield.new(
      {
        owner_resource: owner_resource,
        owner_id: owner_id,
        namespace: opts[:namespace] || namespace,
        key: opts[:key] || key,
        value_type: 'string',
        value: opts[:value] || value
      }
      )
      metafield.save! if owner_id
      metafield
    end

    def namespace
      s = ''
      loop do
        word = ::Faker::Lorem.word[0..rand(10)].downcase
        word = '.' + word if s.length > 0
        if (s.length + word.length) < 21
          s += word 
        else
          break
        end
      end
      s
    end

    def key
      ::Faker::Lorem.word.downcase
    end

    def value
      ::Faker::Lorem.sentence(rand(10))
    end

  end
end
