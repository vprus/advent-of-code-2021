import Foundation
import Algorithms

struct QuantumState: Hashable {
    var positions: [Int]
    var scores = [0, 0]
    var rolls = 0
}

func day21_part2() throws {
    var stateCounts = [QuantumState(positions: [4 - 1, 7 - 1]): 1]
    
    let diceCounts = Dictionary(product(product(1...3, 1...3), 1...3).map{ ($0.0 + $0.1 + $1, 1)}, uniquingKeysWith: +)
    
    for step in 1...20 {
        var changes = 0
        for i in 0..<2 {
            var newStateCounts = [QuantumState: Int]()
            for (dice, diceCount) in diceCounts {
                for (state, count) in stateCounts {
                    if (state.scores[0] >= 21 || state.scores[1] >= 21) {
                        newStateCounts[state] = count
                    } else {
                        var newState = state
                        newState.positions[i] = (state.positions[i] + dice) % 10
                        newState.scores[i] = (state.scores[i]) + (newState.positions[i] + 1)
                        newState.rolls += 1
                        newStateCounts[newState, default: 0] += diceCount * count
                        changes += 1
                    }
                }
            }
            stateCounts = newStateCounts
        }
        print("Step \(step), changes \(changes)")
        if changes == 0 {
            print("Done after \(step) steps")
            break
        }
    }
    
    let w1 = stateCounts.filter({ $0.key.scores[0] >= 21 }).reduce(0, { $0 + $1.value})
    let w2 = stateCounts.reduce(0, { $0 + $1.value }) - w1
    print([w1, w2].max()!)
}
