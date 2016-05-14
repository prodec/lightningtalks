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
      (0...dimensions).map { |d| (coord(d) - other.coord(d))**2 }.reduce(0) { |a, b|
        a + b
      }
    end
  end

  class Point2d < Point
    def initialize(x : Int64, y : Int64)
      @x = x
      @y = y
    end

    def dimensions
      2
    end

    def coord(dimension)
      dimension == 0 ? @x : @y
    end

    def to_s
      "#{@x}, #{@y}"
    end
  end

  def self.nearest_neighbor(probe : Point, node : Node)
    if node.empty?
      nil
    elsif node.leaf? && (node as ValueNode).value
      (node as ValueNode).value
    else
      value_node = node as ValueNode
      axis = value_node.axis
      value = value_node.value
      x_probe = probe.coord(axis)
      x_value = value.coord(axis)

      if x_probe <= x_value
        find_nearest(x_probe, x_value, probe, value, value_node.left, value_node.right)
      else
        find_nearest(x_probe, x_value, probe, value, value_node.right, value_node.left)
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
                     nearest = nearest_neighbor(probe, tree_b)
                     candidates_a + (nearest ? [nearest] : [] of Point)
                   else
                     candidates_a
                   end

    candidates_b.sort { |va, vb|
      dva = probe.distance(va)
      dvb = probe.distance(vb)

      dva <=> dvb
    }.first
  end

  def self.build(dimensions, vertices, depth = 0)
    axis = depth % dimensions

    if vertices.size == 0
      EmptyNode.instance
    elsif vertices.size == 1
      ValueNode.new(vertices[0], axis)
    else
      sorted = sort_vertices_by_axis(vertices, axis)
      median = (sorted.size / 2)
      left = build(dimensions, sorted[0...median], depth + 1)
      right = build(dimensions, sorted[median + 1..-1], depth + 1)

      ValueNode.new(sorted[median], axis, left, right)
    end
  end

  def self.sort_vertices_by_axis(vertices, axis)
    vertices.sort { |va, vb|
      ca = va.coord(axis)
      cb = vb.coord(axis)

      ca <=> cb
    }
  end

  class Node
    def empty?
      true
    end

    def leaf?
      false
    end
  end

  class EmptyNode < Node
    def to_s
      "()"
    end

    def self.instance
      @@_instance ||= EmptyNode.new
    end
  end

  class ValueNode < Node
    def initialize(value, axis, left = EmptyNode.instance, right = EmptyNode.instance)
      @value = value
      @axis = axis
      @left = left
      @right = right
      @leaf = right.empty? && left.empty?
    end

    getter :axis, :value, :left, :right

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
  class Random
    def initialize(@rng : PRNG, @value : Int64)
    end

    getter :rng, :value
  end

  def initialize(seed : Int64)
    @seed = seed
  end

  def rand
    new_seed = (@seed * 25_214_903_917 + 11) & 281_474_976_710_655
    new_value = new_seed >> 16

    Random.new(PRNG.new(new_seed), new_value)
  end
end

struct VertexGeneration
  def initialize(@rng, @vertices)
  end

  getter :rng, :vertices
end


def using_prng
  starting_gen = VertexGeneration.new(PRNG.new(42_i64), [] of KdTree::Point)
  rng_vertices = (1..100).reduce(starting_gen) { |vgn, _|
    x_val = vgn.rng.rand
    y_val = x_val.rng.rand

    VertexGeneration.new(y_val.rng, vgn.vertices + [KdTree::Point2d.new(x_val.value, y_val.value)])
  }

  tree = KdTree.build(2, rng_vertices.vertices)

  Benchmark.bm do |x|
    x.report("prng") do
      100_000.times.reduce(rng_vertices.rng) { |rng|
        x_val = rng.rand
        y_val = x_val.rng.rand

        KdTree.nearest_neighbor(KdTree::Point2d.new(x_val.value, y_val.value), tree)

        y_val.rng
      }
    end
  end

  puts
  puts "Nearest to (11231, 531123): #{KdTree.nearest_neighbor(KdTree::Point2d.new(11231_i64, 531123_i64), tree).to_s}"
end

def using_rand
  vertices = (1..100).reduce([] of KdTree::Point) { |vs|
    vs + [KdTree::Point2d.new(rand, rand)]
  }

  tree = KdTree.build(2, vertices)

  Benchmark.bm do |x|
    x.report("rand") do
      100_000.times {
        KdTree.nearest_neighbor(KdTree::Point2d.new(rand, rand), tree)
      }
    end
  end
end

using_prng

