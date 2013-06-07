module Shopifydev
  module Generators
    class Shop < Thor::Group
      include Thor::Actions

      source_root File.expand_path('../templates', __FILE__)
      
      argument :name
      class_option :test_shop
      class_option :live_shop

      def setup
        create_file "#{name}/TODO"
        copy_file "Gemfile", "#{name}/Gemfile"
        copy_file "rvmrc", "#{name}/.rvmrc"
        copy_file "gitignore", "#{name}/.gitignore"
        copy_file "shopify-tmbundle", "#{name}/.shopify-tmbundle"
        system "git init"
        system "git add --all"
        system 'git commit -m "initial setup"'
      end
 
      def download_template
        say "TODO: automate downloading template from test shop"
      end
 
    end
  end
end