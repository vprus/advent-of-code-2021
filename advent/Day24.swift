
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
        
    func constrain(_ value: ClosedRange<Int>, _ visited: inout [Int: ClosedRange<Int>]) {
        if let c = visited[id] {
            if !(value.lowerBound > c.lowerBound || value.upperBound < c.upperBound) {
                return
            }
        }
        visited[id] = value
        
        if case let .input(i) = p {
            print("INPUT \(i) seem to matter \(value)")
        }
        
        if case let .op(op, operands) = p {
            updateRange(value)
            
            if op == "add" && range?.lowerBound == value.lowerBound && range?.lowerBound == value.upperBound {
                operands.forEach({ $0.constrain($0.range!.lowerBound...$0.range!.lowerBound, &visited) })
            } else if op == "add" && operands[0].range!.lowerBound >= 0 && operands[1].range!.lowerBound >= 0 {
                operands[0].constrain(Int.min...range!.upperBound, &visited)
                operands[1].constrain(Int.min...range!.upperBound, &visited)
            }
            
            else if op == "mul" && range?.lowerBound == 0 && range?.upperBound == 0 {
                if let r = operands[0].range, r.lowerBound > 0 {
                    operands[1].constrain(0...0, &visited)
                } else if let r = operands[1].range, r.lowerBound > 0 {
                    operands[0].constrain(0...0, &visited)
                }
            } else if op == "div" && range?.lowerBound == 0 && range!.upperBound == 0 {
                if let r = operands[1].range, r.lowerBound == r.upperBound && r.lowerBound > 0 {
                    operands[0].constrain(Int.min...(r.lowerBound-1), &visited)
                }
            } else {
                operands.forEach({ $0.constrain(Int.min...Int.max, &visited) })
            }
            
            /*
                
            if (op == "add" && range != nil && range?.lowerBound == 0) {
                    print("add, value at min of range")
                    operands.forEach({ $0.constrain($0.range!.lowerBound, &visited) })
                } else if (op == "mul" && value == 0) {
                    if let r = operands[0].range, r.lowerBound > 0 {
                        operands[0].constrain(Int.max, &visited)
                        operands[1].constrain(0, &visited)
                    } else if let r = operands[1].range, r.lowerBound > 0 {
                        operands[0].constrain(0, &visited)
                        operands[1].constrain(Int.max, &visited)
                    }
                } else if (op == "eql" && value == 0) {
                    if case let .literal(v) = operands[0].p {
                        operands[0].constrain(nil, &visited)
                        operands[1].constrain(v, &visited)
                    } else if case let .literal(v) = operands[1].p {
                        operands[0].constrain(v, &visited)
                        operands[1].constrain(nil, &visited)
                    }
                } else if op == "div" && value == 0 {
                    //
                    //operands[1].constrain(nil, &visited)
                }
                else {
                    operands.forEach({ $0.constrain(nil, &visited) })
                }
            } else {
                operands.forEach({ $0.constrain(nil, &visited) })
            }*/
        }
    }
    
    func constrain(_ value: Int) {
        var visited = [Int: ClosedRange<Int>]()
        constrain(value...value, &visited)
    }
    
    func uniqueCount(_ visited: inout Set<Int>) -> Int {
        guard visited.insert(self.id).inserted else {
            return 0
        }
        if case let .op(op, operands) = self.p {
            if case .input = operands[0].p {
                print("input used on left of \(op)")
            }
            if case .input = operands[1].p {
                print("input used on right of \(op)")
            }
            
            
            return 1 + operands.map({ $0.uniqueCount(&visited) }).reduce(0, { $0 + $1 })
        }
        return 0
    }
    
    /*
    func visit<R>(handle: (AluExpression, [R]) -> R) {
        
    }
    
    func visit<R>(_ visited: inout Set<Int>) -> Int {
        guard visited.insert(self.id).inserted else {
            return 0
        }
    }*/
    
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
    
    var count: Int {
        if case let .op(_, operands) = self {
            return operands.map({ $0.p.count }).reduce(0, { $0 + $1 })
        } else {
            return 1
        }
    }
}

struct AluState: Equatable {
    var registers = [Int](repeating: 0, count: 4)
    var ip = 0
    var valid = true
}

