
import Foundation
import SwiftPriorityQueue

class DasPointer: CustomStringConvertible {
    static var nextId = 0
    
    var id: Int
    var p: AluExpression
    var range: ClosedRange<Int>? = nil //Int.min...Int.max
    
    init(_ p: AluExpression) {
        self.p = p
        self.id = DasPointer.nextId
        DasPointer.nextId += 1
        update(p)
    }
    
    func treeString() -> String {
        var visited = Set<Int>()
        return treeString(&visited, "")
    }
    
    func treeString(_ visited: inout Set<Int>, _ indent: String) -> String {
        guard visited.insert(id).inserted else {
            return indent + "# \(id)"
        }
        
        if case let .op(op, operands) = self.p {
            return indent + description + "\n"
            + operands.map{( $0.treeString(&visited, indent + "    ") )}.joined(separator: "\n")
        } else {
            return indent + description
        }
    }
    
    func evaluate(_ input: [Int], _ registers: [Int]? = nil) -> Int? {
        var cache = [Int: Int?]()
        return evaluate(input, registers, &cache)
    }
    
    func evaluate(_ input: [Int], _ registers: [Int]?, _ cache: inout [Int: Int?]) -> Int? {
        if let c = cache[id] {
            return c
        }
        
        var result: Int? = nil
        if case let .input(i) = self.p {
            result = input[i]
        } else if case let .literal(v) = self.p {
            result = v
        } else if case let .register(r) = self.p, registers != nil {
            result = registers![r]
        } else if case let .op(op, operands) = self.p {
            let ev = operands.map({ $0.evaluate(input, registers, &cache) })
            if ev.contains(where: { $0 == nil }) {
                return nil
            }
            switch (op) {
            case "add": result = ev[0]! + ev[1]!
            case "mul": result = ev[0]! * ev[1]!
            case "div": result =  ev[1] == 0 ? nil : (ev[0]! / ev[1]!)
            case "mod": result =  (ev[0]! < 0 || ev[1]! <= 0) ? nil : (ev[0]! % ev[1]!)
            case "eql": result =  (ev[0]! == ev[1]!) ? 1 : 0
            default: break
            }
        }
        
        cache[id] = result
        return result
    }
    
    func update(_ p: AluExpression) {
        self.p = p
        if case let .input(i) = p {
            range = 1...9
        }
        if case let .op(op, _) = p, op == "eql" {
            range = 0...1
        }
        if case let .literal(v) = p {
            range = v...v
        }
    }
    
    func updateRange(_ r: ClosedRange<Int>) {
        if range == nil {
            range = r
        } else {
            range = max(range!.lowerBound, r.lowerBound)...min(range!.upperBound, r.upperBound)
        }
    }
        
    func optimize() -> (DasPointer, Bool) {
        var cache = [Int: DasPointer]()
        return optimize(cache: &cache)
    }
    
    func optimize(cache: inout [Int: DasPointer]) -> (DasPointer, Bool) {
        if let c = cache[self.id] {
            return (c, false)
        }
        let r = optimizeInner(cache: &cache)
        cache[self.id] = r.0
        return r
    }
        
    func optimizeInner(cache: inout [Int: DasPointer]) -> (DasPointer, Bool) {
        if case var .op(op, operands) = p {
            let optimized = operands.map({ $0.optimize(cache: &cache)})
            var n = false
            for i in 0..<optimized.count {
                operands[i] = optimized[i].0
                n = n || optimized[i].1
            }
            
            if case let .literal(lv) = operands[0].p, case let .literal(rv) = operands[1].p {
                if op == "add" {
                    update(.literal(v: lv + rv))
                    return (self, true)
                }
                if op == "mul" {
                    update(.literal(v: lv * rv))
                    return (self, true)
                }
                if op == "div" {
                    update(.literal(v: lv / rv))
                    return (self, true)
                }
                if op == "mod" {
                    update(.literal(v: lv % rv))
                    return (self, true)
                }
                if op == "eql" {
                    update(.literal(v: (lv == rv) ? 1 : 0))
                    return (self, true)
                }
            }
            
            if case let .literal(lv) = operands[0].p {
                if op == "add" && lv == 0 {
                    if (id == 51) {
                        print("HERE")
                    }
                    return (operands[1], true)
                }
                if op == "mul" && lv == 1 {
                    return (operands[1], true)
                }
                if op == "mul" && lv == 0 {
                    update(.literal(v: 0))
                    return (self, true)
                }
            }
            
            if case let .literal(rv) = operands[1].p {
                if op == "add" && rv == 0 {
                    return (operands[0], true)
                }
                if op == "add" {
                    if operands[0].range != nil {
                        updateRange((operands[0].range!.lowerBound + rv)...(operands[0].range!.upperBound + rv))
                    }
                }
                if op == "mul" && rv == 1 {
                    return (operands[0], true)
                }
                if op == "mul" && rv == 0 {
                    update(.literal(v: 0))
                    return (self, true)
                }
                if op == "mod" {
                    range = 0...(rv - 1)
                }
            }
            
            
            if let left_range = operands[0].range, let right_range = operands[1].range {
                if op == "eql" && (left_range.upperBound < right_range.lowerBound || right_range.upperBound < left_range.lowerBound) {
                    update(.literal(v: 0))
                    return (self, true)
                }
                if op == "add" {
                    updateRange((left_range.lowerBound + right_range.lowerBound)...(left_range.upperBound + right_range.upperBound))
                }
                
                if op == "mul" && left_range.lowerBound >= 0 && right_range.lowerBound >= 0 {
                    updateRange((left_range.lowerBound * right_range.lowerBound)...(left_range.upperBound * right_range.upperBound))
                }
                
                if op == "div" && left_range.lowerBound >= 0 && right_range.lowerBound >= 0 {
                    updateRange((left_range.lowerBound / right_range.upperBound)...(left_range.upperBound / right_range.lowerBound))
                }
            }
            
            if op == "div", case .literal(1) = operands[1].p {
                return (operands[0], true)
            }
            
            update(.op(op: op, operands: operands))
            return (self, n)
        }
        return (self, false)
    }
    
