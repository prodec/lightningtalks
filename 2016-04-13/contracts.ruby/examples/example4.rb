require "contracts"

Person = Struct.new(:name, :gender)

module IdentifiesAsMale
  def self.valid?(person)
    person.gender == :male
  end
end

module Example4
  include Contracts::Core
  include Contracts::Builtin

  Contract ArrayOf[IdentifiesAsMale] => ArrayOf[String]
  def self.boy_names(boys)
    boys.map(&:name)
  end
end
