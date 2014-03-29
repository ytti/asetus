class Asetus

  def to_yaml config
    Adapter::YAML.to config._asetus_to_hash
  end

  def from_yaml yaml
    Adapter::YAML.from yaml
  end

  class Adapter
    class YAML
      class << self
        def to hash
          require 'yaml'
          ::YAML.dump hash
        end

        def from yaml
          require 'yaml'
          ::YAML.load yaml
        end
      end
    end
  end

end
