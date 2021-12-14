
import Foundation
import Algorithms

extension Sequence {
    func elementCounts() -> [Element: Int] where Element: Hashable {
        self.reduce(into: [Element: Int](), { $0[$1, default: 0] += 1 })
    }
    func combineCounts<Key>() -> [Key: Int]  where Element == (Key, Int) {
        self.reduce(into: [Key: Int](), { $0[$1.0, default: 0] += $1.1 })
    }
}

func day14() throws {
    let lines = try input(day: 14)
    
    let s = lines[0]
    var pairCounts = s.windows(ofCount: 2).map({ String($0) }).elementCounts()
    let rules = lines[1...].filter{ $0.count > 0 }.map { Array($0) }.map { (String([$0[0], $0[1]]), $0[6]) }
    
    for _ in 1...40 {
        pairCounts = pairCounts.flatMap({ pair -> [(String, Int)] in
            if let rule = rules.first(where: { String($0.0) == pair.key }) {
                return [(String([rule.0.first!, rule.1]), pair.value), (String([rule.1, rule.0.last!]), pair.value)]
            }
            return [(pair.key, pair.value)]
        }).combineCounts()
    }
    
    var characterCounts = pairCounts.flatMap({
        [($0.key.first!, $0.value), ($0.key.last!, $0.value)]
    }).combineCounts()
    characterCounts[s.first!, default: 0] += 1
    characterCounts[s.last!, default: 0] += 1
    
    let sortedCounts = characterCounts.sorted(by: { $0.1 > $1.1 })
    print(sortedCounts.first!.value/2 - sortedCounts.last!.value/2)
}
