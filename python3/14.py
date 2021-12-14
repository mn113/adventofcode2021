#! /usr/bin/env python3

with open('../inputs/input14.txt') as fp:
    lines = [line.strip() for line in fp.readlines()]

polymer, rules = lines[0], lines[2:]

# build mappings
chr_mappings = {} # character mappings: NN -> H
ins_mappings = {} # insertion mappings: NN -> [NH, HN]
for rule in rules:
    [key, val] = rule.split(' -> ')
    chr_mappings[key] = val
    ins_mappings[key] = [key[0]+val, val+key[1]]

# track individual char counts
char_counts = {}
for i in range(len(polymer)):
    char = polymer[i]
    if not char in char_counts:
        char_counts[char] = 1
    else:
        char_counts[char] += 1

# track char-pair counts
pair_counts = {}
for i in range(len(polymer) - 1):
    pair = polymer[i:i+2]
    if not pair in pair_counts:
        pair_counts[pair] = 1
    else:
        pair_counts[pair] += 1

# Iterate one round of insertions, producing new pair_counts & updating char_counts in place
def insertion_step(pair_counts):
    new_pair_counts = pair_counts.copy()
    for (k1, v1) in pair_counts.items():
        # lose all of 1 broken-up pair
        new_pair_counts[k1] -= v1
        # gain 2 new pairs (v1 times)
        for k2 in ins_mappings[k1]:
            if not k2 in new_pair_counts:
                new_pair_counts[k2] = v1
            else:
                new_pair_counts[k2] += v1
        # count inserted char (v1 times)
        char = chr_mappings[k1]
        if not char in char_counts:
            char_counts[char] = v1
        else:
            char_counts[char] += v1
    return new_pair_counts

# Calculate (most frequent minus least frequent) in freqs dict
def calc_freq_diff(freqs):
    freq_vals_order = sorted([v for (k,v) in freqs.items()])
    return freq_vals_order[-1] - freq_vals_order[0]

# part 1
for n in range(10):
    pair_counts = insertion_step(pair_counts)
print("Part 1:", calc_freq_diff(char_counts)) # 4244

# part 2
for n in range(30):
    pair_counts = insertion_step(pair_counts)
print("Part 2:", calc_freq_diff(char_counts)) # 4807056953866
