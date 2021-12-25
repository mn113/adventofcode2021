#! /usr/bin/env python3

# Load maze file into nested array:
with open('../inputs/input25.txt') as fp:
    grid = [list(line.strip()) for line in fp.readlines()]
ydim = len(grid)
xdim = len(grid[0])

SYMBOLS = { 'east': '>', 'south': 'v', 'empty': '.'}

# Look up which coords a mover wants to move to
def target_cell(coords, type):
    (x, y) = coords
    if type == SYMBOLS['east']:
        return ((x + 1) % xdim, y)
    elif type == SYMBOLS['south']:
        return (x, (y + 1) % ydim)

# Prepare the new grid after moving all of one type of symbol
def move_all_facers(grid, type):
    # Count how many moved:
    moves = 0
    # Pre-fill with empties
    grid1 = [[SYMBOLS['empty'] for _x in range(xdim)] for _y in range(ydim)]
    # Map movers into grid1
    for y in range(ydim):
        for x in range(xdim):
            if grid[y][x] == type:
                (tx, ty) = target_cell((x,y), type)
                if grid[ty][tx] == SYMBOLS['empty']:
                    # Make move
                    grid1[ty][tx] = type
                    grid1[y][x] = SYMBOLS['empty']
                    moves += 1
                else:
                    # Stay put
                    grid1[y][x] = type
    # Current movers all changed in grid from symbol to dot, in grid1 from dot to symbol
    # Now backfill all non-movers:
    for y in range(ydim):
        for x in range(xdim):
            if grid[y][x] != type and grid1[y][x] != type:
                grid1[y][x] = grid[y][x]
    return (grid1, moves)

def pgrid(grid):
    for row in grid:
        print("".join(row))
    print("---")

# Do one step, moving all the symbols that have a space to move into
def step(grid):
    # East moves first, then South
    (grid, east_moves) = move_all_facers(grid, SYMBOLS['east'])
    # pgrid(grid)
    (grid, south_moves) = move_all_facers(grid, SYMBOLS['south'])
    # pgrid(grid)
    return (grid, east_moves + south_moves)

# How many steps before grid reaches a settled state?
steps = 0
while 1:
    steps += 1
    # print("Step {}".format(steps))
    (grid, moves) = step(grid)
    if moves == 0:
        break

print("Part 1:", steps)
