class Asetus
  class ConfigStruct

    def _asetus_to_hash
      hash = {}
      @cfg.each do |key, value|
        if value.class == ConfigStruct
          value = value._asetus_to_hash
        end
        hash[key] = value
      end
      hash
    end

    def empty?
      @cfg.empty?
    end

    private

    def initialize hash=nil
      @cfg = hash ? _asetus_from_hash(hash) : {}
    end

    def method_missing name, *args, &block
      name = name.to_s
      arg = args.first
      if name[-1..-1] == '='
        _asetus_set name[0..-2], arg
      else
        _asetus_get name, arg
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
          value = _asetus_from_hash value
        end
        cfg[key] = value
      end
    end

  end
end
