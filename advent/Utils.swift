
import Foundation

enum Errors: Error {
    case parseError(input: String)
    case otherError(message: String)
}

extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}

func input(day: Int) throws -> [String] {
    let content = try String(contentsOfFile: "/Users/vladimir/Downloads/day\(day)-input.txt")
    let lines = content.split(separator: "\n")
    return lines.map { String($0) }
    
    /*
    
    
    guard let url = URL(string: "file://") else {
        throw Errors.otherError(message: "Could not parse URL")
    }
                        
    DispatchQueue.global().async { () async -> [String] in
        // Note: url.lines appear to skip empty lines
        var lines: [String] = []
        for try await line in url.lines {
            lines.append(line)
        }
        return lines
    }
    
    return t.value*/
}
