
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

  def upload(remote_keys, options={})
    # upload one asset or directory

    remote_keys.each do |remote_key|
      if File.directory?(remote_key) then
        self.upload_dir(remote_key)
      else
        @devshop.asset(remote_key).upload
      end
    end
  end

  def patchify(patch_dir)
    ENV['PATCHIFY_ROOT'] = patch_dir # temporarily set an environment variable

    Dir.glob(File.join(ENV['PATCHIFY_ROOT'], "*/*")).reverse.each do |file|
      self.upload(file)
    end
  end

  def upload_dir(upload_dir)
    # upload all assets in the given dir

    Dir[upload_dir + "/*"].each do |remote_key|
      self.upload(remote_key)
    end
  end

  def upload_glob(glob)
    # upload all assets in the given dir matching a given pattern
    puts "in"

    glob.each do |remote_key|
      self.upload(remote_key)
    end
  end

  def download(options={})
    # Download the whole template

    @devshop.template.download
  end

  end
end
