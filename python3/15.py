#! /usr/bin/env python3

# Load maze file into nested array:
with open('../inputs/input15.txt') as fp:
    grid = [[int(char) for char in line_str.strip()] for line_str in fp.readlines()]
xdim = ydim = len(grid) - 1

def grid_val(coords):
    (x,y) = coords
    return grid[y][x]

def manhattan_dist(a,b):
    return abs(a[0] - b[0]) + abs(a[1] - b[1])

# Return valid points of [down, left, up, right] from given point (x,y)
def neighbours(point):
    (x,y) = point
    up    = (x, max(y-1, 0))
    down  = (x, min(y+1, ydim))
    left  = (max(x-1, 0), y)
    right = (min(x+1, xdim), y)
    # nb must not be x,y
    return [nb for nb in [down, left, up, right] if not (nb[0] == x and nb[1] == y)]

# Main algo: Dijkstra / BFS
# Finds lowest cost path from start to goal. Visits all points in grid, storing and updating cost to reach each one.
def dijkstra(start, goal):
    lowest_cost_to = {start: 0} # measures cumulative cost from start to each node; keys function as "seen" list
    to_visit = [start]          # list-as-queue
    came_from = {start: None}   # traces the optimal path taken
    limit = manhattan_dist(start, goal) * 3.25

    while len(to_visit) > 0:
        # re-sort nodes to visit - nearest to start comes first (to search breadth-first)
        to_visit.sort(key=lambda point: manhattan_dist(point, start))

        # shift first (lowest heuristic)
        current, to_visit = to_visit[0], to_visit[1:]
        curVal = grid_val(current)

        if current == goal:
            print('GOAL!', len(to_visit), "to see")
            # Keep searching, to guarantee shortest:

        if lowest_cost_to[current] > limit:
            # Abandon too-costly paths
            print("oops", current, lowest_cost_to[current])
            continue

        neighbs = neighbours(current)

        for nextNode in neighbs:
            nextVal = grid_val(nextNode)
            # nextNode unseen:
            if nextNode not in lowest_cost_to.keys():
                # Add to queue:
                to_visit.append(nextNode)
                # Next node will cost nextVal more than this node did:
                lowest_cost_to[nextNode] = lowest_cost_to[current] + nextVal
                came_from[nextNode] = current

            # nextNode seen before:
            else:
                if lowest_cost_to[nextNode] > lowest_cost_to[current] + nextVal:
                    # Via current, we have found a new, shorter path to nextNode:
                    lowest_cost_to[nextNode] = lowest_cost_to[current] + nextVal
                    came_from[nextNode] = current
                    to_visit.append(nextNode)

                elif lowest_cost_to[current] > lowest_cost_to[nextNode] + curVal:
                    # Via nextNode, we have found a new, shorter path to current:
                    lowest_cost_to[current] = lowest_cost_to[nextNode] + curVal
                    came_from[current] = nextNode
                    to_visit.append(current)

    if goal in came_from.keys():
        print(len(came_from.keys()), "points seen")
        print(goal, lowest_cost_to[goal])

# Repeat the grid 5 times in x, and 5 times in y
# With each repetition, the contents increment by 1 (wrapping round to 1 again after 9)
def extend_grid(grid):
    global xdim, ydim
    newgrid = []
    for ny in range(5):
        for row in grid:
            newrow = []
            for nx in range(5):
                tmprow = [d + nx + ny for d in row]
                newrow += [1 + (d % 10) if d > 9 else d for d in tmprow]
            newgrid.append(newrow)

    xdim = ydim = len(grid) - 1
    return newgrid

# part 1
dijkstra((0,0), (xdim, ydim)) # P1: 429

# part 2
grid = extend_grid(grid)
xdim = ydim = len(grid) - 1
dijkstra((0,0), (xdim, ydim)) # P2: 2844