    var description: String {
        switch self.p {
        case let .input(i): return "\(id): input \(i)" + (range != nil ? " range \(range!)" : "")
        case let .register(i): return "\(id): " + ["w", "x", "y", "z"][i]
        case let .literal(v): return "\(id):" + String(v)
        case let .op(op, operands): return "\(id): \(op) "
            + operands.map({ "op(\($0.id))" }).joined(separator: " ")
            + (range != nil ? " range \(range!)" : "")
           
        }
    }
}

indirect enum AluExpression {
    case input(i: Int)
    case register(r: Int)
    case literal(v: Int)
    case op(op: String, operands: [DasPointer])
}

struct SearchState {
    var z: Int
    var inputAsNumber: Int
}

func day24() throws {
    let lines = try input(day: 24)
    let lines_ = """
inp w
add z w
mod z 2
div w 2
add y w
mod y 2
div w 2
add x w
mod x 2
div w 2
mod w 2
""".components(separatedBy: "\n")
    
    func parseOp(_ s: String) -> AluExpression {
       if let i = ["w", "x", "y", "z"].firstIndex(of: s) {
           return .register(r: i)
       } else {
           return .literal(v: Int(s)!)
       }
    }
    
    var searchStates = [SearchState(z: 0, inputAsNumber: 0)]
    
    for piece in 0..<14 {
        
        var inputIndex = 0
        //var registerValues = [DasPointer](repeating: DasPointer(AluExpression.literal(v: 0)), count: 4)
        var registerValues = (0...3).map({ DasPointer(AluExpression.register(r: $0)) })
        
        for line in lines[(18*piece)..<(18*piece + 18)] {
            let pieces = line.split(separator: " ")
            let operation = String(pieces[0])
            let operands = pieces[1...].map({ parseOp(String($0)) })
            if case let .register(dst) = operands[0] {
                if operation == "inp" {
                    registerValues[dst] = DasPointer(AluExpression.input(i: inputIndex))
                    inputIndex += 1
                } else {
                    let transformed = operands.map({ (e: AluExpression) -> DasPointer in
                        if case let .register(r) = e {
                            return registerValues[r]
                        } else {
                            return DasPointer(e)
                        }
                    })
                    registerValues[dst] = DasPointer(AluExpression.op(op: operation, operands: transformed))
                }
            }
        }
        
        for i in 3...3 {
            var f = registerValues[i]
            
            /*
            for _ in 1...10 {
                let (nf, changed) = f.optimize()
                if (!changed) {
                    break
                }
                f = nf
            }*/
            
            print("Processign step \(piece)")
            
            print(f.treeString())
            
            searchStates = searchStates.flatMap({ state in
                
                (1...9).compactMap({ input -> SearchState? in
                    var inputs = [input]
                    var registers = [0, 0, 0, state.z]
                    let r = f.evaluate(inputs, registers)
                    if (r == nil) {
                        return nil
                    }
                    var newState = state
                    newState.inputAsNumber = state.inputAsNumber * 10 + input
                    newState.z = r!
                    return newState
                })
            })
            
            //print("New states \(searchStates)")
            print("New states \(searchStates.count)")
            
            let counts: [Int: Int] = Dictionary<Int, Int>(searchStates.map({ ($0.z, $0.inputAsNumber) }), uniquingKeysWith: min)
            searchStates = counts.map({ SearchState(z: $0.key, inputAsNumber: $0.value )})
        }
    }
    
    print(searchStates.filter({ $0.z == 0 }).map({ $0.inputAsNumber }).min())
}
