
import Foundation

func day6() throws {
    let lines = try input(day: 6)
    let fishes = lines[0].components(separatedBy: ",").map { Int($0)! }
    
    var fishCounts = fishes.reduce(into: [Int: Int]()) {
        $0[$1, default: 0] += 1
    }
    for _ in 1...256 {
        let dividing = fishCounts[0, default: 0]
        for i in 0...7 {
            fishCounts[i] = fishCounts[i + 1, default: 0]
        }
        fishCounts[8] = dividing
        fishCounts[6, default: 0] += dividing
    }
    print(fishCounts.values.reduce(0, { $0 + $1}))
}
