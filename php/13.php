<?php

$inputFile = '../inputs/input13.txt';
$data = file($inputFile);
// $lines = explode('\n', $data);

$points = [];
$pointset = [];
$folds = [];

foreach($data as $line) {
    if (strpos($line, ',') > 0) {
        $points[] = array_map(
            function($d) { return intval($d); },
            explode(',', $line)
        );
    }
    else if (strpos($line, 'fold') === 0) {
        $eq = explode('=', substr($line, 11));
        $folds[] = [$eq[0], intval($eq[1])];
    }
}

/**
 * Fold the points up, bottom to top, along line x = fx
 */
function foldX($fx, $pts) {
    return array_map(
        function ($pt) use ($fx) {
            $px = $pt[0];
            $py = $pt[1];
            if ($px > $fx) {
                return [$fx - ($px - $fx), $py];
            }
            else {
                return [$px,$py];
            }
        },
        $pts
    );
}

/**
 * Fold the points across, right to left, along line y = fy
 */
function foldY($fy, $pts) {
    return array_map(
        function ($pt) use ($fy) {
            $px = $pt[0];
            $py = $pt[1];
            if ($py > $fy) {
                return [$px, $fy - ($py - $fy)];
            }
            else {
                return [$px,$py];
            }
        },
        $pts
    );
}

// first fold
$ff = array_shift($folds);
$points = foldX($ff[1], $points);
foreach ($points as $point) {
    $strpt = implode('_', $point);
    if (!in_array($strpt, $pointset)) {
        $pointset[] = $strpt;
    }
}
echo "Part 1: " . count($pointset) . PHP_EOL; // 701

// remaining folds
foreach($folds as $fold) {
    $fdir = $fold[0];
    $fval = $fold[1];
    if ($fdir === 'x') {
        $points = foldX($fval, $points);
    }
    else {
        $points = foldY($fval, $points);
    }
}
$pointset = [];
foreach ($points as $point) {
    $strpt = implode('_', $point);
    if (!in_array($strpt, $pointset)) {
        $pointset[] = $strpt;
    }
}

// printout
$output = '';
for ($y = 0; $y <= 5; $y++) {
    for ($x = 0; $x <= 40; $x++) {
        $strpt = implode('_', [$x,$y]);
        $output .= in_array($strpt, $pointset) ? '▓' : ' ';
    }
    $output .= PHP_EOL;
}
echo "Part 2:" . PHP_EOL;
echo $output; // FPEKBEJL
