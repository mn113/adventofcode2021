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
 * @property {Number} version
 * @property {Number} type
 * @property {Number} value
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

    // toString() {
    //     return `[ V${this.version}, T${this.type}, L${this.value}, c:[${this.children.join(',')}] ]`;
    // }
}

/**
 * Decode a binary string and all its subpackets
 * @param {String} bitstr
 * @param {Object} options
 * @param {Number} options.sublength
 * @param {Number} options.subcount
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
 * Sums the versions of all packets
 * @param {Packet} pkt
 * @returns {Number}
 */
function sum_versions(pkt) {
    sum = pkt.version;
    if (pkt.children && pkt.children.length) {
        sum += pkt.children.reduce(
            (acc, child_pkt) => acc + sum_versions(child_pkt),
            0
        );
    }
    return sum;
}

let hex1 = "D2FE28" // 110100101111111000101000
let hex2 = "38006F45291200" // 00111000000000000110111101000101001010010001001000000000
let hex3 = "EE00D40C823060" // 11101110000000001101010000001100100000100011000001100000
let hex4 = "8A004A801A8002F478" // Sv16 OK
let hex5 = "620080001611562C8802118E34" // Sv12 OK
let hex6 = "C0015000016115A2E0802F182340" // Sv23
let hex7 = "A0016C880162017C3686B18A3D4780" // Sv31

p(sum_versions(decode_packets(hex2bin(hex4)).pkt)); // 16
p(sum_versions(decode_packets(hex2bin(hex5)).pkt)); // 12
p(sum_versions(decode_packets(hex2bin(hex6)).pkt)); // 23
p(sum_versions(decode_packets(hex2bin(hex7)).pkt)); // 31

let { pkt: root_pkts } = decode_packets(hex2bin(input));
p(insp(root_pkts, { depth: 6 }));

let s = sum_versions(root_pkts);
p(`Part 1: ${s}`); // 938
