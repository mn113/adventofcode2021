const fs = require('fs');
const util = require('util');

const p = console.log;
const insp = util.inspect;

const input = fs.readFileSync('../inputs/input16.txt', 'utf-8');

/**
 * Converts hexadecimal char sequence to binary
 * @param {String} hex
 * @returns {String} binary representation incl. paddings
 */
function hex2bin(hex) {
    return hex
        .split("")
        .map(h => parseInt(h, 16).toString(2).padStart(4, '0'))
        .join("");
}

/**
 * Decode the numeric value of a binary string
 * @param {String} bitstr
 * @returns {Object} {value: Integer, remainstr: String}
 */
function decode_literal(bitstr) {
    let decoded = "";
    while (bitstr.length >= 5) {
        head = bitstr.substr(0,5);
        bitstr = bitstr.substr(5);
        decoded += head.substr(1);
        if (head.startsWith(0)) {
            break;
        }
    }
    return {
        value: parseInt(decoded, 2),
        remainstr: bitstr
    };
}

/**
 * @typedef {Packet}
 * @property {Integer} version
 * @property {Integer} type
 * @property {Integer} value
 * @property {Packet[]} children
 */
class Packet {
    constructor(version, type, value) {
        this.version = version;
        this.type = type;
        this.value = value;
        this.children = [];
    }

    addChild(subpacket) {
        if (subpacket instanceof Packet) {
            this.children.push(subpacket);
        }
    }
}

/**
 * Decode a binary string and all its subpackets
 * @param {String} bitstr
 * @returns {Packet} packet hierarchy
 */
function decode_packets(bitstr, debug = false) {
    debug && p('bs', bitstr);
    let version = parseInt(bitstr.substr(0,3), 2);
    let type = parseInt(bitstr.substr(3,3), 2);
    debug && p('V', version, 'T', type);
    let value, remainstr = '';

    let pkt = new Packet(version, type)

    if (type === 4) {
        ({ value, remainstr } = decode_literal(bitstr.substr(6)));
        pkt.value = value;
        debug && p('val', value);
        debug && p('r', remainstr); // discardable for this type?
    }
    else {
        let ltid = bitstr.substr(6,1)
        let subpacketstr = '';
        debug && p('I', ltid);
        if (ltid === '0') {
            let subpacketslen = parseInt(bitstr.substr(7,15), 2);
            debug && p('L', subpacketslen);
            subpacketstr = bitstr.substr(22, subpacketslen);
            debug && p('sl', subpacketstr);
            let tail = bitstr.substr(22 + subpacketslen);
            // extract packets up to the fixed length
            while (subpacketstr.length > 0) {
                let { pkt: subpkt, remainstr: remainstr1 } = decode_packets(subpacketstr, debug);
                pkt.addChild(subpkt);
                subpacketstr = remainstr1;
            }
            remainstr = tail;
            debug && p('r1', remainstr);
        }
        else if (ltid === '1') {
            let subpacketcount = parseInt(bitstr.substr(7,11), 2);
            debug && p('C', subpacketcount);
            subpacketstr = bitstr.substr(18);
            debug && p('sc', subpacketstr);
            // extract {subpacketcount} packets before continuing
            while (subpacketcount > 0) {
                let { pkt: subpkt, remainstr: remainstr2 } = decode_packets(subpacketstr, debug);
                pkt.addChild(subpkt);
                subpacketstr = remainstr2;
                remainstr = remainstr2;
                subpacketcount--;
            }
            debug && p('r2', remainstr);
        }
    }

    return {
        pkt,
        remainstr
    };
}

/**
 * Recursively sums the versions of all packets
 * @param {Packet} pkt
 * @returns {Integer}
 */
function sum_versions(pkt) {
    let sum = pkt.version;
    if (pkt.children && pkt.children.length) {
        sum += pkt.children.reduce(
            (acc, child_pkt) => acc + sum_versions(child_pkt),
            0
        );
    }
    return sum;
}

