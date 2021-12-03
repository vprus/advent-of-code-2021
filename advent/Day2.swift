import Foundation

enum Instruction {
    case forward(steps: Int)
    case down(steps: Int)
    case up(steps: Int)
    
    init(_ s: String) throws {
        let parts = s.split(separator: " ")
        if parts.count != 2 {
            throw Errors.parseError(input: s)
        }
        if let steps = Int(parts[1]) {
           switch parts[0] {
           case "forward": self = .forward(steps: steps)
           case "up": self = .up(steps: steps)
           case "down": self = .down(steps: steps)
           default: throw Errors.parseError(input: s)
           }
        } else {
            throw Errors.parseError(input: s)
        }        
    }
}

class State {
    var position = 0
    var depth = 0
    var aim = 0
    
    func update(instruction: Instruction) -> State {
        switch instruction {
        case let .forward(steps):
            position += steps
            depth += (aim * steps)
        case let .up(steps): aim -= steps
        case let .down(steps): aim += steps
        }
        return self
    }
}

struct Day2 {
    static func main() async throws {
        
        if let url = URL(string: "file:///Users/vladimir/Downloads/day2-input.txt") {
            let instructions = url.lines.map({ l in try Instruction(l) })
            let state = try await instructions.reduce(State(), { (state, instruction) in
                state.update(instruction: instruction)
            })
            
            print(state.position * state.depth)
        } else {
            print("Could not parse URL")
        }
    }
}
