
import Foundation

struct Cell {
    var number: Int
    var crossed: Bool
}

class Board {
    init<S: Sequence>(_ lines: S) throws where S.Element == String {
        cells = lines.map { line in
            line.split(separator: " ").map { Cell(number: Int($0)!, crossed: false) }
        }
        guard cells.count == 5 && cells.allSatisfy({ $0.count == 5}) else {
            throw Errors.otherError(message: "Invalid board size")
        }

        print("Board initialized with \(cells)")
    }

    // If n is on the board, cross it. If entire row or column is crossed, return score
    func update(_ n: Int) -> Int? {
        if won {
            return nil
        }
        for row in 0...4 {
            for column in 0...4 {
                if cells[row][column].number == n {
                    cells[row][column].crossed = true
                    if cells[row].allSatisfy({ $0.crossed }) || cells.allSatisfy({ $0[column].crossed }) {
                        won = true
                        return sumUncrossed() * n
                    }
                }
            }
        }
        return nil
    }

    func sumUncrossed() -> Int {
        var sum = 0
        for row in cells {
            for cell in row {
                if !cell.crossed {
                    sum += cell.number
                }
            }
        }
        return sum
    }

    var cells: [[Cell]]
    var won: Bool = false
}

struct Day4 {

    static func main() async throws {

        guard let url = URL(string: "file:///Users/vladimir/Downloads/day4-input.txt") else {
            print("Could not parse URL")
            return
        }

        // Note: url.lines appear to skip empty lines
        var lines: [String] = []
        for try await line in url.lines {
            lines.append(line)
        }

        let numbers = lines[0].split(separator: ",").map { Int($0)! }
        var boards: [Board] = []
        var i = 1
        while i < lines.count {
            try boards.append(Board(lines[i...i+4]))
            i += 5
        }

        var scores: [Int] = []
        for n in numbers {
            for (bi, b) in boards.enumerated() {
                if let score = b.update(n) {
                    scores.append(score)
                    print("Board \(bi) is completed with score \(score)")
                }
            }
        }
    }
}
