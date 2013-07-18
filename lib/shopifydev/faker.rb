require 'ffaker'
require 'shopify_api'
module Shopifydev
  module Faker
    extend ::Faker::ModuleUtils
    extend self

    NL = "\n"


    def metafield(owner=nil, opts={})
      owner_resource = owner && owner.class.element_name 
      owner_id = owner && owner.id
      metafield = ::ShopifyAPI::Metafield.new(
      {
        namespace: opts[:namespace] || namespace,
        key: opts[:key] || key,
        value_type: 'string',
        value: opts[:value] || value
      }
      )
      unless owner.is_a?(::ShopifyAPI::Shop)
        metafield.owner_resource = owner_resource
        metafield.owner_id = owner_id
      end

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
      k = ""
      while((k = ::Faker::Lorem.word).length < 3);end
      k.downcase
    end

    def value
      ::Faker::Lorem.sentence(rand(10) + 1)
    end

    def csv_value
      value.gsub('"','').gsub(',', '')[0..-2]
    end

    def metafield_import_csv(resources, opts={})
      opts[:import_type] ||= :product_variant_sku
      opts[:num] ||= 1
      opts[:namespace] ||= namespace

      out = ""

      case opts[:import_type]
      when :owner_resource
      when :product_handle
      when :product_variant_sku
      when :product_variant_multikey
        out = %w{sku namespace} 
        out += opts[:keys]
        out = out.join(',')
        out << NL

        resources.each do |resource|
          line = [resource.sku, opts[:namespace]]
          values = opts[:values]
          values ||= [csv_value]
          values = [values].flatten
          while(values.length < opts[:num]); values << csv_value; end
          line += values
          out << line.join(',')
          out << NL
        end
      else
        raise "don't know how to create import csv for #{opts[:type].to_s}"
      end

      out
    end
  end
end
