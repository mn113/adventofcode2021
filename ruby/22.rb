#!/usr/bin/env ruby

def read_input
    input = File.open("../inputs/input22.txt", "r")
    # on x=-26..26,y=-40..10,z=-12..42
    instructions = input.each_line.map do |line|
    	/^(?<val>on|off)\s
          x=(?<x1>-?\d+)\.\.(?<x2>-?\d+),
          y=(?<y1>-?\d+)\.\.(?<y2>-?\d+),
          z=(?<z1>-?\d+)\.\.(?<z2>-?\d+)/x =~ line.chomp
    	{
            :on => val == "on",
            :x1 => x1.to_i,
            :x2 => x2.to_i,
            :y1 => y1.to_i,
            :y2 => y2.to_i,
            :z1 => z1.to_i,
            :z2 => z2.to_i,
            :xrange => (x1.to_i..x2.to_i),
            :yrange => (y1.to_i..y2.to_i),
            :zrange => (z1.to_i..z2.to_i)
        }
    end
end

@minicubes = {}

read_input.take(20).each do |i|
    i[:xrange].each{ |x|
        i[:yrange].each{ |y|
            i[:zrange].each{ |z|
                @minicubes[[x,y,z]] = i[:on]
            }
        }
    }
end
p "Part 1: #{@minicubes.values.count(true)}" #

def intersect_cubes(ca, cb)
    (ax1, ax2, ay1, ay2, az1, az2) = ca
    (bx1, bx2, by1, by2, bz1, bz2) = cb
end
