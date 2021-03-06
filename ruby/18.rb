#!/usr/bin/env ruby

def read_input
    File.open("../inputs/input18.txt", "r").each_line.map{ |l| l.chomp }
end

# Replace portion of string at a given index/length with replacement
def replace(str, idx, len, replacement)
    # underscore trick to replace len chars with more or fewer
    tmp = '_' * len
    str[idx,len] = tmp
    str.insert(idx, replacement)
    str.sub!(tmp, '')
end

# Find first [?,?] pair nested more than 4 levels deep
def first_explode_index(str)
    idx = nil
    depth = 0
    str.each_char.with_index do |c,i|
        case c
        when ']' then depth -= 1
        when '[' then
            depth += 1
            # got to be deep and match [m,n]
            if depth > 4 and str.slice(i..-1) =~ /^\[\d+,\d+\]/
                idx = i
                break
            end
        end
    end
    idx
end

# Deeply nested pair [m,n] must be removed.
# - m added to nearest left neighbour ww (or removed)
# - n added to nearest right neighbour zz (or removed)
def explode_at(str, idx)
    # str: 01 ... [2,3] ... 14
    # ids: ww ... xm,ny ... zz
    max_id = str.length - 1
    idy = idx
    idy += 1 until str[idy] == ']'
    #p "explode at #{idx} : #{str[idx..idy]}"
    (m,n) = eval(str[idx..idy]) # match [1,2] or [12,13]
    # seek left from bracket x to find number w (may be 1 or 2 digits)
    idw = idx
    idw -= 1 until str[idw] =~ /\d/ or idw == 0 # 1st char
    idw -= 1 if idw > 0 and str[idw-1] =~ /\d/ # 2nd char
    w = str[idw]
    w += str[idw+1] if str[idw+1] =~ /\d/
    wlen = w.length # 1 or 2
    w = w.to_i
    # seek right from bracket y to find number z (may be 1 or 2 digits)
    idz = idy
    idz += 1 until str[idz] =~ /\d/ or idz == max_id
    z = str[idz]
    z += str[idz+1] if str[idz+1] =~ /\d/
    zlen = z.length # 1 or 2
    z = z.to_i

    # update numerics and delete exploded pair x..y - replacements can modify length so must be done from last to first
    if idz < max_id
        str = replace(str, idz, zlen, (z + n).to_s)
    end
    str = replace(str, idx, idy - idx + 1, '0')
    if idw > 0
        str = replace(str, idw, wlen, (w + m).to_s)
    end
    str
end

# Multi-digit number gets halved and rounded down/up - becomes [m,n]
def split_at(str, idx)
    num = str[idx,2].to_i # always 2-digit?
    m = (num / 2).floor
    n = num - m
    str = replace(str, idx, 2, "[#{m},#{n}]")
end

# Continuously explode or split first matching term, until no terms match
def simplify(str)
    while true do
        explode_idx = first_explode_index(str)
        split_idx = str.index(/\d\d/)

        if explode_idx
            str = explode_at(str, explode_idx)
        elsif split_idx
            str = split_at(str, split_idx)
        else
            break
        end
    end
    str
end

# Reduce list of inputs to final simplified number list
def sum_list(list)
    result = list.reduce{ |acc,str|
        sum = "[#{acc},#{str}]"
        simplify(sum)
    }
end

# Convert number list to integer from inside out according to rules
def magnitude(str)
    while str.start_with?('[') do
        str.gsub!(/\[(\d+),(\d+)\]/) do |_|
            (($1.to_i * 3) + ($2.to_i * 2)).to_s
        end
    end
    str.to_i
end

input = read_input()

p "Part 1: #{magnitude(sum_list(input))}" # 4289

# Maximum magnitude of 2 number sum: A + B or B + A
max = 0
input.permutation(2).each do |pair|
    magn = magnitude(sum_list(pair))
    max = magn if magn > max
end
p "Part 2: #{max}" # 4807
