#!/usr/bin/env ruby

require 'set'

def read_input
    input = File.open("../inputs/input22.txt", "r")
    cubedefs = input.each_line.map do |line|
        /^(?<val>on|off)\s
          x=(?<x1>-?\d+)\.\.(?<x2>-?\d+),
          y=(?<y1>-?\d+)\.\.(?<y2>-?\d+),
          z=(?<z1>-?\d+)\.\.(?<z2>-?\d+)/x =~ line.chomp
        {
            :on => val == "on",
            :coords => [x1, x2, y1, y2, z1, z2].map(&:to_i)
        }
    end
end

# Test if first cube contains second
def contain_3d?(ca, cb)
    (ax1, ax2, ay1, ay2, az1, az2) = ca
    (bx1, bx2, by1, by2, bz1, bz2) = cb
    bx1.between?(ax1,ax2) &&
    bx2.between?(ax1,ax2) &&
    by1.between?(ay1,ay2) &&
    by2.between?(ay1,ay2) &&
    bz1.between?(az1,az2) &&
    bz2.between?(az1,az2)
end

# Assume coords always increasing
def intersect_1d(a1, a2, b1, b2)
    if a1 > b2 || a2 < b1
        # no intersect
        nil
    elsif b1 <= a1 && a2 <= b2
        # full intersect: a in b
        [a1, a2]
    elsif (a1 <= b1 && b2 <= a2)
        # full intersect: b in a
        [b1, b2]
    elsif b1 >= a1 && b2 >= a2
        # partial intersect, b beyond a
        [b1, a2]
    elsif a1 >= b1 && a2 >= b2
        # partial intersect, a beyond b
        [a1, b2]
    end
end

# Given 2 cubes, return coords of intersection cube
def intersect_3d(ca, cb)
    (ax1, ax2, ay1, ay2, az1, az2) = ca
    (bx1, bx2, by1, by2, bz1, bz2) = cb
    # intersect by axis
    x_sect = intersect_1d(ax1, ax2, bx1, bx2)
    return nil if !x_sect
    y_sect = intersect_1d(ay1, ay2, by1, by2)
    return nil if !y_sect
    z_sect = intersect_1d(az1, az2, bz1, bz2)
    return nil if !z_sect
    # combine into 6-tuple
    [x_sect, y_sect, z_sect].flatten
end

# Split ca and return its list of 1 to 6 cubelets, minus intersection
def split_to_cubelets(ca, intersect)
    (ax1, ax2, ay1, ay2, az1, az2) = ca
    p [:a, ca] if ca.nil? or ca.any?{ |a| a.nil? }
    (xs1, xs2, ys1, ys2, zs1, zs2) = intersect
    p [:b, intersect] if intersect.nil? or intersect.any?{ |a| a.nil? }
    cubelets = []
    if xs1 > ax1
        cubelets.push([ax1, xs1 - 1, ay1, ay2, az1, az2])
    end
    if xs2 < ax2
        cubelets.push([xs2 + 1, ax2, ay1, ay2, az1, az2])
    end
    if ys1 > ay1
        cubelets.push([xs1, xs2, ay1, ys1 - 1, az1, az2])
    end
    if ys2 < ay2
        cubelets.push([xs1, xs2, ys2 + 1, ay2, az1, az2])
    end
    if zs1 > az1
        cubelets.push([xs1, xs2, ys1, ys2, az1, zs1 - 1])
    end
    if zs2 < az2
        cubelets.push([xs1, xs2, ys1, ys2, zs2 + 1, az2])
    end
    cubelets
end

def aggregate_input_cubes(limit)
    on_cubes = Set.new()
    # get next cube, cb
    read_input.take(limit).each do |cb|
        cbc = cb[:coords]
        new_on_cubes = Set.new()
        # compare with previous cubes, ca (intersect them)
        on_cubes.each do |cac|
            if contain_3d?(cbc, cac)
                on_cubes.delete(cac)
            else
                int = intersect_3d(cac, cbc)
                if int
                    # split ca
                    new_on_cubes.merge(split_to_cubelets(cac, int))
                    on_cubes.delete(cac)
                end
            end
        end
        if cb[:on]
            new_on_cubes.add(cbc)
        end
        on_cubes.merge(new_on_cubes)
    end
    on_cubes
end

def sum_volumes(cubes)
    cubes.map{ |cc| (cc[1] + 1 - cc[0]) * (cc[3] + 1 - cc[2]) * (cc[5] + 1 - cc[4]) }.reduce(:+)
end

# sum all on_cubes volumes
p "Part 1: #{sum_volumes(aggregate_input_cubes(20))}" # 623748
p "Part 2: #{sum_volumes(aggregate_input_cubes(420))}" # 1227345351869476
