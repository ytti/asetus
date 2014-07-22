require_relative 'asetus/configstruct'
require_relative 'asetus/adapter/yaml'
require_relative 'asetus/adapter/json'
require 'fileutils'

class AsetusError < StandardError; end
class NoName < AsetusError; end
class UnknownOption < AsetusError; end

# @example common use case
#   CFGS = Asetus.new :name=>'my_sweet_program' :load=>false   # do not load config from filesystem
#   CFGS.default.ssh.port      = 22
#   CFGS.default.ssh.hosts     = %w(host1.example.com host2.example.com)
#   CFGS.default.auth.user     = lana
#   CFGS.default.auth.password = dangerzone
#   CFGS.load  # load system config and user config from filesystem and merge with defaults to #cfg
#   raise StandardError, 'edit ~/.config/my_sweet_program/config' if CFGS.create  # create user config from default config if no system or user config exists
#   # use the damn thing
#   CFG = CFGS.cfg
#   user      = CFG.auth.user
#   password  = CFG.auth.password
#   ssh_port  = CFG.ssh.port
#   ssh_hosts = CFG.ssh.hosts
class Asetus
  CONFIG_FILE = 'config'
  attr_reader :cfg, :default, :file
  attr_accessor :system, :user

  class << self
    def cfg *args
      new(*args).cfg
    end
  end

  # When this is called, by default :system and :user are loaded from
  # filesystem and merged with defefault, so that user overrides system which
  # overrides default
  #
  # @param [Symbol] level which configuration level to load, by defaukt :all
  # @return [void]
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

  # @param [Symbol] level which configuration level to save, by default :user
  # @return [void]
  def save level=:user
    if level == :user
      save_cfg @usrdir, @user
    elsif level == :system
      save_cfg @sysdir, @system
    end
  end

  # @example create user config from default config and raise error, if no config was found
  #   raise StandardError, 'edit ~/.config/name/config' if asetus.create
  # @param [Hash] opts options for Asetus
  # @option opts [Symbol]  :source       source to use for settings to save, by defaylt :default
  # @option opts [Symbol]  :destination  destinatino to use for settings to save, by default :user
  # @option opts [boolean] :load         load config once saved, by default false
  # @return [boolean] true if config didn't exist and was created, false if config already exists
  def create opts={}
    src   = opts.delete :source
    src ||= :default
    dst   = opts.delete :destination
    dst ||= :user
    no_config = false
    no_config = true if @system.empty? and @user.empty?
    if no_config
      src = instance_variable_get '@' + src.to_s
      instance_variable_set('@'+dst.to_s, src.dup)
      save dst
      load if opts.delete :load
    end
    no_config
  end

  private

  # @param [Hash] opts options for Asetus.new
  # @option opts [String]  :name     name to use for asetus (/etc/name/, ~/.config/name/) - autodetected if not defined
  # @option opts [String]  :adapter  adapter to use 'yaml' or 'json' for now
  # @option opts [String]  :usrdir   directory for storing user config ~/.config/name/ by default
  # @option opts [String]  :sysdir   directory for storing system config /etc/name/ by default
  # @option opts [String]  :cfgfile  configuration filename by default CONFIG_FILE
  # @option opts [Hash]    :default  default settings to use
  # @option opts [boolean] :load     automatically load+merge system+user config with defaults in #cfg
  # @option opts [boolean] :key_to_s convert keys to string by calling #to_s for keys
  def initialize opts={}
    @name     = (opts.delete(:name)    or metaname)
    @adapter  = (opts.delete(:adapter) or 'yaml')
    @usrdir   = (opts.delete(:usrdir)  or File.join(Dir.home, '.config', @name))
    @sysdir   = (opts.delete(:sysdir)  or File.join('/etc', @name))
    @cfgfile  = (opts.delete(:cfgfile) or CONFIG_FILE
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
    @file = File.join dir, @cfgfile
    file = File.read @file
    ConfigStruct.new(from(@adapter, file), :key_to_s=>@key_to_s)
  rescue Errno::ENOENT
    ConfigStruct.new
  end

  def save_cfg dir, config
    config = to(@adapter, config)
    file   = File.join dir, @cfgfile
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