enum AluOperand: CustomStringConvertible {
    case register(r: Int)
    case literal(v: Int)
    
    init(_ s: String) {
        if let i = ["w", "x", "y", "z"].firstIndex(of: s) {
            self = .register(r: i)
        } else {
            self = .literal(v: Int(s)!)
        }
    }
    
    var description: String {
        switch self {
        case let .register(r): return ["w", "x", "y", "z"][r]
        case let .literal(v): return String(v)
        }
    }
    
    func evaluate(_ state: inout AluState) -> Int {
        switch self {
        case let .register(r): return state.registers[r]
        case let .literal(v): return v
        }
    }
    
    func staticValue(_ knownValues: [Int?]) -> Int? {
        switch self {
        case let .register(r): return knownValues[r]
        case let .literal(v): return v
        }
    }
}

struct AluOperator: CustomStringConvertible {
    var op: String
    var operands: [AluOperand]
    
    var description: String {
        return op + " " + operands.map({ $0.description }).joined(separator: " ")
    }
    
    init(_ s: String) {
        let pieces = s.split(separator: " ")
        op = String(pieces[0])
        operands = pieces[1...].map({ AluOperand(String($0)) })
    }
    
    func evaluate(_ operands: [Int]) -> Int? {
        switch op {
        case "add": return operands[0] + operands[1]
        case "mul": return operands[0] * operands[1]
        case "div" : if (operands[1] == 0) {
            return nil
        } else {
            return operands[0] / operands[1]
        }
        case "mod": if (operands[0] < 0 || operands[1] <= 0) {
            return nil
        } else {
            return (operands[0] % operands[1])
        }
        case "eql": return (operands[0] == operands[1] ? 1 : 0)
        default: assert(false, "invalid operator \(op)")
        }
        return nil
    }
    
    func evaluate(_ state: inout AluState, nextInput: Int?) -> AluState {
        var result = state
        func store(_ v: Int) {
            if case let AluOperand.register(r) = operands[0] {
                result.registers[r] = v
            }
        }
        
        if op == "inp" {
            store(nextInput!)
        } else {
            if let v = evaluate(operands.map({ $0.evaluate(&state) })) {
                store(v)
            } else {
                result.valid = false
            }
        }
        
        result.ip = result.ip + 1
        
        return result
    }
    
}

struct SearchState {
    var z: Int
    //var input: [Int]
    var inputAsNumber: Int
}


