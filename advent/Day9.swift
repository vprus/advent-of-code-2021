import Foundation
import Algorithms

// In Swift, tuple is not hashable and can't be used in Set.
struct Coord: Hashable {
    var r: Int
    var c: Int
}

func day9() throws {
    let lines = try input(day: 9)
    let data = lines.map({ $0.map { Int(String($0))! }})
   
    var visited = Set<Coord>()
    var basins = [Int]()
    
    func explore(_ ri: Int, _ ci: Int) -> Int {
        if ri < 0 || ri >= data.count || ci < 0 || ci >= data[ri].count {
            return 0
        }
        if data[ri][ci] == 9 {
            return 0
        }
        if !visited.insert(Coord(r: ri, c: ci)).inserted {
            return 0
        }
        return 1 + explore(ri - 1, ci) + explore(ri + 1, ci) + explore(ri, ci - 1) + explore(ri, ci + 1)
    }
    
    for ri in 0..<data.count {
        for ci in 0..<data[ri].count {
            let c = explore(ri, ci)
            if c > 0 {
                basins.append(c)
            }
        }
    }
    print(basins.sorted(by: { $0 > $1 })[0...2].reduce(1, { $0 * $1 }))
}
