#!/usr/bin/env ruby

@sym2int = {'#' => 1, '.' => 0}

def read_input
    input = File.open("../inputs/input20.txt", "r").each_line.map{ |l| l.chomp }
    algo = input[0]
    image = input.drop(2)
    [algo, image]
end

# Add an empty border to the image on sides which aren't empty
def surround_by_where_needed(image, char)
    opp_char = char == "#" ? "." : "#"
    needs_top = image[0].include?(opp_char)
    needs_bot = image[-1].include?(opp_char)
    prefix = image.any?{ |row| row.start_with?(opp_char) } ? char : ""
    suffix = image.any?{ |row| row.end_with?(opp_char) } ? char : ""

    image.map!{ |row| prefix + row + suffix }
    newrow = char * image[0].size
    if (needs_top)
        image = [newrow] + image
    end
    if (needs_bot)
        image += [newrow]
    end
    image
end

# Add an empty border to the image on all sides
def surround_by_all_sides(image, char)
    newrow = char * (image[0].size + 2)
    [newrow] + image.map{ |row| char + row + char } + [newrow]
end

# Get the binary number based on the 3x3 grid around a point
def read_cell_value(image, x,y)
    [-1,0,1]
    .map{ |d| image[y+d][x-1, 3] }
    .join
    .chars
    .map{ |c| @sym2int[c] }
    .join
    .to_i(2)
end

# Map all non-border cells of the image onto a new, slightly smaller image
def enhance(image, algo)
    ydim = image.size
    xdim = image[0].size
    new_image = []
    for y in (1..ydim-2) do
        new_row = []
        for x in (1..xdim-2) do
            b = read_cell_value(image, x, y)
            new_row.push(algo[b])
        end
        new_image.push(new_row.join)
    end
    new_image
end

# Surround image 2 to 3 times !!! so all the cells - inner and outer - can be safely processed
def surround_generously(image, char)
    image = surround_by_where_needed(image, char)
    image = surround_by_all_sides(image, char)
    image = surround_by_all_sides(image, char)
end

def do_loop(n)
    @image = surround_generously(@image, n % 2 == 0 ? "." : "#")
    @image = enhance(@image, @algo)
end

# Start here
(@algo, @image) = read_input()

2.times{ |n| do_loop(n) }

p "Part 1: #{@image.join.count '#'}" # 5044

48.times{ |n| do_loop(n+2) }

p "Part 2: #{@image.join.count '#'}" # 18074
