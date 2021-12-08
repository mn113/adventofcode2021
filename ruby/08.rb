#!/usr/bin/env ruby

require 'set'

def read_input
    File.open("../inputs/input08.txt", "r")
    .each_line
    .map do |line|
        line.split('|')
        .map do | phrase |
            phrase.scan(/([a-g]+)/).flatten
        end
    end
end

"""
Find number of 1's, 4's, 7's, 8's in the input tails
"""
def part1
    all_tails = read_input.map{ |pair| pair[1] }.flatten

    ones = all_tails.select{ |t| t.length == 2 }
    fours = all_tails.select{ |t| t.length == 4 }
    sevens = all_tails.select{ |t| t.length == 3 }
    eights = all_tails.select{ |t| t.length == 7 }

    p "Part 1: #{ones.length + fours.length + sevens.length + eights.length}"
end

def normalize_word(str)
    str.chars.sort.join
end

"""
Decode the 7-segment display mapping and sum all 4-digit tails
   0:      1:      2:      3:      4:
  AAAA    ....    AAAA    AAAA    ....
 B    C  .    C  .    C  .    C  B    C
 B    C  .    C  .    C  .    C  B    C
  ....    ....    DDDD    DDDD    DDDD
 E    F  .    F  E    .  .    F  .    F
 E    F  .    F  E    .  .    F  .    F
  GGGG    ....    GGGG    GGGG    ....

   5:      6:      7:      8:      9:
  AAAA    AAAA    AAAA    AAAA    AAAA
 B    .  B    .  .    C  B    C  B    C
 B    .  B    .  .    C  B    C  B    C
  DDDD    DDDD    ....    DDDD    DDDD
 .    F  E    F  .    F  E    F  .    F
 .    F  E    F  .    F  E    F  .    F
  GGGG    GGGG    ....    GGGG    GGGG
"""
def part2
    scores = read_input.map do |pair|
        all = pair.flatten.map{ |s| normalize_word(s) }.to_set.to_a

        one = all.select{ |t| t.length == 2 }[0]
        four = all.select{ |t| t.length == 4 }[0]
        seven = all.select{ |t| t.length == 3 }[0]
        eight = all.select{ |t| t.length == 7 }[0]

        two_three_five = all.select{ |t| t.length == 5 }
        # 3 contains all segments of 1
        three = two_three_five.select{ |word| one.chars.all? { |x| word.include? x } }[0]
        two_five = two_three_five.delete_if{ |word| word == three }
        # 5 has 3 segments matching 4
        five = two_five.select{ |word| word.chars.select{ |x| four.include? x }.count == 3 }[0]
        two = two_five.delete_if{ |word| word == five }[0]

        six_nine_zero = all.select{ |t| t.length == 6 }
        # 9 contains all segments of 3
        nine = six_nine_zero.select{ |word| three.chars.all? { |x| word.include? x } }[0]
        six_zero = six_nine_zero.delete_if{ |word| word == nine }
        # 6 contains all segments of 5
        six = six_zero.select{ |word| five.chars.all? { |x| word.include? x } }[0]
        zero = six_zero.delete_if{ |word| word == six }[0]

        digits = [zero, one, two, three, four, five, six, seven, eight, nine]
        mapping = digits.zip('0123456789'.chars).to_h

        pair[1]
        .map{ |word| normalize_word(word) }
        .map{ |word| mapping[word] }
        .join
        .to_i
    end
    p "Part 2: #{scores.reduce(:+)}"
end

part1 # 245
part2 # 983026