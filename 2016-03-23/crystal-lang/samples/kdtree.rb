require "benchmark"

module KdTree
  class Point
    def dimensions
      raise "Implement this"
    end

    def coord(dimension)
      raise "Implement this"
    end

    def distance(other)
      (0...dimensions).map { |d| (coord(d) - other.coord(d))**2 }.reduce(0, :+)
    end

    def to_s
      "#{@x}, #{@y}"
    end
  end

  class Point2d < Point
    def initialize(x, y)
      @x = x
      @y = y
    end

    def dimensions
      2
    end

    def coord(dimension)
      dimension == 0 ? @x : @y
    end
  end

  def self.nearest_neighbor(probe, node)
    if node.empty?
      nil
    elsif node.leaf? && node.value
      node.value
    else
      axis = node.axis
      value = node.value
      x_probe = probe.coord(axis)
      x_value = value.coord(axis)

      if x_probe <= x_value
        find_nearest(x_probe, x_value, probe, value, node.left, node.right)
      else
        find_nearest(x_probe, x_value, probe, value, node.right, node.left)
      end
    end
  end

  def self.find_nearest(x_probe, x_value, probe, value, tree_a, tree_b)
    temp_a = nearest_neighbor(probe, tree_a)
    sphere_intersects_plane =
      (x_probe - x_value)**2 <= probe.distance(value)

    candidates_a = if temp_a
                     [temp_a, value]
                   else
                     [value]
                   end

    candidates_b = if sphere_intersects_plane
                     candidates_a + Array(nearest_neighbor(probe, tree_b))
                   else
                     candidates_a
                   end

    candidates_b.sort { |va, vb|
      probe.distance(va) - probe.distance(vb)
    }.first
  end

  def self.build(dimensions, vertices, depth = 0)
    axis = depth % dimensions

    if vertices.size == 0
      EmptyNode.instance
    elsif vertices.size == 1
      Node.new(vertices[0], axis)
    else
      sorted = sort_vertices_by_axis(vertices, axis)
      median = (sorted.size / 2)
      left = build(dimensions, sorted[0...median], depth + 1)
      right = build(dimensions, sorted[median + 1..-1], depth + 1)

      Node.new(sorted[median], axis, left, right)
    end
  end

  def self.sort_vertices_by_axis(vertices, axis)
    vertices.sort { |va, vb| va.coord(axis) - vb.coord(axis) }
  end

  class EmptyNode
    def leaf?
      false
    end

    def empty?
      true
    end

    def to_s
      "()"
    end

    def self.instance
      @_instance ||= EmptyNode.new
    end
  end

  class Node
    def initialize(value, axis, left = EmptyNode.instance, right = EmptyNode.instance)
      @value = value
      @axis = axis
      @left = left
      @right = right
      @leaf = right.empty? && left.empty?
    end

    attr_reader :axis, :value, :left, :right

    def empty?
      false
    end

    def leaf?
      @leaf
    end

    def to_s
      "#{@value}, (#{@left}, #{@right})"
    end
  end
end

class PRNG
  def initialize(seed)
    @seed = seed
  end

  def rand
    new_seed = (@seed * 25_214_903_917 + 11) & 281_474_976_710_655
    new_value = new_seed >> 16
    [PRNG.new(new_seed), new_value]
  end
end

def using_prng
  prng, vertices = (1..100).reduce([PRNG.new(42), []]) { |(prng, vs), _|
    nprng, x = prng.rand
    nnprng, y = nprng.rand

    [nnprng, vs + [KdTree::Point2d.new(x, y)]]
  }

  tree = KdTree.build(2, vertices)

  Benchmark.bm do |x|
    x.report("prng") do
      100_000.times.reduce(prng) { |rng|
        nrng, x = rng.rand
        nnrng, y = nrng.rand

        KdTree.nearest_neighbor(KdTree::Point2d.new(x, y), tree)

        nnrng
      }
    end
  end

  puts
  puts "Nearest to (11231, 531123): #{KdTree.nearest_neighbor(KdTree::Point2d.new(11231, 531123), tree)}"
end

def using_rand
  vertices = (1..100).reduce([]) { |vs|
    vs + [KdTree::Point2d.new(rand, rand)]
  }

  tree = KdTree.build(2, vertices)

  Benchmark.bm do |x|
    x.report("rand") do
      100000.times {
        KdTree.nearest_neighbor(KdTree::Point2d.new(rand, rand), tree)
      }
    end
  end
end


using_prng
