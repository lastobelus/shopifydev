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
    project_root: relative/path (this might just be '.' for a lot of you cats)
    project_root_variable: SOME_ENVIRONMENT_VARIABLE

Don't include 'http://' in the url, and don't commit this file to your repo (because secrets). The project
root should be the directory where the 'assets' directory lives. If you would rather use an environment
variable specific to your text editor of choice, like TM_PROJECT_DIRECTORY, you can supply that as well.
Shopifydev will always prefer the environment variable, though.

## TODO

Currently we haven't implemented uploading layouts or the files in the config directoyr, like the
settings data.

## Usage

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
