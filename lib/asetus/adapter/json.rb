class Asetus
  def to_json(config)
    Adapter::JSON.to config._asetus_to_hash
  end

  def from_json(json)
    Adapter::JSON.from json
  end

  class Adapter
    class JSON
      class << self
        def to(hash)
          require 'json'
          ::JSON.pretty_generate hash
        end

        def from(json)
          require 'erb'
          require 'json'

          template = ERB.new json

          ::JSON.load template.result
        end
      end
    end
  end
end
