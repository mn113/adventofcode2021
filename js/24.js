const p = console.log;

// Instructions from input occur in repeating blocks of 17
function buildBlockAlgo(zDivVal, xAddVal, yAddVal) {
    return function(z) {
        let w, x, y;
        return function(input) {
            // 1:
            w = input;
            // 2-4:
            x = z % 26;
            // 5:
            z = Math.floor(z / zDivVal);
            // 6:
            x += xAddVal;
            // 7-8:
            x = x === w ? 0 : 1;
            // 9-12:
            y = 25 * x + 1;
            // 13:
            z *= y;
            // 14-15:
            y = w + yAddVal;
            // 16:
            y *= x
            // 17:
            z += y
            return z;
        };
    };
}

const stages = [
    buildBlockAlgo(1, 10, 13),
    buildBlockAlgo(1, 13, 10),
    buildBlockAlgo(1, 13, 3),
    buildBlockAlgo(26, -11, 1),
    buildBlockAlgo(1, 11, 9),
    buildBlockAlgo(26, -4, 3),
    buildBlockAlgo(1, 12, 5),
    buildBlockAlgo(1, 12, 1),
    buildBlockAlgo(1, 15, 0),
    buildBlockAlgo(26, -2, 13),
    buildBlockAlgo(26, -5, 7),
    buildBlockAlgo(26, -11, 15),
    buildBlockAlgo(26, -13, 12),
    buildBlockAlgo(26, -10, 8)
];

const maxDigits = Array(14).fill(0);
const minDigits = Array(14).fill(0);

// Find digit pairs d1 & d2 which will push and pop to the z-stack, leaving z empty
function runPairOfStages(i, j) {
    const DIGITS = "ABCDEFGHIJKLMNOP";
    p(`Pair ${DIGITS[i]}-${DIGITS[j]}:`);
    let solutions = [];
    for (let d1 = 1; d1 <= 9; d1++) {
        let z0 = 0;
        let z1 = stages[i](z0)(d1);
        for (let d2 = 1; d2 <= 9; d2++) {
            let z2 = stages[j](z1)(d2);
            if (z0 === z2) {
                solutions.push([d1,d2]);
            }
        }
    }
    p(`  solutions: ${JSON.stringify(solutions)}`);
    minDigits[i] = solutions[0][0];
    minDigits[j] = solutions[0][1];
    maxDigits[i] = solutions[solutions.length - 1][0];
    maxDigits[j] = solutions[solutions.length - 1][1];
}

// Find digit pairs satisfying module pairs
runPairOfStages(2,3);
runPairOfStages(4,5);
runPairOfStages(8,9);
runPairOfStages(7,10);
runPairOfStages(6,11);
runPairOfStages(1,12);
runPairOfStages(0,13);

p(`Part 1: ${maxDigits.join("")}`); // 69914999975369
p(`Part 2: ${minDigits.join("")}`); // 14911675311114
