
import Foundation

func day25() throws {
    let lines_ = """
v...>>.vv>
.vv>>.vv..
>>.>v>...v
>>v>>.>.v.
v>v.vv.v..
>.>>..v...
.vv..>.>v.
v.v..>>v.v
....v..v.>
""".components(separatedBy: "\n")
    let lines = try input(day: 25)
    
    var state = lines.map({ $0.map({ String($0) }) })
    let rows = state.count
    let columns = state[0].count
    
    state.forEach({ print($0.count) })
    
    func printState() {
        for row in 0..<rows {
            print(state[row].joined())
        }
    }
    
    func updateState() -> Bool {
        let emptyRow = [String](repeating: ".", count: columns)
        var newState1 = [[String]](repeating: emptyRow, count: columns)
        var newState2 = [[String]](repeating: emptyRow, count: columns)
        
        var moved = false
        for row in 0..<rows {
            for column in 0..<columns {
                if state[row][column] == ">" && state[row][(column + 1) % columns] == "." {
                    newState1[row][(column + 1) % columns] = state[row][column]
                    moved = true
                } else if state[row][column] != "." {
                    assert(row < newState1.count)
                    assert(column < newState1[row].count)
                    newState1[row][column] = state[row][column]
                }
            }
        }
        
        for row in 0..<rows {
            for column in 0..<columns {
                if newState1[row][column] == "v" && newState1[(row + 1) % rows][column] == "." {
                    newState2[(row + 1) % rows][column] = newState1[row][column]
                    moved = true
                } else if newState1[row][column] != "." {
                    newState2[row][column] = newState1[row][column]
                }
            }
        }
        state = newState2
        return moved
    }
    
    printState()
    for step in 1... {
        if !updateState() {
            print("Last step with change \(step)")
            break
        }
        print("\n\nStep \(step)")
        //printState()
    }
    
    
    
}
