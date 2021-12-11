
import Foundation
import Algorithms

struct Day11: CustomStringConvertible {
    var board: [[Int]]
    
    // Increase everything by 1. Any cell >9 flashes and contributes further +1 to all neightbors
    func step() -> Day11 {
        var newBoard = board
        var queue: [(Int, Int)] = Array(product(0..<10, 0..<10))
        let neighbors = product(-1...1, -1...1).filter { $0.0 != 0 || $0.1 != 0 }
        var i = 0
        while i < queue.count {
            let (r,c) = queue[i]
            if (newBoard[r][c] <= 9) {
                newBoard[r][c] += 1
                if newBoard[r][c] > 9 {
                    for n in neighbors {
                        if (0..<10).contains(r + n.0) && (0..<10).contains(c + n.1) {
                            queue.append((r + n.0, c + n.1))
                        }
                    }
                }
            }
            i += 1
        }
        return Day11(board: newBoard.map { $0.map { $0 > 9 ? 0 : $0 }})
    }
    
    var description: String {
        return board.map({
            String($0.map({ String($0) }).joined())
        }).joined(separator: "\n")
    }
}

func day11() throws {
    let lines = try input(day: 11)
    let data = lines.map { l in
        l.map { Int(String($0))! }
    }
    
    var current = Day11(board: data)
    var total = 0
    for s in 1...Int.max {
        current = current.step()
        let flushes = current.board.flatMap{ $0 }.reduce(0, { $0 + ($1 == 0 ? 1 : 0 )})
        total += flushes
        if (s == 100) {
            print("Part 1: \(total)")
        }
        if (flushes == 100) {
            print("Part 2: \(s)")
            break;
        }
    }
}

func day11_testData() -> Day11 {
    let lines = """
        5483143223
        2745854711
        5264556173
        6141336146
        6357385478
        4167524645
        2176841721
        6882881134
        4846848554
        5283751526
        """
    let board = lines.components(separatedBy: "\n").map { l in
        l.map { Int(String($0))! }
    }
    return Day11(board: board)
}
