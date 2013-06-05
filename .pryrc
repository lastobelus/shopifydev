dir = File.dirname(__FILE__)
$LOAD_PATH.unshift File.join(dir, 'lib')

load File.join(dir, 'lib', 'shop.rb')
require 'active_resource_handle_api_limit'
require 'dev'

require 'pathname'

module Work
  class << self
    def apps
      {
        test: Pathname.new(File.dirname(__FILE__)),
        mefi: Pathname.new(File.expand_path("~/clients/webify/metafieldeditor")),
        ship: Pathname.new(File.expand_path("~/clients/webify/shipping")),
        shydra: Pathname.new(File.expand_path("~/clients/lasto/shydra")),
        streamworker: Pathname.new(File.expand_path("~/clients/lasto/streamworker"))
      }
    end

    def load_points
      [
        'app/models',
        'lib'
      ]
    end

    def lod(what, *to_check )
      # puts "what: #{what.inspect}"
      # puts "to_check: #{to_check.inspect}"
      to_check.map! do |p| 
        case p
        when Symbol
          Work.apps[p]
        when String
          Pathname.new(p)
        when File
          Pathname.new(p.path)
        when Pathname
          p
        end
      end

      to_check = Work.apps.values if to_check.empty?

      # puts "-----------------------------------------------------"
      # puts "what: #{what.inspect}"
      # puts "to_check: #{to_check.inspect}"

      to_check.each do |app|
        load_points.each do |load_point|
          path = app.join(load_point, what)
          # puts "checking #{path.to_s}..."
          if File.exist?(path)
            if File.directory?(path)
              Dir.glob("#{path.to_s}/**/*.rb") do |f|
                puts "loading #{f}"
                load f
              end
            else
              puts "loading #{path.to_s}"
              load path.to_s
            end
          elsif File.exist?("#{path.to_s}.rb")
            puts "loading #{path.to_s}.rb"
            load "#{path.to_s}.rb"
          end
        end
      end
    end
  end
end

mefi_dir = Pathname.new(File.expand_path("~/clients/webify/metafieldeditor"))
ship_dir = Pathname.new(File.expand_path("~/clients/webify/metafieldeditor"))
mefi_initializers_dir = mefi_dir.join( 'config', 'initializers' )
mefi_models_dir = mefi_dir.join( 'app', 'models' )

# load mefi_initializers_dir.join( 'shopify_api_extensions.rb')
load mefi_models_dir.join( 'metafield.rb')

Pry::Commands.block_command "lod", "Load a file from current shopify projects" do |what, *to_check|
  Work.lod(what, *to_check)
end

# Pry::Commands.block_command "bye", "exit any depth" do
# end

Pry::Commands.block_command "switch", "exit any depth" do |site|
  Connection.switch(site)
end

Pry::Commands.block_command "arlog", "Turn ActiveResource logging on/off" do |state|
  state ||= 'on'
  state = state.downcase
  state = 'off' unless state == 'on'
  output.puts "Turning ActiveResource logging #{state}"
  if state == 'on'
    ActiveResource::Base.logger = Logger.new STDOUT
  else
    ActiveResource::Base.logger = nil
  end
end

Pry.config.hooks.add_hook(:before_session, :set_context) { |_, _, pry| pry.input = StringIO.new("cd ShopifyAPI") }
ShopifyAPI.connection
