#!/usr/bin/env ruby

require 'set'

@grid = File.open("../inputs/input09.txt", "r").each_line.map{ |r| r.chomp.chars.map(&:to_i) }

@ydim = @grid.size
@xdim = @grid[0].size

def surround_by_9s(grid)
    newdim = grid[0].size + 2
    newrow = Array.new(newdim, 9)
    [newrow] + grid.map{ |row| [9] + row + [9] } + [newrow]
end

@wrapped_grid = surround_by_9s(@grid)

"""
Find all low points within the grid
"""
def part1
    lowscores = []
    for y in (1..@ydim) do
        for x in (1..@xdim) do
            cellval = @wrapped_grid[y][x]
            nbvals = [@wrapped_grid[y-1][x], @wrapped_grid[y+1][x], @wrapped_grid[y][x-1], @wrapped_grid[y][x+1]]
            if nbvals.all?{ |nb| nb > cellval }
                lowscores.push(cellval)
            end
        end
    end
    lowscores.reduce(:+) + lowscores.count
end

"""
Model a droplet's flow from any high point to its final low point. Gather all points on route.
"""
def follow_flow(origin)
    low = nil
    seen = []
    to_see = [origin]
    # BFS until queue fully exhausted
    while to_see.size > 0 do
        (px, py) = to_see.shift
        pval = @wrapped_grid[py][px]
        # look at all 4 nbs
        nbs = [[px,py-1], [px,py+1], [px-1,py], [px+1,py]]
        lowernbs = nbs.select{ |nb| @wrapped_grid[nb[1]][nb[0]] < pval }
        # enqueue only lower nbs
        if lowernbs.size > 0
            to_see += lowernbs
        else
            # when all nbs higher, low found -> set as return value
            low = [px,py]
        end
        seen += [[px,py]]
    end
    [low, seen]
end

"""
Find 3 largest 3 basins in the grid
"""
def part2
    # basins: Keys are low points [x,y]. Values are the sets of higher points flowing to the low
    basins = {}
    # track seen points, to avoid repeating work
    seen = Set.new
    for y in (1..@ydim) do
        for x in (1..@xdim) do
            cell = [x,y]
            next if seen.include? cell
            cellval = @wrapped_grid[y][x]
            # by chance, nothing under 4 matters
            if cellval.between?(4, 8)
                (low, points) = follow_flow(cell)
                seen.merge(points)
                # assign or extend hash entry
                if basins[low]
                    basins[low].merge(points)
                else
                    basins[low] = Set.new(points)
                end
            end
        end
    end
    sorted_sizes = basins.values.map(&:size).sort{ |x,y| y <=> x }
    sorted_sizes.take(3).reduce(:*)
end

p "Part 1: #{part1}" # 494
p "Part 2: #{part2}" # 1048128