/**
 * Recursively evaluates the value of the outermost packet
 * @param {Packet} pkt
 * @returns {Integer}
 */
function evaluate_packet_value(pkt, debug = false) {
    let res;
    switch (pkt.type) {
        case 4: // literal
        debug && p('4:', pkt.value);
            return pkt.value;

        case 0: // sum
            res = pkt.children.reduce(
                (acc, child_pkt) => acc + evaluate_packet_value(child_pkt, debug),
                0
            );
            debug && p('0/+:', res);
            return res;

        case 1: // product
            res = pkt.children.reduce(
                (acc, child_pkt) => acc * evaluate_packet_value(child_pkt, debug),
                1
            );
            debug && p('1/*:', res);
            return res;

        case 2: // min
            res = pkt.children.reduce(
                (acc, child_pkt) => {
                    let child_val = evaluate_packet_value(child_pkt, debug);
                    return child_val < acc ? child_val : acc;
                },
                Infinity
            );
            debug && p('2/min:', res);
            return res;

        case 3: // max
            res = pkt.children.reduce(
                (acc, child_pkt) => {
                    let child_val = evaluate_packet_value(child_pkt, debug);
                    return child_val > acc ? child_val : acc;
                },
                0
            );
            debug && p('3/max:', res);
            return res;

        case 5: // gt
            res = evaluate_packet_value(pkt.children[0], debug) > evaluate_packet_value(pkt.children[1], debug) ? 1 : 0;
            debug && p('5/gt:', res);
            return res;

        case 6: // lt
            res = evaluate_packet_value(pkt.children[0], debug) < evaluate_packet_value(pkt.children[1], debug) ? 1 : 0;
            debug && p('6/lt:', res);
            return res;

        case 7: // eq
            res = evaluate_packet_value(pkt.children[0], debug) === evaluate_packet_value(pkt.children[1], debug) ? 1 : 0;
            debug && p('7/eq:', res);
            return res;

        default:
            throw new Error(`Packet has type ${pkt.type}`);
    }
}

const tests = [
    {
        hex1: "D2FE28", // 110100101111111000101000
        hex2: "38006F45291200", // 00111000000000000110111101000101001010010001001000000000
        hex3: "EE00D40C823060" // 11101110000000001101010000001100100000100011000001100000
    },
    {
        hex4: "8A004A801A8002F478", // Sv16 OK
        hex5: "620080001611562C8802118E34", // Sv12 OK
        hex6: "C0015000016115A2E0802F182340", // Sv23
        hex7: "A0016C880162017C3686B18A3D4780" // Sv31
    },
    {
        hex8: "C200B40A82", // 3
        hex9: "04005AC33890", // 54
        hex10: "880086C3E88112", // 7
        hex11: "CE00C43D881120", // 9
        hex12: "D8005AC2A8F0", // 1
        hex13: "F600BC2D8F", // 0
        hex14: "9C005AC2F8F0", // 0
        hex15: "9C0141080250320F1802104A08" // 1
    }
];

// p("Hex2bin tests:");
// Object.values(tests[0]).forEach(hex => {
//     p(hex, '->', hex2bin(hex));
// });

// p("Sum of versions tests:");
// Object.values(tests[1]).forEach(hex => {
//     p(hex, '->', sum_versions(decode_packets(hex2bin(hex)).pkt));
// });

// p("Evaluated values tests:");
// Object.values(tests[2]).forEach(hex => {
//     p(hex, '->', evaluate_packet_value(decode_packets(hex2bin(hex)).pkt));
// });

let root_pkts = decode_packets(hex2bin(input)).pkt;
// p(insp(root_pkts, { depth: 6 }));

p("---");
p(`Part 1: ${sum_versions(root_pkts)}`); // 938
p(`Part 2: ${evaluate_packet_value(root_pkts)}`); // 1495959086337
