require "contracts"

module Example3
  include Contracts::Core
  include Contracts::Builtin

  Contract ArrayOf[RespondTo[:size]] => Fixnum
  def self.average_length(values)
    values.map(&:size).reduce(0, :+) / values.size
  end
end
