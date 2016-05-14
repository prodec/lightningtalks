require "contracts"

module Example2
  include Contracts::Core
  include Contracts::Builtin

  Contract ArrayOf[String] => Fixnum
  def self.average_length(strings)
    strings.map(&:size).reduce(0, :+) / strings.size
  end
end
