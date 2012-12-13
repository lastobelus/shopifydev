# Shopifydev

Abstract out and port to ruby the functionality of the shopify textmate bundle for use in other editors.

## Installation

Add this line to your application's Gemfile:

    gem 'shopifydev'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install shopifydev

Once Shopifydev is installed, you'll need to add a .shopifydev.yaml file to your project root. This config
file should contain the secrets specific to the shopify site you are working on. Here's a sample:

    api_key: youneedakey
    password: andapassword
    url: my_store_url.myshopify.com

Don't include 'http://' in the url, and don't commit this file to your repo (because secrets).

Once that's done there's just ONE MORE THING. You need to have an environment variable,

    export TM_PROJECT_DIRECTORY='where_files_live'

Later on we'll set this app up to use different variables depending on what text editor you are using
but for now it is TM by default. If you have a couple of projects, you are going to get tired of 
exporting variables all the time... so we'll fix this soon.

## Usage


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
