
import Foundation
import Algorithms

indirect enum Expression : CustomStringConvertible {
    case literal(_ value: Int)
    case pair(_ l: Expression, _ r: Expression)
    
    var magnitude: Int {
        switch self {
        case let .literal(v): return v
        case let .pair(l, r): return 3 * l.magnitude + 2 * r.magnitude
        }
    }
    
    func increment(_ by: Int?, _ left: Bool) -> Expression {
        if by == nil {
            return self
        }
        switch self {
        case let .literal(v): return .literal(v + by!)
        case let .pair(l, r): if (left) {
            return .pair(l.increment(by, left), r)
        } else {
            return .pair(l, r.increment(by, left))
        }
        }
    }
    
    func explode(_ level: Int = 0) -> (Expression, Bool, Int?, Int?) {
        if case let .pair(.literal(l), .literal(r)) = self {
            if (level >= 4) {
                return (.literal(0), true, l, r)
            }
        }
        if case let .pair(l, r) = self {
            let (e1, s1, dl1, dr1) = l.explode(level + 1)
            if (s1) {
                return (.pair(e1, r.increment(dr1, true)), true, dl1, nil)
            }
            let (e2, s2, dl2, dr2) = r.explode(level + 1)
            if (s2) {
                return (.pair(e1.increment(dl2, false), e2), true, nil, dr2)
            }
        }
        return (self, false, nil, nil)
    }
    
    func split() -> (Expression, Bool) {
        switch self {
        case let .literal(v) where v >= 10: return (.pair(.literal(v/2), .literal((v+1)/2)), true)
        case .literal: return (self, false)
        case let .pair(l, r):
            let (el, sl) = l.split()
            if (sl) {
                return (.pair(el, r), true)
            }
            let (er, sr) = r.split()
            return (.pair(l, er), sr)
        }
    }
    
    func reduce() -> Expression {
        var r = self
        while true {
            let (e1, s1, _, _) = r.explode()
            r = e1
            if (s1) {
                continue
            }
            let (e2, s2) = r.split()
            r = e2
            if (s2) {
                continue
            }
            break
        }
        return r
    }
    
    var description: String {
        switch self {
        case .literal(let v): return "\(v)"
        case .pair(let l, let r): return "[\(l), \(r)]"
        }
    }
}

func parse(_ s: Substring) -> (Expression, Substring) {
    if s.first == "[" {
        let (l, s1) = parse(s.dropFirst())
        let (r, s2) = parse(s1.dropFirst())
        return (.pair(l, r), s2.dropFirst())
    } else {
        let number = s.prefix(while: { $0.isNumber })
        return (Expression.literal(Int(number)!), s.suffix(from: number.endIndex))
    }
}

func day18() throws {
    let lines = try input(day: 18)
    let expressions = lines.map { parse($0[$0.startIndex...]).0 }
    
    var r = expressions[0]
    for i in 1..<expressions.count {
        r = .pair(r, expressions[i]).reduce()
    }
    print(r.magnitude)
    
    var magnitudes = [Int]()
    for i in 0..<expressions.count {
        for j in (i+1)..<expressions.count {
            magnitudes.append(Expression.pair(expressions[i], expressions[j]).reduce().magnitude)
        }
    }
    print(magnitudes.max()!)
}
