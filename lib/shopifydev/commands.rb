
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

  def upload(remote_keys)
    # upload one asset or directory
    raise "no shopify files were specified" if remote_keys.empty?

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

      self.upload(Array.wrap(File.join(file.split('/')[-2..-1])))
    end
  end

  def gitify
    porcelain = `git status --porcelain`

    modified = porcelain.scan(/^[ AM][M](.*)/).flatten.each {|f| f.strip!}

    puts modified.inspect

    top_level = ["assets", "snippets", "templates", "layout"]
    remote_keys = modified.select do |file|
        file.split('/').any? { |f| top_level.include?(f) }
    end

    puts remote_keys.inspect

    remote_keys.each do |file|
      `git add #{file}`
    end

    upload(remote_keys)
  end

  def upload_dir(upload_dir)
    # upload all assets in the given dir

    Dir[upload_dir + "/**/*"].each do |remote_key|
      self.upload([remote_key].squeeze("/"))
    end
  end

  def upload_glob(glob)
    # upload all assets in the given dir matching a given pattern

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
