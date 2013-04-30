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

## Usage

WARNING: Files will always be uploaded from `project_root/`. This is great, because it means you can keep 
the shopify files separate from whatever sweet app you happen to be working on. Unfortunately, at the 
moment, this means autocompletion of file names really only works if `project_root` is `'.'`. But Imma fix 
that.

With shopifydev uploading a shopify file is a snap!

    $ shopifydev upload assets/some_pic.jpg

Uploading two files is also a snap!

    $ shopifydev upload assets/cart.png templates/cart.liquid 

More files? It's a UNIX system! You know this!

    $ shopifydev upload {snippets,templates}/*.liquid

But Mr Authors, what if I don't have any files to upload?

    $ shopify download

What could be better than that? How about uploading all your files:

    $ shopifydev upload --patchify patch_directory

I wouldn't recommend running that with '.' or any directory that contains subdirectories shopify wouldn't recognize. I'll fix that someday too! (^o ^)//

One final tip: `alias upify='shopifydev upload'`

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
