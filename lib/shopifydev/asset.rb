require 'shopify_api'
require 'filemagic'

module Shopifydev
  class Asset
    attr_accessor :shop, :remote_key

    def initialize(shop, path=ENV['TM_FILEPATH'], project_root)
      @shop = shop

      puts "path " + path.to_s
      puts "project_root " + project_root.to_s

      # Asset name should be relative to TM_PROJECT_DIRECTORY
      # but if it isn't, then gsub just doesn't replace anything
      # so if you know the key, you can just supply the key?
      unless project_root.nil?
        @remote_key = path.gsub(project_root + '/', '') # fix absolute path
        @local_path = Pathname.new(project_root + '/' + @remote_key) # prepend project root
      else
        raise Exception, "could no determine project_root. In .shopifydev.yaml include\n  project_root: relative/path"
      end
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
      if asset.valid?
        asset.save
        puts "Success!"
      else
        puts "Failure! Terrible failure!"
      end
    end
  end
end
