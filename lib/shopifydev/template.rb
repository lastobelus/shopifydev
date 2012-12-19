require 'pathname'
require 'fileutils'

module Shopifydev
  class Template

    attr_accessor :shop, :project_root

    def initialize(shop, project_root)
      @shop = shop
      @project_root = project_root
    end

    def download(root=nil)
      root ||= FileUtils.pwd
      shop.logger.info("Downloading all pages from #{shop.credentials['url']}")

      begin
        response = ShopifyAPI::Asset.find(:all) # get all them assets
        get_list_of_assets(response).each {| key, file | write_local_copy(file) }
      rescue SocketError => e
        puts e.message
        puts "Maybe check your internet connection?"
      rescue NoMethodError => e
        puts e.message
      rescue ActiveResource::UnauthorizedAccess => e
        puts e.message
        puts "Make sure you have the right password set in .shopifydev.yaml"
      rescue Exception => e
        puts e.message
      end
    end

    def write_local_copy(file)

      directory_path = Pathname.new(@project_root +
                                 File::Separator +
                                 file.dirname.to_path)

      directory_path.mkpath unless (directory_path.exist?)

      begin
        puts "downloading #{file.basename}"
        asset = get_asset(file.to_path)
      rescue SocketError => e
        puts e.message
        puts "The connection was interupted while downloading #{file.to_path}."
      end

      # TODO maybe this should compare timestamps?
      File.open((directory_path.realdirpath + file.basename).to_path, 'w') do |f|
        puts "writing #{directory_path.to_path + File::Separator +  file.basename.to_path}"
        f.write(asset.value)
        puts "---"
      end
    end

    def get_list_of_assets(response)
      response.reverse.inject({}) do | list, asset_info | 
        pathname = Pathname.new(asset_info.attributes["key"])
      path = pathname.to_path

      list[path] = pathname unless list.keys.include?(path + '.liquid')
      list
      end
    end

    def get_asset(key)
      ShopifyAPI::Asset.find(key)
    end

  end
end
