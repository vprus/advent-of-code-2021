import Foundation
import Algorithms

func reverseDictionary<K, V>(_ d: Dictionary<K, V>) -> Dictionary<V, K> {
    return Dictionary(uniqueKeysWithValues: d.map({ ($0.1, $0.0 )}))
}

let digits = [
    0: "abcefg", 1: "cf", 2: "acdeg", 3: "acdfg", 4: "bcdf",
    5: "abdfg", 6: "abdefg", 7: "acf", 8: "abcdefg", 9: "abcdfg"
]

let reverseDigits = reverseDictionary(digits)

func solve(_ codes: [String]) -> Int {
    
    let sets = codes.map { Set($0) }
    let usageCounts = codes[0...9].joined().reduce(into: [Character: Int]()) { (counts, c) in
        counts[c, default: 0] += 1
    }
    
    let one = sets.first(where: { $0.count == 2 })!
    let seven = sets.first(where: { $0.count == 3 })!
    let four = sets.first(where: { $0.count == 4 })!
    
    var encoding = [Character: Character]()
    encoding["a"] = seven.subtracting(one).first!
    encoding["b"] = four.subtracting(one).filter({ usageCounts[$0] == 6 }).first!
    encoding["c"] = one.filter({ usageCounts[$0] == 8 }).first!
    encoding["d"] = four.subtracting(one).filter({ usageCounts[$0] != 6 }).first!
    encoding["e"] = usageCounts.filter({ $0.value == 4 }).first!.key
    encoding["f"] = usageCounts.filter({ $0.value == 9 }).first!.key
    // g has usage count 7, just like d. But we know what is d.
    encoding["g"] = usageCounts.filter({ $0.value == 7 && $0.key != encoding["d"]! }).first!.key
    let decoding = reverseDictionary(encoding)
   
    return codes[10...].map({ code in
        String(code.map { decoding[$0]! }.sorted())
    }).map({ reverseDigits[$0]! }).reduce(0, { $0 * 10 + $1 })
}

func day8() throws {
    let lines = try input(day: 8)
    
    print (lines.map({ line in
        solve(line.split(whereSeparator: { $0 == " " || $0 == "|" }).map({ String($0) }))
    }).reduce(0, { $0 + $1 }))
}
