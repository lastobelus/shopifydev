require "shopify_api"

class PreferenceMetafield < ShopifyAPI::Metafield
  class_attribute :namespace
  PreferenceMetafield.namespace = "WorldShipCalculator"
  self.element_name = "metafield"

  def initialize(attrs={}, *args)
    puts "PreferenceMetafield *args: #{args.inspect}"
    super(attrs.merge({
        namespace: PreferenceMetafield.namespace,
        owner_resource: "shop"
      }), *args)
  end

  def self.all
    find(:all, 
      params: {namespace: PreferenceMetafield.namespace, owner_resource: "shop"})
  end
end


class Preference
  class TypeError < StandardError
  end
  class InvalidError < StandardError
  end
  # include ActiveModel::Model
  extend  ActiveModel::Naming
  extend  ActiveModel::Translation
  include ActiveModel::Validations
  include ActiveModel::Conversion
  include ActiveModel::Dirty

  class_attribute :attributes
  
  attr_accessor :attributes, :defaults, :metafields

  def self.attribute(name, options={})
    name = name.to_sym
    options = {type: :string, default: ""}.merge(options)
    Preference.attributes ||= {}
    Preference.attributes[name] = options
    define_method name do
      @attributes.has_key?(name) ? @attributes[name] : @defaults[name]
    end

    define_method "#{name.to_s}=".to_sym do |val|
      if (@attributes.has_key?(name) && (val != @attributes[name])) ||
          (val != @defaults[name])
        self.send("#{name.to_s}_will_change!") unless val == @attributes[name]
        @attributes[name] = val
      end
    end

    define_attribute_methods [name]
  end

  def initialize(params={})
    @attributes = HashWithIndifferentAccess.new
    @metafields = PreferenceMetafield.all
    @defaults =  Hash[Preference.attributes.map{|key, defn| [key, defn[:default]]}]
    params.each do |attr, value|
      self.public_send("#{attr}=", value)
    end if params
    @metafields.each do |mf|
      @attributes[mf.key.to_sym] = mf.value
    end
  end

  def attribute_names
    Preference.attributes.keys
  end

  validate :must_have_correct_type
  def must_have_correct_type
    Preference.attributes.each do |name, defn|
      new_val = typecast_value(name, @attributes[name], defn[:type])
      puts "setting #{name} to #{new_val} which is a #{new_val.class.inspect}"
      @attributes[name] = typecast_value(name, @attributes[name], defn[:type])
    end
  end

  def typecast_value(name, value, type)
    begin
      case type
      when :string
        value.to_s
      when :integer
        value.to_i
      when :boolean
        case value
        when TrueClass, 1, /t(rue)?/i, "1"
          1
        when FalseClass, 0, /f(alse)?/i, "0"
          0
        end
      end
    rescue
      raise TypeError.new("#{value.class.name} but should be a kind of #{type}")
    end
  end

  def persisted?
    @_persisted
  end

  def self.find
    pref = Preference.new
    pref.metafields = PreferenceMetafield.all
    pref.metafields.each { |mf| pref.public_send("#{mf.key}=", mf.value) }
    pref
  end


  def save(force=false)
    unless valid? || force
      raise InvalidError.new(errors.full_messages)
    end
    attrs = force ? attribute_names : changed
    attrs.each do |name|
      puts "name: #{name}"
      value = self.public_send(name)

      metafield = @metafields.find{|mf| mf.key == name }
      metafield ||= PreferenceMetafield.new({
        key: name,
        value_type: value.is_a?(Integer) ? "integer" : "string"
      })
      metafield.value = value
      metafield.value_type = value.is_a?(Integer) ? "integer" : "string"
      puts "saving #{name}: #{value.inspect}"
      metafield.save
    end
    @_persisted = true
    puts "finished saving"
  end
end
