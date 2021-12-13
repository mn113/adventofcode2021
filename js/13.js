const fs = require('fs');

const data = fs.readFileSync('../inputs/input13.txt', 'utf-8');
const lines = data.split("\n");

const p = console.log;

let points = [];
let pointset = new Set();
const folds = [];

lines.forEach(line => {
    if (line.indexOf(',') > 0) {
        points.push(line.split(',').map(d => parseInt(d, 10)));
    }
    else if (line.startsWith('fold')) {
        const eq = line.substr(11).split('=');
        folds.push([eq[0], parseInt(eq[1], 10)]);
    }
});

/**
 * Fold the points up, bottom to top, along line x = fx
 */
function foldX(fx, pts) {
    return pts.map(([px,py]) => {
        if (px > fx) {
            return [fx - (px - fx), py];
        }
        else {
            return [px,py];
        }
    });
}

/**
 * Fold the points across, right to left, along line y = fy
 */
function foldY(fy, pts) {
    return pts.map(([px,py]) => {
        if (py > fy) {
            return [px, fy - (py - fy)];
        }
        else {
            return [px,py];
        }
    });
}

const folders = {
    x: foldX,
    y: foldY
};

// first fold
const ff = folds.shift();
points = folders[ff[0]](ff[1], points);
pointset = new Set(points.map(pt => pt.toString()));
p("Part 1:", pointset.size); // 701

// remaining folds
folds.forEach(([fdir, fval]) => {
    points = folders[fdir](fval, points);
});

pointset = new Set(points.map(pt => pt.toString()));

// printout
let output = '';
for (let y = 0; y <= 5; y++) {
    for (let x = 0; x <= 40; x++) {
        output += pointset.has([x,y].toString()) ? '▓' : ' ';
    }
    output += '\n';
}
p("Part 2:");
p(output); // FPEKBEJL
