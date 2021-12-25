
import Foundation

struct Cuboid {
    var on: Bool
    var bounds: [[Int]]
    
    var volume: Int {
        return bounds.map({ $0[1] - $0[0] + 1 }).reduce(1, { $0 * $1 })
    }
    
    init(_ s: String.SubSequence) {
        on = s.prefix(2) == "on"
        bounds = s.split(separator: ",").map { s2 in
            let j = s2.firstIndex(of: "=")!
            return s2[s2.index(after: j)...].components(separatedBy: "..").map { Int($0)! }
        }
    }
    
    init(_ on: Bool, _ bounds: [[Int]]) {
        self.on = on
        self.bounds = bounds
    }
    
    func rebounded(_ d: Int, _ bound: [Int]) -> Cuboid {
        var bounds = self.bounds
        bounds[d] = bound
        return Cuboid(self.on, bounds)
    }
        
    func subtract(_ another: Cuboid, _ d: Int = 0) -> [Cuboid] {
        let sb = self.bounds[d]
        let ab = another.bounds[d]
        
        let intersection = [max(sb[0], ab[0]), min(sb[1], ab[1])]
        if intersection[0] > intersection[1] {
            return [self]
        }
        
        return [
            [sb[0], intersection[0] - 1],
            intersection,
            [intersection[1] + 1, sb[1]]
        ]
            .filter({ $0[0] <= $0[1] })
            .flatMap { piece -> [Cuboid] in
                if piece == intersection {
                    if (d == 2) {
                        return []
                    } else {
                        return self.rebounded(d, intersection).subtract(another, d + 1)
                    }
                } else {
                    return [self.rebounded(d, piece)]
                }
            }
    }
}

func day22() throws {
    let lines = try input(day: 22).map{ $0[$0.startIndex...] }
    
    let steps = lines.map { Cuboid($0) }
    
    func runSteps(_ steps: [Cuboid]) {
        var result = [steps[0]]
        for step in steps[1...] {
            print("Processing \(result.count) cuboids")
            result = result.flatMap({ prior in prior.subtract(step) })
            if step.on {
                result.append(step)
            }
        }
        print(result.filter({ $0.on }).reduce(0, { $0 + $1.volume }))
    }
    
    runSteps(steps.filter { cube in
        cube.bounds.allSatisfy({ $0[0] >= -50 && $0[1] <= 50 })
    })
    runSteps(steps)
}

