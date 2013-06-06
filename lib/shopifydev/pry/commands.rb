require 'term/ansicolor'
require 'oj'
class Color
  if Pry.config.color
    extend Term::ANSIColor
  else
    class << self
      def method_missing
        ''
      end
    end
  end
end

class LocalShopifyApp
  attr_accessor :path
  def initialize(path)
    @path = path
  end

  def shops
    json = `/bin/bash -l -c "unset BUNDLE_GEMFILE; cd #{path}; bundle exec rake shops 2>/dev/null"`
    json = json.split("----snip----\n").last
    Oj.load json
  end

end

class ConfigMenu

  attr_accessor :cfg

  def initialize(cfg)
    @cfg = cfg
    @menu_choices = [:do_nothing]
    @menu_display = []
  end
  def build
    header("Test Shops")
    cfg[:test_shops].keys.each do |k|
      choice([:test_shops, k], k)
    end
    
    header("Local Apps")
    cfg[:apps][:development].each do |k, path|
      choice([:apps, :development, k], path)
    end

    header("Heroku Apps")
    cfg[:apps][:heroku].each do |k, name|
      choice([:apps, :heroku, k], name)
    end

    self
  end

  def print(output)
    output.puts @menu_display.join("\n")
  end

  def header(label)
    @menu_display << ''
    @menu_display << Color.blue { label }
  end

  def choice(path, value)
    ix = @menu_choices.length
    @menu_display << Color.yellow{ ix.to_s } + '. ' + value.to_s
    @menu_choices[ix] = path
  end

  def pick(ix)
    if ix >= @menu_choices.length
      nil
    else
      @menu_choices[ix]
    end
  end

  def pick_config(ix)
    path = pick(ix)
    return :no_such_config if path.nil?
    result = cfg
    path.each do |x|
      result = result[x]
    end

    [path, result]
  end
end

shopifydev_command_set = Pry::CommandSet.new do
  create_command "switch" do
    description "switch shops"


    # opt is a Slop object, see https://github.com/injekt/slop/blob/master/README.md
    def options(opt)
    end

    def process
      print_current_shop

      config_menu = ConfigMenu.new(Shopifydev::Config.config).build

      

      case true
      when args.empty?
        config_menu.print(output)
      when (args.length == 1)
        ix = args.first.to_i
        path, cfg = config_menu.pick_config(ix)
        if path == :no_such_config
          output.puts Color.red{ "I don't know about #{ix}" }
          config_menu.print(output)
        else
          handle_choice(path, cfg)
        end
      end
    end

    def print_current_shop
      current_shop = ShopifyAPI::Base.site || 'none'
      output.puts Color.green{ "current shop:"} + " #{current_shop}"
    end

    def handle_choice(path, cfg)
      case path.first.to_sym
      when :test_shops
        url = "https://#{cfg[:api_key]}:#{cfg[:password]}@#{cfg[:myshopify_domain]}/admin/"
        ShopifyAPI::Base.site = url
        print_current_shop
      when :apps
        case path[1].to_sym
        when :development
          output.puts "you picked #{path.join('.')}"
          output.puts cfg.inspect
          app = LocalShopifyApp.new(cfg)
          output.puts Color.yellow{ app.shops.inspect }          
        when :heroku
          output.puts "you picked #{path.join('.')}"
          output.puts cfg.inspect

          output.puts Color.yellow{ "but it's not ready yet!"}          
        else
          output.puts "you picked #{path.join('.')}"
          output.puts cfg.inspect
          output.puts Color.red{ "AND I DON'T EVEN KNOW!"}          
        end
      else
        output.puts "you picked #{path.join('.')}"
        output.puts cfg.inspect
        output.puts Color.red{ "AND I DON'T EVEN KNOW!"}          
      end
    end


    def output_menu_choices(arr, ix=1)
      my_ix = 0
      arr.each do |item|
        output.puts menu_choice(ix+my_ix, item.to_s)
        my_ix +=1
      end
      my_ix
    end

    def menu_choice(ix, s)
      Color.yellow{ ix.to_s } + '. ' + s.to_s
    end

    def menu_header(s)
      Color.blue { s }
    end

    def write_menu(cfg) 
      ix = 1
      # output.puts "Test Shops"
      output.puts menu_header("Test Shops")
      ix += output_menu_choices(cfg[:test_shops].keys.sort, ix)

      output.puts
      output.puts menu_header("Local Apps")
      ix += output_menu_choices(cfg[:apps][:development].keys.sort, ix)

      output.puts
      output.puts menu_header("Heroku Apps")
      ix += output_menu_choices(cfg[:apps][:heroku].keys.sort, ix)
    end
  end

end

Pry::Commands.import shopifydev_command_set
