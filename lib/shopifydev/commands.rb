
require "logger"
require "shopify_api"

module Shopifydev
  class CommandRunner

  def initialize
    @devshop = Shopifydev::Shop.new(credentials)
  end

  def credentials
    unless @credentials
      @credentials = YAML::load(
        File.open('.shopifydev.yaml'))
    end

    @credentials
  end

  def upload(remote_key, options={})
    # Download just one asset

    @devshop.asset(remote_key).upload
  end

  def download(options={})
    # Download the whole template

    @devshop.template.download
  end

  end
end
