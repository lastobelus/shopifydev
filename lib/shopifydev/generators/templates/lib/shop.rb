equire "shopify_api"
require "pp"
require "inifile"
gem "shopify-api-limits"

class Shop
  
  def initialize
    ShopifyAPI::Base.site = "https://#{credentials['api_key']}:#{credentials['password']}@#{credentials['store']}/admin"
  end
  
  def credentials
    unless @credentials
      inifile = File.join(File.dirname(__FILE__), '..', '.shopify-tmbundle')
      ini = IniFile.new( File.read(inifile), :parameter => '=' )
      using = ini['global']['use']
      puts "using #{using}"
      @credentials = ini[using]
    end
    @credentials
  end
end

