#! /usr/bin/env python3

import re

board_dimension = 5

def read_input():
    with open('../inputs/input04.txt') as fp:
        lines = fp.readlines()
        balls = None
        board = None
        boards = []
        for line in lines:
            line = line.strip()
            # set the draw list from the first line
            if not balls:
                balls = [int(d) for d in line.split(',')]
            # blank line = new board
            elif len(line) == 0:
                board = []
            # remaining lines go to board rows
            else:
                board.append([(int(d), True) for d in re.split(r'\s+', line)])
                if len(board) == board_dimension:
                    boards.append(board)

        return (balls, boards)

def mark_number(num, boards):
    for x in range(len(boards)):
        if boards[x]:
            for y in range(len(boards[x])):
                for z in range(len(boards[x][y])):
                    if boards[x][y][z][0] == num:
                        boards[x][y][z] = (num, False)
    return boards

def check_winning_row(board):
    for row in board:
        if len([1 for cell in row if cell[1] == True]) == 0:
            return True
    return False

def check_winning_col(board):
    for i in range(4):
        col = [row[i] for row in board]
        if len([1 for cell in col if cell[1] == True]) == 0:
            return True
    return False

def check_winning_board(board):
    return check_winning_row(board) or check_winning_col(board)

def check_all_boards(boards):
    winners = []
    for b in range(len(boards)):
        board = boards[b]
        if board and check_winning_board(board):
            winners.append(b)
    return winners

def print_board(board):
    for row in board:
        print(row)
    print("\n")

def score_board(board):
    return sum([sum([cell[0] for cell in row if cell[1] == True]) for row in board])

"""
Mark numbers on bingo boards until first winning line is found on a board
"""
def part1():
    (balls, boards) = read_input()
    print(len(balls), "balls,", len(boards), "boards\n")

    n = 0
    winners = []
    score = 0
    while len(winners) == 0:
        ball = balls[n]
        boards = mark_number(ball, boards)
        winners = check_all_boards(boards)
        if len(winners) > 0:
            score = score_board(boards[winners[0]]) * ball
            print("BALL:", ball)
            print("P1:", score, "\n")
        n += 1

"""
Mark numbers on bingo boards until last winning board is found
"""
def part2():
    (balls, boards) = read_input()
    print(len(balls), "balls,", len(boards), "boards\n")

    n = 0
    all_winners = []
    score = 0
    while n < len(balls) and len(all_winners) < len(boards):
        ball = balls[n]
        boards = mark_number(ball, boards)
        new_winners = check_all_boards(boards)
        if len(new_winners):
            all_winners.extend(new_winners)
            if len(all_winners) == len(boards):
                last_winner = boards[all_winners[-1]]
                score = score_board(last_winner) * ball
                print("BALL:", ball)
                print("P2:", score, "\n")
            # delete winning boards
            for w in new_winners:
                boards[w] = None
        n += 1

part1() # 4662
part2() # 12080