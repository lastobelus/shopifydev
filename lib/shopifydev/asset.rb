require 'shopify_api'
require 'filemagic'

module Shopifydev
  class Asset
    attr_accessor :shop, :remote_key

    def initialize(shop, path=ENV['TM_FILEPATH'])
      @shop = shop

      # Asset name should be relative to TM_PROJECT_DIRECTORY
      # but if it isn't, then gsub just doesn't replace anything
      # so if you know the key, you can just supply the key?
      @remote_key = path.gsub(ENV['TM_PROJECT_DIRECTORY'] + '/', '')
      @local_path = Pathname.new(ENV['TM_PROJECT_DIRECTORY'] + '/' + @remote_key)
    end

    def upload(root=nil)
      # check that it's not binary 

      asset = ShopifyAPI::Asset.create(:key => @remote_key)
      contents = File.read(@local_path.to_path)
      fm = FileMagic.new

      if (fm.file(@local_path.realpath.to_path).include?('image'))
        asset.attach contents
      else
        asset.value = contents
      end

      # TODO this doesn't fail spectacularly enough... I don't 
      # feel comfortable with that
      asset.save if asset.valid?
    end
  end
end
