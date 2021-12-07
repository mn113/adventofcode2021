#!/usr/bin/env ruby

@crabs = File.open("../inputs/input07.txt", "r").each_line.first.split(",").map(&:to_i)

"""
Find fuel amount (r) needed to minimise sum of movements to align all crab positions.
"""
def part1
    lowest_sum = 9999999

    (@crabs.min..@crabs.max).map do |r|
        deltas = @crabs.map{ |c| (c - r).abs }
        sum = deltas.reduce(:+)
        if sum <= lowest_sum
            lowest_sum = sum
        else
            break lowest_sum
        end
    end
end

"""
Find fuel amount (r) needed to minimise sum of movements to align all crab positions.
Larger movements cost more, e.g. moving 5 costs 1+2+3+4+5
"""
def part2
    lowest_sum = 9999999999

    (@crabs.min..@crabs.max).map do |r|
        deltas = @crabs.map{ |c| (c - r).abs }
        sum = deltas.map{ |d|
            d > 0 ? (1..d).reduce(:+) : 0
        }.reduce(:+)
        if sum <= lowest_sum
            lowest_sum = sum
        else
            break lowest_sum
        end
    end
end

p "Part 1: #{part1}" # P1: 328187
p "Part 2: #{part2}" # P2: 91257582

