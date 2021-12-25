
import Foundation
import SwiftPriorityQueue

let stepCost = ["A": 1, "B": 10, "C": 100, "D": 1000]
let sideroomColumn = ["A": 3, "B": 5, "C": 7, "D": 9]
let sideroomColumns = [3, 5, 7, 9]

struct AmphipodState : Comparable, CustomStringConvertible {
    var board: [[String]]
    var cost: Int = 0
    
    var complete: Bool {
        return sideroomColumn.allSatisfy({ (l, c) in
            board.countIf({ row in row[c] == l}) == (board.count - 3)
        })
    }
    
    func move(r1: Int, c1: Int, r2: Int, c2: Int) -> AmphipodState {
        let l = board[r1][c1]
        var newBoard = board
        newBoard[r2][c2] = l
        newBoard[r1][c1] = "."
        let steps = (r1 - 1) + (r2 - 1) + abs(c2 - c1)
        return AmphipodState(board: newBoard, cost: self.cost + steps * stepCost[l]!)
    }
    
    func explore() -> [AmphipodState] {
        var moves = [[[Int]]]()
        for l in ["A", "B", "C", "D"] {
            let c = sideroomColumn[l]!
            
            // Compute the empty hallway area around this sideroom.
            let left: Int = board[1][0..<c].lastIndex(where: { ("A"..."D").contains($0) || $0 == "#" })!
            let right: Int = board[1][(c+1)...].firstIndex(where: { ("A"..."D").contains($0) || $0 == "#" })!
           
            let column = (1..<board.count).map { board[$0][c] }
            if column.allSatisfy({ $0 == l || $0 == "." || $0 == "#" }) {
                // The column has only desired letters, can accept further ones, either
                // from the hallway, or from other columns
                let r: Int = column.firstIndex(where: { $0 == l || $0 == "#" })!
                
                if board[1][left] == l {
                    moves.append([[1, left], [r, c]])
                }
                if board[1][right] == l {
                    moves.append([[1, right], [r, c]])
                }
                for ac in sideroomColumns {
                    if (ac != c && left < ac && ac < right) {
                        let ar = (2...).first(where: {board[$0][ac] != "."})!
                        if board[ar][ac] == l {
                            moves.append([[ar, ac], [r, c]])
                        }
                    }
                }
            } else {
                if let xr = column.firstIndex(where: { ("A"..."D").contains($0) }) {
                    let r = xr + 1
                    for ac in (left+1)...(right-1) {
                        if !sideroomColumns.contains(ac) {
                            moves.append([[r, c], [1, ac]])
                        }
                    }
                }
            }
        }
        return moves.map({ self.move(r1: $0[0][0], c1: $0[0][1], r2: $0[1][0], c2: $0[1][1]) })
    }
    
    var description: String {
        board.map({ $0.joined(separator: "")}).joined(separator: "\n") + "\n" + "(cost \(cost))\n"
    }
    
    static func < (lhs: AmphipodState, rhs: AmphipodState) -> Bool {
        return lhs.cost < rhs.cost
    }
}

func day23() throws {
    let lines = try input(day: 23)
    let lines2 = Array(lines[0...2]) + ["  #D#C#B#A#", "  #D#B#A#C#"] + Array(lines[3...])
    
    let pieces = lines.map({$0.map({ String($0) })})
    let pieces2 = lines2.map({$0.map({ String($0) })})
    
    func solve(_ state: AmphipodState) {
        var visited = Set<[[String]]>()
        var queue = PriorityQueue<AmphipodState>(ascending: true)
        queue.push(state)
        
        while !queue.isEmpty {
            let s = queue.pop()!
            guard visited.insert(s.board).inserted else {
                continue
            }
            if (s.complete) {
                print(s)
                break;
            }
            s.explore().forEach({ queue.push($0) })
        }
    }
    
    solve(AmphipodState(board: pieces))
    solve(AmphipodState(board: pieces2))
}
