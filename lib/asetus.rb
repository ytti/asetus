require_relative 'asetus/configstruct'
require_relative 'asetus/adapter/yaml'
require_relative 'asetus/adapter/json'
require 'fileutils'

class AsetusError < StandardError; end
class NoName < AsetusError; end
class UnknownOption < AsetusError; end

class Asetus
  CONFIG_FILE = 'config'
  attr_reader :cfg, :default
  attr_accessor :system, :user

  class << self
    def cfg *args
      new(*args).cfg
    end
  end

  def load level=:all
    if level == :default or level == :all
      @cfg = merge @cfg, @default
    end
    if level == :system or level == :all
      @system = load_cfg @sysdir
      @cfg = merge @cfg, @system
    end
    if level == :user or level == :all
      @user = load_cfg @usrdir
      @cfg = merge @cfg, @user
    end
  end

  def save level=:user
    if level == :user
      save_cfg @usrdir, @user
    elsif level == :system
      save_cfg @sysdir, @system
    end
  end

  private

  def initialize opts={}
    @name     = (opts.delete(:name)    or metaname)
    @adapter  = (opts.delete(:adapter) or 'yaml')
    @usrdir   = (opts.delete(:usrdir)  or File.join(Dir.home, '.config', @name))
    @sysdir   = (opts.delete(:sysdir)  or File.join('/etc', @name))
    @default  = ConfigStruct.new opts.delete(:default)
    @system   = ConfigStruct.new
    @user     = ConfigStruct.new
    @cfg      = ConfigStruct.new
    @load     = true
    @load     = opts.delete(:load) if opts.has_key?(:load)
    @key_to_s = opts.delete(:key_to_s)
    raise UnknownOption, "option '#{opts}' not recognized" unless opts.empty?
    load :all if @load
  end

  def load_cfg dir
    file = File.join dir, CONFIG_FILE
    file = File.read file
    ConfigStruct.new(from(@adapter, file), :key_to_s=>@key_to_s)
  rescue Errno::ENOENT
    ConfigStruct.new
  end

  def save_cfg dir, config
    config = to(@adapter, config)
    file   = File.join dir, CONFIG_FILE
    FileUtils.mkdir_p dir
    File.write file, config
  end

  def merge *configs
    hash = {}
    configs.each do |config|
      hash = hash._asetus_deep_merge config._asetus_to_hash
    end
    ConfigStruct.new hash
  end

  def from adapter, string
    name = 'from_' + adapter
    send name, string
  end

  def to adapter, config
    name = 'to_' + adapter
    send name, config
  end

  def metaname
    path = caller_locations[-1].path
    File.basename path, File.extname(path)
  rescue
    raise NoName, "can't figure out name, specify explicitly"
  end
end

class Hash
  def _asetus_deep_merge newhash
    merger = proc do |key, oldval, newval|
      Hash === oldval && Hash === newval ? oldval.merge(newval, &merger) : newval
    end
    merge newhash, &merger
  end
end
