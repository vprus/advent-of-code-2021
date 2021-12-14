
import Foundation
import Algorithms

func day14() throws {
    let lines = try input(day: 14)
    
    let s = lines[0]
    var pairCounts = s.windows(ofCount: 2).reduce(into: [String: Int](), {
        $0[String($1), default: 0] += 1
    })
    
    let rules = lines[1...].filter{ $0.count > 0 }.map { Array($0) }.map { (String([$0[0], $0[1]]), $0[6]) }
    
    func runRules(_ pairs: [String: Int]) -> [String: Int] {
        var r = [String: Int]()
        pairs.forEach { pair in
            if let rule = rules.first(where: { String($0.0) == pair.key }) {
                r[String([rule.0.first!, rule.1]), default: 0] += pair.value
                r[String([rule.1, rule.0.last!]), default: 0] += pair.value
            } else {
                r[pair.key, default: 0] += pair.value
            }
        }
        return r
    }
    
    for _ in 1...40 {
        pairCounts = runRules(pairCounts)
    }
    
    var characterCounts = pairCounts.reduce(into: [String: Int](), {
        $0[String($1.key.first!), default: 0] += $1.value
        $0[String($1.key.last!), default: 0] += $1.value
    })
    // The above will double-count all characters, so we need to divide counts by 2
    // Except that first and last characters are only part of a single pair, so bump
    // them up.
    characterCounts[String(s.first!), default: 0] += 1
    characterCounts[String(s.last!), default: 0] += 1
    
    let sortedCounts = characterCounts.sorted(by: { $0.1 > $1.1 })
    print(sortedCounts.first!.value/2 - sortedCounts.last!.value/2)
}
