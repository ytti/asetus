class Asetus
  class ConfigStruct

    def _asetus_to_hash
      hash = {}
      @cfg.each do |key, value|
        if value.class == ConfigStruct
          value = value._asetus_to_hash
        end
        key = key.to_s if @key_to_s
        hash[key] = value
      end
      hash
    end

    def empty?
      @cfg.empty?
    end

    def each &block
      @cfg.each(&block)
    end

    def has_key? key
      @cfg.has_key? key
    end

    private

    def initialize hash=nil, opts={}
      @key_to_s = opts.delete :key_to_s
      @cfg = hash ? _asetus_from_hash(hash) : {}
    end

    def method_missing name, *args, &block
      name = name.to_s
      name = args.shift if name[0..1] == '[]' # asetus.cfg['foo']
      arg = args.first
      if    name[-1..-1] == '?'               # asetus.cfg.foo.bar?
        if @cfg.has_key? name[0..-2]
          @cfg[name[0..-2]] ? true : false
        else
          nil
        end
      elsif name[-1..-1] == '='               # asetus.cfg.foo.bar = 'quux'
        _asetus_set name[0..-2], arg
      else
        _asetus_get name, arg                 # asetus.cfg.foo.bar
      end
    end

    def _asetus_set key, value
      @cfg[key] = value
    end

    def _asetus_get key, value
      if @cfg.has_key? key
        @cfg[key]
      else
        @cfg[key] = ConfigStruct.new
      end
    end

    def _asetus_from_hash hash
      cfg = {}
      hash.each do |key, value|
        if value.class == Hash
          value = ConfigStruct.new value, :key_to_s=>@key_to_s
        end
        cfg[key] = value
      end
      cfg
    end

  end
end
