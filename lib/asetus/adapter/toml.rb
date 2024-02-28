class Asetus
  def to_toml(config)
    Adapter::TOML.to config._asetus_to_hash
  end

  def from_toml(toml)
    Adapter::TOML.from toml
  end

  class Adapter
    class TOML
      class << self
        def to(hash)
          require 'toml'
          ::TOML::Generator.new(hash).body
        end

        def from(toml)
          require 'erb'
          require 'toml'

          template = ERB.new toml

          ::TOML.load template.result
        end
      end
    end
  end
end
