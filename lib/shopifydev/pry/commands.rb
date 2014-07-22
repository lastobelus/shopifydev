# encoding: UTF-8
require 'oj'
require 'shopifydev/test'

class Switch
  def initialize
    @current_shop = ''
    reset!
  end

  def current_shop
    @current_shop = ShopifyAPI::Base.site || 'none'
    TColor.green{ "current shop:"} + " #{@current_shop}"
  end

  def reset!
    @menu = default_menu
    @finished = false
  end

  def finished?
    @finished
  end

  def finish!
    @finished = true
  end

  def menu
    @menu
  end

  def pick(ix)
    result = ''

    # TODO we need need need to rename cfg, as it is currently confusing
    @breadcrumbs, @cfg = pick_config(ix)

    if @breadcrumbs == :no_such_config
      result << TColor.red{ "I don't know about #{ix}\n" }
      result << self.menu.print
    else
      # update the menu based on the choice
      # if we've reached a terminal menu, then do something
      # otherwise just present the next menu
      result << handle_choice
    end
  end

  private

  def set_shop(key, password, domain)
    @current_shop = domain
    ShopifyAPI::Base.site = "https://#{key}:#{password}@#{domain}/admin/"
    @current_shop
  end

  def pick_config(ix)
    # this gives us the menu item
    path = self.menu.pick(ix)
    return :no_such_config if path.nil?
    result = shopify_config

    path.each do |x|
      result = result[x]
    end

    [path, result]
  end

  # if we chose a test shop cfg is a hash of key, password, and domain
  # if we chose a local shop, it is a path
  # path is the path through the yaml file
  def handle_choice
    result = ''

    case @cfg
    when String then
      case @breadcrumbs[1].to_sym
      when :development then menu_method = self.method(:development_menu)
      when :heroku      then menu_method = self.method(:heroku_menu)
      else                   menu_method = self.method(:missing_menu)
      end
    when Hash
      result = handle_by_shop_type
      finish!
    else
      raise "don't know what to do with @cfg: #{@cfg.inspect}"
    end

    if menu_method
      result << "you picked #{@breadcrumbs.join('.')}\n"
      result << @cfg.inspect + "\n"
      result << TColor.yellow { menu_method.call.print }
    end
    result
  end

  def handle_by_shop_type
    if @cfg.keys.include?("shop_type")
      case @cfg["shop_type"].to_sym
      when :local
        ShopifyAPI::Base.clear_session
        session = ShopifyAPI::Session.new(@cfg['url'], @cfg['token'])
        session.valid?  # returns true
        ShopifyAPI::Base.activate_session(session)
      when :heroku
        puts TColor.red{ "can't handle heroku yet"}
      end
    else
      ShopifyAPI::Base.clear_session
      set_shop(@cfg[:api_key], @cfg[:password], @cfg[:myshopify_domain])
    end
    self.current_shop
  end

  def default_menu
    @menu = ConfigMenu.new(Shopifydev::Config.config, :default).build
  end

  # TODO this needs to be renamed:
  #   It is the contents of .shopifydev.yaml, but it is also
  #   more than that, since it gets updated throughout the life
  #   of a switch object.
  def shopify_config
    @shopify_config ||= Shopifydev::Config.config
  end

  # TODO this method is pretty obscure
  def development_menu
    # this needs to be memoized
    @apps ||= {}
    @apps[@cfg] ||= LocalShopifyApp.new(@cfg)
    shops = @apps[@cfg].shops

    # add the shop_type to the array of shops
    shops.each do |shop|
      shop["shop_type"] = "local"
    end

    key = ''
    domain = @cfg # at this point we know @cfg is a path on the local machine

    # iterate over shopifydev.yaml and replace the local file path matching
    # domain with the list of shops associated with that domain
    # TODO drop M's terrible habbit of using k and v for key and value

    # TODO: use detect
    shopify_config["apps"]["development"].each do |k, v|
      if v == domain
        shopify_config["apps"]["development"][k] = shops
        key = k
        break
      end
    end

    # the menu relevant yaml needs to be [key, array]
    @menu = ConfigMenu.new([key, shopify_config["apps"]["development"][key]], :development).build
  end

  def heroku_menu
    app = HerokuShopifyApp.new(@cfg)
    shops = app.shops
    @menu = ConfigMenu.new(shops, :heroku).build
  end

  def missing_menu
    @menu = ConfigMenu.new(shops, :missing).build
  end
end

class Pry
  attr_accessor :switch

  def switch
    @switch ||= Switch.new
  end
end

# these mini classes JUST grabs the JSON that we need for making submenus
class ShopifyAppShopList
  attr_accessor :path

  def initialize(path)
    @path = path
  end

  def shops
    raise "you must define the shops method"
  end
end

class HerokuShopifyApp < ShopifyAppShopList
end

