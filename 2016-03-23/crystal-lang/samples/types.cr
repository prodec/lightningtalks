def length_me_up(obj)
  obj.size
end

puts length_me_up({ "foo" => 1, "bar" => 2 })
puts length_me_up([1, 2, 3, 4])
puts length_me_up("asfasdfasf")
puts length_me_up(1)
