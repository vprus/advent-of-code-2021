
import Foundation

struct Packet {
    let version: Int
    let type: Int
    let literal: Int?
    let subs: [Packet]
    
    func sumOfVersions() -> Int {
        return version + subs.map({ $0.sumOfVersions() }).reduce(0, { $0 + $1 })
    }
    
    func value() -> Int {
        if (type == 4) {
            return literal!
        }
        
        let subvalues = subs.map({ $0.value() })
        
        switch (type) {
        case 0: return subvalues.reduce(0, { $0 + $1 })
        case 1: return subvalues.reduce(1, { $0 * $1 })
        case 2: return subvalues.min()!
        case 3: return subvalues.max()!
        case 5: return (subvalues[0] > subvalues[1]) ? 1 : 0
        case 6: return (subvalues[0] < subvalues[1]) ? 1 : 0
        case 7: return (subvalues[0] == subvalues[1]) ? 1 : 0
        default: return Int.max
        }
    }
}

func parseBits<T: Sequence>(_ bits: T) -> Int where T.Element == Int {
    bits.reduce(0, { $0 * 2 + $1 })
}

func hexToBits(_ hex: String) -> [Int] {
    hex.flatMap({ ds -> [Int] in
        let d = Int(String(ds), radix: 16)!
        return [d & 8, d & 4, d & 2, d & 1]
    }).map({ ($0 > 0) ? 1 : 0 })
}

func parse(_ xbits: ArraySlice<Int>) -> (Packet, ArraySlice<Int>)  {
    var bits = xbits
    
    func parseValue(_ n: Int) -> Int { let r = parseBits(bits.prefix(n)); bits = bits.suffix(from: bits.startIndex.advanced(by: n)); return r }
    func parseSub() -> Packet { let (r, b) = parse(bits); bits = b; return r }
  
    let version = parseValue(3)
    let type = parseValue(3)
    var subs = [Packet]()
    if (type == 4) {
        var literal = 0
        while true {
            let n = parseValue(5)
            literal = literal << 4 | (n & 0xF)
            if (n & 0x10) == 0 {
                break
            }
        }
        return (Packet(version: version, type: type, literal: literal, subs: subs), bits)
    } else {
        if parseValue(1) == 0 {
            let subpacketBits = parseValue(15)
            let tail = bits.suffix(from: bits.startIndex.advanced(by: subpacketBits))
            bits = bits.prefix(subpacketBits)
            while !bits.isEmpty {
                subs.append(parseSub())
            }
            return (Packet(version: version, type: type, literal: nil, subs: subs), tail)
        } else {
            for _ in 0..<parseValue(11) {
                subs.append(parseSub())
            }
            return (Packet(version: version, type: type, literal: nil, subs: subs), bits)
        }
    }
    return (Packet(version: version, type: type, literal: nil, subs: subs), bits)
}

func day16() throws {
    let test = [1, 2, 3, 4, 5, 6, 7, 8]
    let slice = test[4...]
    // The line below crashes, because array slice has the same indexes
    // as the original array, and the first index is '4'. Which means that
    // to index a slice, one has to remember the start index, and one might
    // as well index the original array.
    //
    // No other language I know does this.
    // print(slice[0..<2])
    // The below works, but is way to much typing.
    print(slice[slice.startIndex...slice.startIndex.advanced(by: 2)])

    let lines = try input(day: 16)
    let p = parse(hexToBits(lines[0])[0...])
    print(p.0.sumOfVersions())
    print(p.0.value())
}