class LocalShopifyApp < ShopifyAppShopList
  def refresh!
    @data = nil
  end

  def url_column
    data['url_column']
  end

  def shops
    data['shops']
  end

  def data
    @data ||= begin
      data = {}
      if Pathname(path).expand_path == Pathname.getwd
        url_column = 'myshopify_domain'
        url_column = 'domain' unless ::Shop.column_names.include?(url_column)
        url_column = 'url' unless ::Shop.column_names.include?(url_column)
        data = {
          'shops' => ::Shop.select("id,#{url_column},token").all.map(&:attributes),
          'url_column' => url_column
        }
      else
        json = `/bin/bash -l -c "unset BUNDLE_GEMFILE; cd #{path} 2> /dev/null; bundle exec rake shops 2>/dev/null"`
        json = json.split("----snip----\n").last
        json = json.split("\n").last
        data = Oj.load(json)
        # TODO: this should go away when we refactor into objects, since the app object will know what it's url_column is and be responsible for shop data
      end
      unless data['url_column'] == 'url'
        data['shops'].each{|shop| shop['url'] = shop[data['url_column']]}
      end
      data
    end
  end
end

class ConfigMenu
  attr_accessor :json

  def initialize(json, style=:default)
    @json = json
    @style = style
    @choices = [:do_nothing]
    @lines = []
  end

  def build
    case @style
    when :development then build_development
    when :default then build_default
    when :heroku then build_heroku
    else build_missing
    end
  end

  def print(output=nil)
    if output.nil?
      @lines.join("\n")
    else
      output.puts @lines.join("\n")
    end
  end

  def pick(ix)
    if ix >= @choices.length
      nil
    else
      @choices[ix]
    end
  end

  private

  # instead of having infinite build_something methods, maybe we should have
  # a way of passing in blocks, or something?
  def build_default
    header("Test Shops")
    json[:test_shops].keys.each do |k|
      choice([:test_shops, k], k)
    end

    header("Local Apps")
    json[:apps][:development].each do |k, path|
      if Pathname(path).expand_path == Pathname.getwd
        path = TColor.green{ path }
      end
      choice([:apps, :development, k], path)
    end

    header("Heroku Apps")
    json[:apps][:heroku].each do |k, name|
      choice([:apps, :heroku, k], name)
    end

    self
  end

  def build_development
    header("Development Shops")

    name = json.first
    json.last.each_with_index do |h, index|
      choice([:apps, :development, name, index], h["url"])
    end

    self
  end

  def build_missing
    warn("AND I DON'T EVEN KNOW!")
    self
  end

  # TODO I think these three related methods could be moved into a module called "Writer" or something
  def header(label)
    @lines << ''
    @lines << TColor.blue { label }
  end

  def warn(label)
    @lines << ''
    @lines << TColor.red { label }
  end

  def choice(path, value)
    ix = @choices.length
    @lines << TColor.yellow{ ix.to_s } + '. ' + value.to_s
    @choices[ix] = path
  end
end

shopifydev_command_set = Pry::CommandSet.new do
  create_command "switch" do
    description "switch shops"

    # opt is a Slop object, see https://github.com/injekt/slop/blob/master/README.md
    def options(opt)
    end

    def process
      output.puts _pry_.switch.current_shop

      case true
      when args.empty?
        _pry_.switch.reset! # reset to the first menu page
        result = ''
        until _pry_.switch.finished?
          output.puts _pry_.switch.menu.print
          print "❔  " + TColor.yellow
          choice = $stdin.gets
          print TColor.clear
          if choice.blank?
            _pry_.switch.reset!
          else
            result = _pry_.switch.pick(choice.chomp.to_i)
          end
        end
        puts result
        _pry_.switch.reset!
      when (args.length == 1)
        _pry_.switch.reset! # reset to the first menu page
        ix = args.first.to_i
        output.puts _pry_.switch.pick(ix)
      end
    end
  end

  create_command "arlog", "Turn ActiveResource logging on/off" do
    def process
      case  args.first
      when 'off'
        puts TColor.black{"ActiveResource logging "} + TColor.red{'off'}
        ActiveResource::Base.logger = nil
      else      
        puts TColor.black{"ActiveResource logging "} + TColor.yellow{'on'}
        ActiveResource::Base.logger = Logger.new STDOUT
      end
    end
  end

  block_command "tree", "display directory using unix 'tree'" do |path|
   UnixTree.print_tree(path) # moved to module so can use in save_json & load_json
  end

  block_command "consume_api", "use up Shopify API calls until only [x] remain (default 0)" do |num|
    require "shopifydev/shopify_api/consume_api"
    report = Shopifydev::ShopifyAPI::ConsumeAPI.consume(num) do |report_line|
      case report_line.level
      when :info
        puts TColor.yellow{ report_line.msg }
      when :status
        puts TColor.blue{ report_line.msg}
      else
        puts report_line.msg
      end
    end
  end

end

Pry::Commands.import shopifydev_command_set
