
import Foundation

func parseBits<T: Sequence>(_ bits: T) -> Int where T.Element == Int {
    bits.reduce(0, { $0 * 2 + $1 })
}

func hexToBits(_ hex: String) -> [Int] {
    hex.flatMap({ ds -> [Int] in
        let d = Int(String(ds), radix: 16)!
        return [d & 8, d & 4, d & 2, d & 1]
    }).map({ ($0 > 0) ? 1 : 0 })
}

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
    
    static func parse<T: RandomAccessCollection>(_ bits: T, nesting: String = "") throws -> (Packet, Int) where T.Element == Int, T.Index == Int {
        print("\(nesting)Parsing \(bits.map({ String($0) }).joined())")
        let version = parseBits(bits[0...2])
        let type = parseBits(bits[3...5])
        var subs = [Packet]()
        print("\(nesting)Type is \(type)")
        if (type == 4) {
            print("\(nesting)Parsing value")
            var valueBits = [Int]()
            for i in stride(from: 6, to: bits.count, by: 5) {
                valueBits.append(contentsOf: bits[i+1...i+4])
                if bits[i] == 0 {
                    print("\(nesting)Value packet \(version): \(parseBits(valueBits))")
                    return (Packet(version: version, type: type, literal: parseBits(valueBits), subs: subs), i+5)
                }
            }
        } else {
            var i = 0
            var shouldStop: () -> Bool
            if bits[6] == 0 {
                let subpacketBits = parseBits(bits[7..<(7+15)])
                print("\(nesting)Subpacket bits: \(subpacketBits)")
                i = 7 + 15
                shouldStop = { i >= (7 + 15) + subpacketBits }
            } else {
                let subpacketsCount = parseBits(bits[7..<(7+11)])
                print("\(nesting)Subpacket count: \(subpacketsCount)")
                i = 7 + 11
                shouldStop = { subs.count >= subpacketsCount }
            }
            
            while true {
                print("\(nesting)Parsing at \(i)")
                let r = try Packet.parse(Array(bits[i...]), nesting: nesting + "    ")
                subs.append(r.0)
                i += r.1
                if shouldStop() {
                    break
                }
            }
            return (Packet(version: version, type: type, literal: nil, subs: subs), i)
        }
        throw Errors.otherError(message: "Unexpected end of parsing")
    }
}

func day16() throws {
    let lines = try input(day: 16)
    let p = try Packet.parse(hexToBits(lines[0]))
    print(p.0.value())
}
