
import Foundation

func day12() throws {
    let pairs = try input(day: 12).map { (line: String) -> (String, String) in
        let p = line.components(separatedBy: "-")
        return (p[0], p[1])
    }
    
    let neightbors = pairs.reduce(into: [String:[String]]()) {
        $0[$1.0, default: [String]()].append($1.1)
        $0[$1.1, default: [String]()].append($1.0)
    }
    
    // Use inout parameter for no better reason than trying this feature.
    func collectPaths(_ prefix: [String], counts: inout [String: Int],
                      prune: ([String], [String: Int]) -> Bool) -> [[String]] {
        if (prefix.last == "end") {
            return [prefix]
        }
        let extended = neightbors[prefix.last!]!.flatMap({ (next: String) -> [[String]] in
            counts[next, default: 0] += 1
            defer { counts[next, default: 0] -= 1 }
            if (prune(prefix + [next], counts)) {
                return [[String]]()
            } else {
                return collectPaths(prefix + [next], counts: &counts, prune: prune)
            }
        })
        return extended
    }
    
    func collectPaths(prune: ([String], [String: Int]) -> Bool) -> [[String]] {
        var counts = ["start": 1]
        return collectPaths(["start"], counts: &counts, prune: prune)
    }
    
    let paths1 = collectPaths(prune: { path, counts in
        counts.contains(where: { k, v in k.first!.isLowercase && v > 1})
    })
    print("Part 1: \(paths1.count)")
    
    let paths2 = collectPaths(prune: { path, counts in
        // Loop would be more efficient, but not as compact.
        counts["start"]! > 1
        // Observe that 'contains' uses a named parameter while 'filter' does not. Ick!
        || counts.contains(where: { k, v in k.first!.isLowercase && v > 2})
        || counts.filter({ k, v in k.first!.isLowercase && v > 1 }).count > 1
    })
    print("Part 2: \(paths2.count)")
}
