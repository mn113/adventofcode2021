#! /usr/bin/env python3

import re

class Scanner:
    variations = [] # precompute and store beacons x24 ?

    def __init__(self, id, beacons = [], rotX = 0, rotY = 0, rotZ = 0, flipped = False):
        self.id = id
        self.beacons = beacons
        # default orientation
        self.rotX = rotX
        self.rotY = rotY
        self.rotZ = rotZ
        self.flipped = flipped

    def __str__(self):
        return "SCN {}\n".format(self.id) + str(self.beacons) + "\n"

    def addBeacon(self, line):
        self.beacons.append([int(d) for d in line.split(",")])

    def components(self, index):
        return sorted([bcn[index] for bcn in self.beacons])

    def rotate(self, rotmask):
        return [[rotmask[i] * bcn[i] for i in range(3)] for bcn in self.beacons]

    def rotateX(self, n = 0):
        rotmask = [(1,1,1), (1,-1,1), (1,-1,-1), (1,1,-1)][n % 4]
        return self.rotate(rotmask)

    def rotateY(self, n):
        rotmask = [(1,1,1), (-1,1,1), (-1,1,-1), (1,1,-1)][n % 4]
        return self.rotate(rotmask)

    def rotateZ(self, n):
        rotmask = [(1,1,1), (-1,1,1), (-1,-1,1), (1,-1,1)][n % 4]
        return self.rotate(rotmask)

    def flip(self):
        return [[-1 * d for d in bcn] for bcn in self.beacons]

def flip(numbers):
    return [-1 * n for n in numbers]

def deltas(seq):
    return [seq[i+1] - seq[i] for i in range(len(seq)-1)]

def check_12_overlaps(seq1, seq2):
    #    [a,b,c,.....][a,b,c,.....]
    # <--i--> [.....,x,y,z]
    # i = 0,1,2,3,.....
    # both seqs must be sorted ascending before deltas comparison
    seq1_deltas = deltas(sorted(seq1))
    seq2_deltas = deltas(sorted(seq2))
    seq1_deltas_twice = seq1_deltas + seq1_deltas
    overlap_indices = len(seq2_deltas) - 11
    for i in range(len(seq1_deltas)):
        for j in range(overlap_indices):
            if seq1_deltas_twice[i:i+11] == seq2_deltas[i+j:i+j+11]:
                #print('MATCH', seq1_deltas_twice[i:i+11])
                return True
    return False

scanners = []

# Load data:
with open('../inputs/diag19.txt') as fp:
    scanner = None
    beacons = []
    for line in fp.readlines() + ['last']:
        if line.startswith("---"):
            id = line.split(' ')[2]
            scanner = Scanner(id)
        elif re.search(r',', line):
            scanner.addBeacon(line.strip())
        else:
            scanners.append(scanner)
            scanner = None

# print(scanners[0])
# print(scanners[0].rotateX(1))
# print(scanners[0].rotateY(2))
# print(scanners[0].rotateZ(3))
# print(scanners[0].rotateZ(0))

# try combinations
for i in range(5):
    for j in range(i+1,5):
        for s1_compo in [0,1,2]:
            for s2_compo in [0,1,2]:
                sc1 = scanners[i]
                sc2 = scanners[j]
                seq1 = sc1.components(s1_compo)
                seq2 = sc2.components(s2_compo)
                seq2flip = flip(seq2)
                check1 = check_12_overlaps(seq1, seq2)
                check2 = check_12_overlaps(seq1, seq2flip)
                if check1:
                    print(
                        "SCN {}".format(sc1.id),
                        "xyz"[s1_compo],
                        "SCN {}".format(sc2.id),
                        "xyz"[s2_compo],
                        check1
                    )
                if check2:
                    print(
                        "SCN {}".format(sc1.id),
                        "xyz"[s1_compo],
                        "SCN {}".format(sc2.id),
                        "xyz"[s2_compo],
                        "Flipped",
                        check2
                    )
