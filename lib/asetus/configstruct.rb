class Asetus
  class ConfigStruct

    def _asetus_to_hash
      hash = {}
      @cfg.each do |key, value|
        if value.class == ConfigStruct
          value = value._asetus_to_hash
        end
        key = key.to_s
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

    def keys
      @cfg.keys
    end

    def has_key? key
      @cfg.has_key? key
    end

    # [] accessors always succeed
    def [] key
      _asetus_get key, false                  # asetus.cfg['foo']['bar']
    end

    def []= key, arg
      _asetus_set key, arg                    # asetus.cfg['foo']['bar'] = 'quux'
    end

    private

    def initialize hash=nil, opts={}
      @cfg = hash ? _asetus_from_hash(hash) : {}
    end

    # cfg.foo.bar will fail unless already set
    def method_missing name, *args, &block
      name = name.to_s
      arg = args.first
      if name[-1..-1] == '?'                  # asetus.cfg.foo.bar?
        @cfg.has_key? name[0..-2]
      elsif name[-1..-1] == '='               # asetus.cfg.foo.bar = 'quux'
        _asetus_set name[0..-2], arg
      else
        _asetus_get name, false               # asetus.cfg.foo.bar
      end
    end
    
    def _asetus_set key, value
      key = key.to_s
      @cfg[key] = value
    end

    def _asetus_get key, error=false
      key = key.to_s
      if @cfg.has_key? key
        @cfg[key]
      else
        raise Unset, key if error
        nil
      end
    end

    def _asetus_from_hash hash
      cfg = {}
      hash.each do |key, value|
        if value.class == Hash
          value = ConfigStruct.new value
        end
        cfg[key] = value
      end
      cfg
    end
  end
end
