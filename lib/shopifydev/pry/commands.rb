shopifydev_command_set = Pry::CommandSet.new do
  create_command "switch" do
    description "switch shops"


    # opt is a Slop object, see https://github.com/injekt/slop/blob/master/README.md
    def options(opt)
    end

    def process
      output.puts "current shop: #{ShopifyAPI::Base.site}"
      output.print "whaddaya want? "
      s = output.gets
      output.puts
      output.puts "you said #{s}"
    end
  end

end

Pry::Commands.import shopifydev_command_set
