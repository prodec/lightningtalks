require "contracts"

Person = Struct.new(:name, :gender) do
  include Contracts::Core
  include Contracts::Builtin
  include Contracts::Invariants

  invariant(:gender) { gender == :male || gender == :female }
  
  Contract Symbol => Symbol
  def reassign_gender(new_gender)
    self.gender = new_gender
  end
end
