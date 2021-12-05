<?php

$inputFile = '../inputs/input05.txt';
$data = file($inputFile);

$data = array_map(function($line) {
    preg_match("/(?<x1>\d+),(?<y1>\d+) -> (?<x2>\d+),(?<y2>\d+)/", $line, $m);
    $matches = [$m['x1'], $m['y1'], $m['x2'], $m['y2']];
    return array_map(
        function ($x) { return intval($x); },
        $matches
    );
}, $data);

function expand_line($coords, $opts) {
    [$x1, $y1, $x2, $y2] = $coords;

    $xrange = range($x1, $x2);
    $yrange = range($y1, $y2);

    // horizontal
    if ($x1 == $x2) {
        return array_map(
            function ($y) use ($x1) { return [$x1, $y];},
            $yrange
        );
    }
    // vertical
    else if ($y1 === $y2) {
        return array_map(
            function ($x) use ($y1) { return [$x, $y1];},
            $xrange
        );
    }
    // diagonals allowed
    else if ($opts['allow_diagonals']) {
        $zipped = [];
        for ($i = 0; $i < count($xrange); $i++) {
            $zipped[] = [$xrange[$i], $yrange[$i]];
        }
        return $zipped;
    }
    // diagonals ignored
    else {
        return [];
    }
}

function count_hotspots($data, $opts) {
    $expanded_lines = array_map(
        function($line) use ($opts) { return expand_line($line, $opts); },
        $data
    );
    $expanded_points = array_merge(...$expanded_lines);
    $point_strings = array_map(
        function ($point) { return implode('_', $point); },
        $expanded_points
    );
    $counts = array_count_values($point_strings);
    $hotspots = array_filter(
        $counts,
        function($v) { return $v > 1; }
    );
    return count($hotspots);
}

// part 1
$n1 = count_hotspots($data, ['allow_diagonals' => false]);
print "P1: $n1\n";

// part 2
$n2 = count_hotspots($data, ['allow_diagonals' => true]);
print "P2: $n2\n";
