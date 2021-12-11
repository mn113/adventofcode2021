#!/usr/bin/env ruby

@grid = File.open("../inputs/input11.txt", "r").each_line.map{ |r| r.chomp.chars.map(&:to_i) }

@ydim = @grid.size
@xdim = @grid[0].size
@area = @xdim * @ydim

"""
Increase every cell's value by 1
"""
def do_simple_boost(grid)
    for y in (0...@ydim) do
        for x in (0...@xdim) do
            grid[y][x] += 1
        end
    end
    grid
end

"""
Propagate energy from all cells greater than 9, to their 8 neighbours
"""
def do_energy_transfer(grid)
    toflash = 0
    for y in (0...@ydim) do
        for x in (0...@xdim) do
            if grid[y][x].between?(10,100)
                # self can flash only once, so put it outside normal range
                grid[y][x] = 999
                # increase all neighbours
                nbs = [
                    [-1,-1], [0,-1], [1,-1],
                    [-1, 0],         [1, 0],
                    [-1, 1], [0, 1], [1, 1]
                ]
                for (dx,dy) in nbs do
                    # receive energy
                    if (x+dx).between?(0,@xdim-1) && (y+dy).between?(0,@ydim-1)
                        grid[y+dy][x+dx] += 1
                        if grid[y+dy][x+dx] > 9
                            toflash += 1
                        end
                    end
                end
            end
        end
    end
    [grid, toflash]
end

"""
Reset to 0 those cells that have flashed
"""
def do_reset_flashers(grid)
    flashcount = 0
    for y in (0...@ydim) do
        for x in (0...@xdim) do
            if grid[y][x] >= 999
                grid[y][x] = 0
                flashcount += 1
            end
        end
    end
    [grid, flashcount]
end

"""
Do 1 full step on the grid: boost, energy transfers, reset
"""
def do_step(grid)
    # boost grid by 1
    grid = do_simple_boost(grid)
    # make >9s flash
    flashcount = 0
    toflash = grid.flatten.count{ |c| c.between?(10,100)  }
    while toflash > 0
        (grid, toflash) = do_energy_transfer(grid)
    end
    # reset to 0 any cell which has flashed
    (grid, newflashcount) = do_reset_flashers(grid)
    flashcount += newflashcount
    [grid, flashcount]
end

"""
Cycle 100 steps and count all flashes
"""
def part1
    # deep clone input grid
    grid = @grid.dup.map(&:dup)

    flashcount = 0
    100.times do
        (grid, newflashcount) = do_step(grid)
        flashcount += newflashcount
    end
    flashcount
end

"""
Cycle until all cells flash in unison
"""
def part2
    # deep clone input grid
    grid = @grid.dup.map(&:dup)

    step = 0
    while true
        step += 1
        (grid, newflashed) = do_step(grid)
        break if newflashed == @area # every cell just flashed
    end
    step
end

p "Part 1: #{part1}" # 1713
p "Part 2: #{part2}" # 502
