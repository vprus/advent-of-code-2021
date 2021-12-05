
import Foundation

struct Coordinate: Hashable {
    var x: Int
    var y: Int
}


struct VentLine {
    var from: Coordinate
    var to: Coordinate
    
    init(_ s: String) throws {
        // Regular expression appear to be badly lacking in Swift.
        guard let match = VentLine.pattern.matches(in: s, options: [], range: NSRange(s.startIndex..<s.endIndex, in: s)).first else {
            throw Errors.otherError(message: "Failed to match input")
        }
        // In Scala, it would take `case pattern(a, b, c, d)` to extract subgroups.
        from = Coordinate(x: Int(s[Range(match.range(at: 1), in: s)!])!, y: Int(s[Range(match.range(at: 2), in: s)!])!)
        to = Coordinate(x: Int(s[Range(match.range(at: 3), in: s)!])!, y: Int(s[Range(match.range(at: 4), in: s)!])!)
    }
    
    var allCoordinates: [Coordinate] {
        get throws {
            let deltaX = (to.x - from.x).clamped(to: -1...1)
            let deltaY = (to.y - from.y).clamped(to: -1...1)
            if deltaX == 0 || deltaY == 0 || abs(deltaX) == abs(deltaY) {
                var result: [Coordinate] = [from]
                while result.last != to {
                    result.append(Coordinate(x: result.last!.x + deltaX, y: result.last!.y + deltaY))
                }
                return result
            } else {
                throw Errors.otherError(message: "Found too diagonal line")
            }
        }
    }
    
    static let pattern = try! NSRegularExpression(pattern: #"^([0-9]+),([0-9]+) -> ([0-9]+),([0-9]+)$"#, options: [])
}

func day5() throws {
    let lines = try input(day: 5).map({ try VentLine($0) })
  
    var counts: [Coordinate: Int] = [:]
    for line in lines {
        for c in try line.allCoordinates {
            counts.updateValue((counts[c] ?? 0) + 1, forKey: c)
        }
    }
    
    let (width, height) = counts.keys.reduce((0, 0), { (a: (Int, Int), c: Coordinate) in
        return (max(a.0, c.x), max(a.1, c.y))
    })
    
                  
    
    for y in 0...height {
        for x in 0...width {
            if let c = counts[Coordinate(x: x, y:y )] {
                print(c, terminator: "")
            } else {
                print (".", terminator: "")
            }
        }
        print("\n", terminator: "")
    }
                                             
                                            
    var result = 0
    counts.forEach { if $0.value > 1 {
        result += 1
    } }
    
    print(result)
}
