
import Foundation

extension Sequence {
    func countIf(_ predicate: (Self.Element) -> Bool) -> Int {
        var r = 0
        self.forEach {
            if predicate($0) {
                r += 1
            }
        }
        return r
    }
}

struct Day3 {
    
    static func findMetric(_ xdata: [Int], numDigits: Int, selectBit: (Int,Int) -> Int) throws -> Int {
        var data = xdata
        // The task starts with the left-most bit
        // Starting from the highest order bit
        // - compute the number of ones and zeroes.
        // - ask 'selectBit' which bit we want in that position
        // - select data with the desired value of the bit
        // - if only one data item remains, return it
        // - move to the next bit
        
        var digit = numDigits - 1
        while digit >= 0 {
            let mask = 1 << digit
            let countOfOnes = data.countIf { $0 & mask > 0 }
            let selectFor = selectBit(countOfOnes, data.count - countOfOnes) << digit
            data = data.filter { $0 & mask == selectFor }
            if data.count == 1 {
                return data[0]
            }
            
            digit -= 1
        }
        throw Errors.otherError(message: "Count not find a single item")
    }
    
    static func selectForOxygenGenerator(ones: Int, zeros: Int) -> Int {
        if ones > zeros {
            return 1
        } else if zeros > ones {
            return 0
        } else {
            return 1
        }
    }
    
    static func selectForCO2Scrubber(ones: Int, zeros: Int) -> Int {
        if ones < zeros {
            return 1
        } else if zeros < ones {
            return 0
        } else {
            return 0
        }
    }
    
    static func main() async throws {
                
        if let url = URL(string: "file:///Users/vladimir/Downloads/day3-input.txt") {
            var lines = [String]()
            for try await line in url.lines {
                lines.append(line)
            }
            let numDigits = lines[0].count
            guard lines.allSatisfy({ $0.count == numDigits }) else {
                throw Errors.otherError(message: "Input has inconsistent number of digits")
            }
            
            let data = lines.map { Int($0, radix: 2)! }
            
            try print(findMetric(data, numDigits: numDigits, selectBit: selectForOxygenGenerator) *
                      findMetric(data, numDigits: numDigits, selectBit: selectForCO2Scrubber))
        } else {
            print("Could not parse URL")
        }
    }
}
