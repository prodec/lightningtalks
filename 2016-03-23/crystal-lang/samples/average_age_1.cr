class Person
  def initialize(@name, @age)
  end

  getter :name, :age
end
  
def average_age(people : Array(Person))
  return 0 if people.empty?

  sum_ages = people.map { |p| p.age }.reduce(0) { |a, b| a + b }
  sum_ages / people.size
end

puts average_age([Person.new("Mary", 10), Person.new("John", 13)])
