require 'pathname'
require 'fileutils'

module Shopifydev
  class Template
    
    attr_accessor :shop
    
    def initialize(shop)
      @shop = shop
    end
    
    def download(root=nil)
      root ||= FileUtils.pwd
      shop.logger.info("Downloading all pages from #{shop.credentials['url']}")

      # TODO error handling goes here
      response = ShopifyAPI::Asset.find(:all) # get all them assets

      asset_files = get_list_of_assets(response)

      asset_files.each do | file | 
        file_info = file[:file_info]

        folder_path = Pathname.new(tm_project_directory + directory_separator + file_info.dirname.to_path).realdirpath
        puts folder_path.join(file_info.basename).to_path

        unless (folder_path.exist?)
          FileUtils.mkpath(folder_path.to_path)

        end

        # TODO error handling puleez
        asset = get_asset(file[:file_path])

        File.open((folder_path + file_info.basename).to_path, 'w') do |f| 
          # f.write(asset.value)
        end

      end

    end

    def tm_project_directory
      "/home/zeigfreid/github/shopifydev/tm_project"
    end

    def directory_separator
      "/"
    end

    def get_list_of_assets(response)
      asset_files = []

      response.reverse.each do | asset_info |
        pathname = Pathname.new(asset_info.attributes["key"])
        path_string = pathname.to_path

        if ".css" == pathname.extname
          puts "yeah"
          puts path_string + '.liquid' 
          puts asset_files.include?(path_string + '.liquid')
          if asset_files.include?(path_string + '.liquid')

            next

          end
        end

        puts path_string
        asset_files << { :file_path => path_string, :file_info => pathname }
        gets
      end

      return asset_files
    end

    def get_asset(key)
      ShopifyAPI::Asset.find(key)
    end

  end
end


=begin

<ShopifyAPI::Asset:0x00000002b1f128 
  @attributes={ 
    "key"=>"assets/ajaxify-shop.js", 
    "public_url"=>"http://static.shopify.com/s/files/1/0173/2198/t/3/assets/ajaxify-shop.js?0", 
    "created_at"=>"2012-08-04T18:01:53-04:00", 
    "updated_at"=>"2012-08-04T18:01:53-04:00", 
    "content_type"=>"application/javascript", 
    "size"=>7738
  }, 
  @prefix_options={}, 
  @persisted=true>

=end