/*
class AluProgram {
    var operators: [AluOperator]
    
    init(_ ops: [AluOperator]) {
        operators = ops
    }
}

struct AluSearchState: Comparable {
    var aluState: AluState = AluState()
    var score: Int = 0
    var inputDigit = 13
    
    mutating func explore(_ program: AluProgram) -> [AluSearchState] {
        if (program.operators[aluState.ip].op == "inp") {
            return (1...9).map({ input -> AluSearchState in
                let ns = program.operators[aluState.ip]
                return AluSearchState(
                    aluState: ns.evaluate(&aluState, nextInput: input),
                    // Uhm?
                    score: score + (input * (pow(10, inputDigit) as NSDecimalNumber).intValue),
                    inputDigit: inputDigit - 1
                )
            })
        } else {
            return [AluSearchState(
                aluState: program.operators[aluState.ip].evaluate(&aluState, nextInput: nil),
                score: score,
                inputDigit: inputDigit)].filter({ $0.aluState.valid })
        }
    }
    
    static func == (lhs: AluSearchState, rhs: AluSearchState) -> Bool {
        return lhs.aluState == rhs.aluState && lhs.score == rhs.score && lhs.inputDigit == rhs.inputDigit
    }
    
    static func < (lhs: AluSearchState, rhs: AluSearchState) -> Bool {
        return lhs.score < rhs.score
    }
}*/

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
    let xxx = lines[0] == lines[18]
    print("XXX \(xxx)")
    //for j in 1..{
    //    if lines[0..<18] == lines[(j*18)..<(j*18 + 18)] {
    //        print("\(j) OK")
    //    }
    //}
    
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
            
            for _ in 1...10 {
                let (nf, changed) = f.optimize()
                if (!changed) {
                    break
                }
                f = nf
            }
            
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
        
    //print(registerValues[3].treeString())
    
   
    
    //f.constrain(0)
    
    //print(f.treeString())
    
    /*
    var count = 0
outer:
    while true {
        if count % 10000 == 0 {
            print(candidate)
        }
        count += 1
        let v = f.evaluate(candidate)
        if v == 0 {
            print("Found", candidate)
            break
        }
        var i = candidate.count - 1
        while i >= 0 {
            candidate[i] -= 1
            if candidate[i] >= 1 {
                break
            }
            candidate[i] = 9
            i -= 1
            if i < 0 {
                break outer
            }
        }
    }*/
    
    
    /*
    for a in 1...9 {
        for b in 1...9 {
            for c in 1...9 {
                candidate[0] = a
                candidate[1] = b
                candidate[2] = c
                let r = f.evaluate(candidate) == 0 ? 0 : 1
                if r == 0 {
                    print("we're done")
                }
            }
        }
    }*/
    
    
    //print(f.evaluate(candidate))
    
    //f.constrain(0)
    
    //print(f.treeString())
    
    //f.constrain(0)
    
    
    //print(f)
    
    //registerValues.forEach({ print($0.p.count) })
    
    
    
    
    
    //var operators = lines.map({ AluOperator($0) })
    //print("\(operators.count) operators")
    //let program = AluProgram(operators)
    
    /*
    
    
    var knownValues = [Int?](repeating: 0, count: 4)
    
    var i = 0
    while i < operators.count {
        let c = operators[i]
        print("i = \(i): \(c) \(knownValues)")
        
        if c.op == "div" {
            if case .literal(1) = c.operands[1] {
                // Division by 1 has no effect, drop it
                operators.remove(at: i)
                continue
            }
        }
        
        if c.op == "inp", case let .register(r) = c.operands[0] {
            knownValues[r] = nil
        } else if let kl = c.operands[0].staticValue(knownValues), let kr = c.operands[1].staticValue(knownValues) {
            // Both operands are statically known
            if case let .register(r) = c.operands[0] {
                knownValues[r] = c.evaluate([kl, kr])
            }
            operators.remove(at: i)
            continue
        } else if c.op == "mul", let kr = c.operands[1].staticValue(knownValues), kr == 0 {
            if case let .register(r) = c.operands[0] {
                knownValues[r] = 0
            }
            operators.remove(at: i)
            continue
        } else if case let .register(r) = c.operands[0] {
            print("Resetting \(r)")
            knownValues[r] = nil
        }
        
        i += 1
    }
    
    print("\(operators.count) operators after optimization")
    operators.forEach({ print($0) })*/
     
    
    
    /*
    let constraints = [
        [],
        [],
        [],
        [0]
    ]
    let inputContstraints = [
    ]
    */
    
    /*
    
    
    let input = "99999999999999".map({ Int(String($0))! })
    //let input = [13]

    
    var searchState = AluSearchState()
    
    var queue = PriorityQueue<AluSearchState>(ascending: false, startingValues: [searchState])
    
    while !queue.isEmpty {
        //print("In queue: \(queue.count)")
        var s = queue.pop()!
        //print(s)
        if (s.aluState.ip == program.operators.count) {
            if (s.aluState.registers[3] == 0) {
                print("Final state: \(s)")
                break;
            } else {
                continue;
            }
            
        }
        s.explore(program).forEach({ queue.push($0)})
    }*/
    
    /*
    
    var e = searchState.explore(program)
    e.forEach({ print($0) })
    
    print("----")
    
    print(e[0].explore(program))*/
    
    
    /*
    
    var state = AluState()
    var i = 0
    
    while state.ip < program.operators.count && state.valid {
        print("ip = \(state.ip): \(program.operators[state.ip])")
        if program.operators[state.ip].op == "inp" {
            state = program.operators[state.ip].evaluate(&state, nextInput: input[i])
            i += 1
        } else {
            state = program.operators[state.ip].evaluate(&state, nextInput: nil)
        }
        print(state)
    }*/
    
    
    //print(input)
    
    //print(operators)
}
