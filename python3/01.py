#! /usr/bin/env python3

def read_input():
    with open('../inputs/input01.txt') as fp:
        return [int(line) for line in fp.readlines()]

"""
Count the number of increasing pairs in the input list
"""
def part1():
    input = read_input()
    count = 0
    for i in range(len(input) - 1):
        if input[i] < input[i+1]:
            count += 1
    return count

"""
Count the number of times the sum of 3 consecutive elements increases in the input list
"""
def part2():
    input = read_input()
    count = 0
    for i in range(len(input) - 3):
        if input[i] < input[i+3]:
            count += 1
    return count

print(part1())
print(part2())
