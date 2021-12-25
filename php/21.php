<?php

// globals
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



function advance($pos, $roll) {
    $pos += $roll;
    if ($pos > 10) {
        $pos = 1 + ($pos - 1) % 10;
    }
    return $pos;
}

print(advance(1,9));
print(advance(5,5));
print(advance(5,6));
print(advance(9,9));
print(EOF);

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

    // incomplete
    // nested keys represent: turn => p1score => p2score => p1pos => p2pos
    // value: games count
    $initialstate = [0 => [0 => [0 => [4 => [8 => 1]]]]];
    $gamestates = $initialstate;
    // completed
    $p1games = 0;
    $p2games = 0;

    $player = 0;
    $rounds = 0;
    while ($rounds < 10) {
        $rounds++;
        echo "-ROUND $rounds\n";
        foreach ($quantum_diceroll_frequencies as $roll => $freq) {
            //echo " -ROLL $roll\n";
            //echo " - " . count($gamestates) . " gamestates\n";
            foreach ($gamestates as $turn => $state0) {
                // take turns viewing half of all gamestates
                if ($turn !== $player) continue;
                //echo "  -TURN $turn\n";
                $nextTurn = ($turn + 1) % 2;

                foreach ($state0 as $p => $state1) {
                    foreach ($state1 as $q => $state2) {
                        foreach ($state2 as $s => $state3) {
                            // ignore completed games
                            if ($s >= 21) continue;
                            foreach ($state3 as $t => $count) {
                                // ignore completed games
                                if ($t >= 21) continue;
                                //echo "   -STATE $p-$q $s-$t\n";

                                // unset old count - this state is history
                                // $gamestates[$turn][$p][$q][$s][$t] = 0;

                                // update current player's pos & score
                                if ($turn == 0) {
                                    $p = advance($p, $roll);
                                    $s += $p;
                                    // log won games
                                    if ($s >= 21) {
                                        //echo "   -victorious winner is p1 $s-$t\n";
                                        $p1games += $count + $freq;
                                        // add new blank game
                                        $gamestates = array_merge_recursive($gamestates, $initialstate);
                                        continue;
                                    }
                                } else {
                                    $q = advance($q, $roll);
                                    $t += $q;
                                    // log won games
                                    if ($t >= 21) {
                                        //echo "   -game won by p2 $s-$t\n";
                                        $p2games += $count + $freq;
                                        // add new blank game
                                        $gamestates = array_merge_recursive($gamestates, $initialstate);
                                        //print_r($gamestates);
                                        continue;
                                    }
                                }

                                // store new count
                                if (!$gamestates[$nextTurn][$p]) $gamestates[$nextTurn][$p] = [];
                                if (!$gamestates[$nextTurn][$p][$q]) $gamestates[$nextTurn][$p][$q] = [];
                                if (!$gamestates[$nextTurn][$p][$q][$s]) $gamestates[$nextTurn][$p][$q][$s] = [];

                                if (!$gamestates[$nextTurn][$p][$q][$s][$t]) {
                                    $gamestates[$nextTurn][$p][$q][$s][$t] = $freq;
                                } else {
                                    $gamestates[$nextTurn][$p][$q][$s][$t] = $count + $freq;
                                }
                                //echo "    -stored [$nextTurn][$p][$q][$s][$t] ". ($count + $freq) . " games\n";
                            }
                        }
                    }
                }
            }
            // play passes
            $player = $nextTurn;
        }
    }
    // print_r($gamestates);
    echo "$p1games $p2games";
}
play_quantum_game();
