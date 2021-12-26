<?php

// P1 globals
$positions = [7,1];
$scores = [0,0];
$nextNum = 0;

function roll3nums() {
    global $nextNum;
    $d1 = (($nextNum++) % 100) + 1;
    $d2 = (($nextNum++) % 100) + 1;
    $d3 = (($nextNum++) % 100) + 1;
    return $d1 + $d2 + $d3;
}

function take_turn($player) {
    global $positions, $scores;
    $positions[$player] = $positions[$player] + roll3nums();
    if ($positions[$player] > 10) {
        $positions[$player] = 1 + ($positions[$player] - 1) % 10;
    }
    $scores[$player] += $positions[$player];
}

$rolls = 0;
$nextPlayer = 0;
while ($scores[0] < 1000 && $scores[1] < 1000) {
    take_turn($nextPlayer);
    $rolls += 3;
    $nextPlayer = ($nextPlayer + 1) % 2;
}

$product = $rolls * min($scores);
echo "Part 1: $product" . PHP_EOL;

/*****************/

function advance($pos, $roll) {
    $pos += $roll;
    if ($pos > 10) {
        $pos = 1 + ($pos - 1) % 10;
    }
    return $pos;
}

function play_quantum_game() {
    # 27 dice roll outcomes for {1,2,3}*{1,2,3}*{1,2,3}
    # 333 = 9 x 1
    # 332 = 8 x 3
    # 322 = 7 x 3
    # 331 = 7 x 3
    # 321 = 6 x 6
    # 222 = 6 x 1
    # 311 = 5 x 3
    # 221 = 5 x 3
    # 211 = 4 x 3
    # 111 = 3 x 1
    $quantum_diceroll_frequencies = [
        9 => 1,
        8 => 3,
        7 => 6,
        6 => 7,
        5 => 6,
        4 => 3,
        3 => 1
    ];
    $winning_score = 21;

    // nested keys represent: turn => p1pos => p2pos => p1score => p2score
    // final value: count of active games in this state
    $initialstate = [0 => [7 => [1 => [0 => [0 => 1]]]]];
    $gamestates = $initialstate;
    // completed counters
    $p1games = 0;
    $p2games = 0;

    $rounds = 0;
    while ($rounds <= 21) {
        $rounds++;
        // echo "-ROUND $rounds\n";
        $turn = ($rounds - 1) % 2;
        $nextTurn = $rounds % 2;
        $state0 = $gamestates[$turn];
        if (!$state0) continue;

        foreach ($state0 as $p => $state1) {
            foreach ($state1 as $q => $state2) {
                foreach ($state2 as $s => $state3) {
                    // ignore completed games
                    if ($s >= 21) continue;
                    foreach ($state3 as $t => $count) {
                        // ignore completed games
                        if ($t >= 21) continue;
                        // echo "  -STATE pos $p-$q sco $s-$t games $count\n"; // these values musn't be changed in this loop
                        // roll all dice combinations
                        foreach ($quantum_diceroll_frequencies as $roll => $freq) {
                            // echo "   -ROLL $roll\n";
                            $newfreq = $count * $freq;
                            // update current player's pos & score
                            if ($turn == 0) {
                                $p1 = advance($p, $roll);
                                $q1 = $q;
                                $s1 = $s + $p1;
                                $t1 = $t;
                            } else {
                                $p1 = $p;
                                $q1 = advance($q, $roll);
                                $s1 = $s;
                                $t1 = $t + $q1;
                            }
                            // log won games
                            if ($s1 >= $winning_score) {
                                // echo "   -victorious winner is p1 $s1-$t1. gains $newfreq games\n";
                                $p1games += $newfreq;
                                continue;
                            } else if ($t1 >= $winning_score) {
                                // echo "   -game won by p2 $s1-$t1. gains $newfreq games\n";
                                $p2games += $newfreq;
                                continue;
                            } else {
                                // game still alive
                                // store new count under next turn
                                if (!$gamestates[$nextTurn]) $gamestates[$nextTurn] = [];
                                if (!$gamestates[$nextTurn][$p1]) $gamestates[$nextTurn][$p1] = [];
                                if (!$gamestates[$nextTurn][$p1][$q1]) $gamestates[$nextTurn][$p1][$q1] = [];
                                if (!$gamestates[$nextTurn][$p1][$q1][$s1]) $gamestates[$nextTurn][$p1][$q1][$s1] = [];

                                if (!$gamestates[$nextTurn][$p1][$q1][$s1][$t1]) {
                                    $gamestates[$nextTurn][$p1][$q1][$s1][$t1] = $newfreq;
                                } else {
                                    $gamestates[$nextTurn][$p1][$q1][$s1][$t1] += $newfreq;
                                }
                                // echo "    -stored [$nextTurn][$p1][$q1][$s1][$t1] ". $gamestates[$nextTurn][$p1][$q1][$s1][$t1] . " games\n";
                            }
                        }
                        // all rolls now added, eliminate exhausted gamestate
                        unset($gamestates[$turn][$p][$q][$s][$t]);
                        if (!count($gamestates[$turn][$p][$q][$s])) {
                            unset($gamestates[$turn][$p][$q][$s]);
                        }
                        if (!count($gamestates[$turn][$p][$q])) {
                            unset($gamestates[$turn][$p][$q]);
                        }
                        if (!count($gamestates[$turn][$p])) {
                            unset($gamestates[$turn][$p]);
                        }
                        if (!count($gamestates[$turn])) {
                            unset($gamestates[$turn]);
                        }
                    }
                }
            }
        }
    }
    return max($p1games, $p2games);
}
echo "Part 2: " . play_quantum_game() . PHP_EOL;
