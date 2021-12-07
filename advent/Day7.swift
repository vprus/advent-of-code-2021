
import Foundation
import Algorithms

func day7() throws {
    print(FileManager.default.currentDirectoryPath)
    
    let input = (try input(day: 7))[0].components(separatedBy: ",").map { Int($0)! }
    
    let (min, max) = input.minAndMax(by: <)!
    let range = min...max // you can only create range using ... syntax.
    
    let optimal_step1 = range.map({ guess in
        input.map({ abs($0 - guess)}).reduce(0, { $0 + $1 })
    }).min()
    print(optimal_step1!)

    let optimal_step2 = range.map({ guess in
        input.map({
            let distance = abs($0 - guess)
            // sum of arithmetic sequence from 0 to distance.
            return distance * (distance + 1) / 2
        }).reduce(0, { $0 + $1 })
    }).min()
    print(optimal_step2!)
}
