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

# read_input.take(20).each do |i|
#     i[:xrange].each{ |x|
#         i[:yrange].each{ |y|
#             i[:zrange].each{ |z|
#                 @minicubes[[x,y,z]] = i[:on]
#             }
#         }
#     }
# end
# p "Part 1: #{@minicubes.values.count(true)}" # 623748

# Assume coords always increasing
def intersect_1d(a1, a2, b1, b2)
    if a1 > b2 || a2 < b1
        # no intersect
        nil
    elsif b1 <= a1 && a2 <= b2
        # full intersect: a in b
        p [a1, a2]
    elsif (a1 <= b1 && b2 <= a2)
        # full intersect: b in a
        p [b1, b2]
    elsif b1 >= a1 && b2 >= a2
        # partial intersect, b beyond a
        p [b1, a2]
    elsif a1 >= b1 && a2 >= b2
        # partial intersect, a beyond b
        p [a1, b2]
    end
end

# Given 2 cubes, return
# - coords of intersection cube
# - list of coords of up to 6 non-matching cubelets of ca
def intersect_3d(ca, cb)
    (ax1, ax2, ay1, ay2, az1, az2) = ca
    (bx1, bx2, by1, by2, bz1, bz2) = cb
    # intersect by axis
    p x_sect = intersect_1d(ax1, ax2, bx1, bx2)
    p y_sect = intersect_1d(ay1, ay2, by1, by2)
    p z_sect = intersect_1d(az1, az2, bz1, bz2)
    p intersect = (x_sect && y_sect && z_sect) ? [x_sect, y_sect, z_sect].flatten : nil
    # find cubelets of ca
    cubelets = []
    if x_sect
        if x_sect[0] > ax1
            cubelets.push([ax1, x_sect[0] - 1, ay1, ay2, az1, az2])
        end
        if x_sect[1] < ax2
            cubelets.push([x_sect[1] + 1, ax2, ay1, ay2, az1, az2])
        end
    end
    if y_sect
        if y_sect[0] > ay1
            cubelets.push([x_sect[0], x_sect[1], ay1, y_sect[0] - 1, az1, az2])
        end
        if y_sect[1] < ay2
            cubelets.push([x_sect[0], x_sect[1], y_sect[1] + 1, ay2, az1, az2])
        end
    end
    if z_sect
        if z_sect[0] > az1
            cubelets.push([x_sect[0], x_sect[1], y_sect[0], y_sect[1], az1, z_sect[0] - 1])
        end
        if z_sect[1] < az2
            cubelets.push([x_sect[0], x_sect[1], y_sect[0], y_sect[1], z_sect[1] + 1, az2])
        end
    end
    [intersect, cubelets]
end

cube1 = [0,9,0,9,0,9]
cube2 = [3,6,3,6,3,6]
p intersect_3d(cube1, cube2)
