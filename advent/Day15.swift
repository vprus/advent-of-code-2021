import Foundation
import OrderedCollections
import SwiftPriorityQueue

struct RC: Hashable {
  var row: Int
  var column: Int
}

struct Path: Comparable {
    let rc: RC
    let minTotalRisk: Int
    
    static func < (lhs: Path, rhs: Path) -> Bool {
        return lhs.minTotalRisk < rhs.minTotalRisk
    }
}

func day15() throws {
     let lines = try input(day: 15)
    
    // Let's reuse custom Matrix from Day 13
    var data = Matrix(data: lines.map({ $0.map({ Int(String($0))! }) }))
    var m1 = data
    for _ in 1...4 {
        m1 = m1.map({ $0 + 1 }).map({ $0 > 9 ? 1 : $0 })
        data.appendRight(m1)
    }
    var m2 = data
    for _ in 1...4 {
        m2 = m2.map({ $0 + 1 }).map({ $0 > 9 ? 1 : $0 })
        data.appendBottom(m2)
    }
    
    let rows = data.rows
    let columns = data.columns
    
    // Using https://github.com/davecom/SwiftPriorityQueue here.
    var queue = PriorityQueue<Path>(ascending: true)
    var visited = Set<RC>()
    queue.push(Path(rc: RC(row: 0, column: 0), minTotalRisk: rows + columns - 2))
    
    for _ in 1... {
        let current = queue.pop()!
        
        if (current.rc == RC(row: rows - 1, column: columns - 1)) {
            print("Found \(current)")
            break
        }
        
        // We already visited this cell before, with a lower risk, so there's no point trying
        // again
        if (visited.contains(current.rc)) {
            continue
        }
        visited.insert(current.rc)
    
        for (dr, dc) in [(1,0), (-1, 0), (0, 1), (0, -1)] {
            let r = current.rc.row + dr
            let c = current.rc.column + dc
            if (r >= 0 && r < rows && c >= 0 && c < columns) {
                queue.push(Path(rc: RC(row: r, column: c),
                           minTotalRisk: current.minTotalRisk + data[r, c] - dr - dc))
            }
        }
    }
}
