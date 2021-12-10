//
//  Day10.swift
//  advent
//
//  Created by Vladimir Prus on 10.12.2021.
//

import Foundation
import Algorithms

extension Sequence where Element == Int {
    func median() -> Int {
        let s = sorted()
        if s.count % 2 == 1 {
            return s[s.count / 2]
        } else {
            return (s[s.count / 2] + s[s.count / 2] + 1) / 2
        }
    }
}

func handleLine(_ s: String) -> (Int?,String?) {
    var stack = Array<String>()
    let closingToOpening = [")": "(", "}": "{", "]": "[", ">": "<"]
    let openingToClosing = reverseDictionary(closingToOpening)
    let penalties = [")": 3, "]": 57, "}": 1197, ">": 25137]
    for c_ in s {
        // It's awkward to use Character; e.g. one can't even create literal Character for maps above,
        // so just convert to String.
        let c = String(c_)
        if let expected = closingToOpening[c] {
            if stack.last! == expected {
                let _ = stack.popLast()
            } else {
                return (penalties[c], nil)
            }
        } else {
            stack.append(c)
        }
    }
    return (nil, stack.reversed().map({ openingToClosing[$0]! }).joined())
}

func day10() throws {
    let lines = try input(day: 10)
    
    let processed = lines.map({ handleLine($0) })
    print(processed.compactMap({ $0.0 }).reduce(0, { $0 + $1 }))
    let penalties = [")": 1, "]": 2, "}": 3, ">": 4]
    print(processed.compactMap({ $0.1 }).map({ completion in
        completion.reduce(0, { $0 * 5 + penalties[String($1)]! })
    }).median())
    
}
