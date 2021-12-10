#!/usr/bin/env ruby

"""
Repeatedly remove all consecutive pairs (), [], {}, <> from sequence
"""
def cleanup(line)
    linecopy = line.dup
    # brute force pair replacement
    10.times do
        linecopy = linecopy.gsub('()', '').gsub('[]', '').gsub('{}', '').gsub('<>', '')
    end

    # all consumed -> valid line
    if linecopy.length == 0
        [linecopy, 'valid']
    # just openers remain -> incomplete line
    elsif /^[\(\[\{\<]+$/.match(linecopy)
        [linecopy, 'incomplete']
    # intruder -> corrupted line
    else
        [linecopy, 'corrupted']
    end
end

@input = File.open("../inputs/input10.txt", "r").each_line.map(&:chomp).map{ |l| cleanup(l) }

"""
Get the score of the first closing char in sequence
"""
def first_closing_char_score(str)
    ill = 0
    str.chars.each do |c|
        case c
            when ')' then ill = 3
            when ']' then ill = 57
            when '}' then ill = 1197
            when '>' then ill = 25137
            else next
        end
        break if ill > 0
    end
    ill
end

"""
Mirror a sequence made of opening brackets
"""
def autocomplete(str)
    str.reverse.gsub('(',')').gsub('[',']').gsub('{','}').gsub('<','>')
end

"""
Compute the score of a closing sequence
"""
def score(str)
    score = 0
    str.chars.each do |c|
        score *= 5
        score += case c
            when ')' then 1
            when ']' then 2
            when '}' then 3
            when '>' then 4
        end
    end
    score
end

"""
Count and score the first invalid chars in corrupt input lines
"""
def part1
    scores = @input.map do |line|
        (lineremains, status) = line
        if status == 'corrupted'
            first_closing_char_score(lineremains)
        end
    end
    scores.reject(&:nil?).reduce(:+)
end

"""
Score the completion sequences of incomplete input lines
"""
def part2
    scores = @input.map do |line|
        (lineremains, status) = line
        if status == 'incomplete'
            score(autocomplete(lineremains))
        end
    end
    scores = scores.reject(&:nil?)
    scores.sort.drop(scores.size.div(2)).first
end

p "Part 1: #{part1}" # 193275
p "Part 2: #{part2}" # 2429644557
