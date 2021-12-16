
import Foundation

// Let's try to simulate numpy in Swift.
struct Matrix: CustomStringConvertible {
    var data: [[Int]]
    
    var rows: Int { return data.count }
    var columns: Int { return data[0].count }
 
    init(data: [[Int]]) {
        self.data = data
    }
    
    init(rows: Int, columns: Int) {
        self.data = [[Int]](repeating: [Int](repeating: 0, count: columns), count: rows)
    }
    
    subscript(r1: Int, r2: Int) -> Int {
        return data[r1][r2]
    }
    
    // Dragon #1: this will work only for half-ranges, created with 0..<10 syntax.
    // It will not work for 0...10, because that produces a totally unrelated type (ClosedRange),
    // and there's no protocol shared between Range and ClosedRange
    // It will not work for stride(from: 0, to: 10, by: 2), because it produces another totally
    // unrelated type, and because Array can't be indexed by stride.
    // I can't use Sequence for the types, because array can't be indexes by Sequence of indices.
    // All in all, Python is way more usable.
    subscript(r1: Range<Int>, r2: Range<Int>) -> Matrix {
        return Matrix(data: data[r1].map({Array($0[r2])}))
    }
    
    // Dragon #2: ideally, one should be able to write
    //
    //    m[r1, r2] += m2
    //
    // Possibly doable if 'subscript', above, returned a *view* into Matrix,
    // but that's out of my time budget.
    mutating func add(_ r1: Range<Int>, _ r2: Range<Int>, _ another: Matrix) {
        for (ri, r) in r1.enumerated() {
            for (ci, c) in r2.enumerated() {
                data[r][c] = data[r][c] + another.data[ri][ci]
            }
        }
    }
    
    mutating func appendRight(_ another: Matrix) {
        for r in 0...rows - 1 {
            data[r].append(contentsOf: another.data[r])
        }
    }
    
    mutating func appendBottom(_ another: Matrix) {
        data.append(contentsOf: another.data)
    }
    
    // Dragon #3: this would not be necessary in Python, since I can just use range
    // with negative stride. But as explained above, does not seem easily doable
    // in Swift.
    func flipTopBottom() -> Matrix {
        return Matrix(data: data.reversed())
    }
    
    func flipLeftRight() -> Matrix {
        return Matrix(data: data.map({$0.reversed()}))
    }
    
    func map(_ mapper: (Int) -> Int) -> Matrix {
        return Matrix(data: data.map({ $0.map(mapper) }))
    }
        
    var description: String {
        return data.map({
            $0.map({String($0)}).joined()
        }).joined(separator: "\n")
    }
}

// Add a few operations specific to the task.
extension Matrix {
    func foldY(y: Int) -> Matrix {
        var m1 = self[0..<y, 0..<columns]
        var m2 = self[y+1..<rows, 0..<columns].flipTopBottom()
        if (m1.rows < m2.rows) {
            swap(&m1, &m2)
        }
        m1.add((m1.rows - m2.rows)..<m1.rows, 0..<columns, m2)
        return m1
    }
    
    func foldX(x: Int) -> Matrix {
        var m1 = self[0..<rows, 0..<x]
        var m2 = self[0..<rows, (x+1)..<columns].flipLeftRight()
        if (m1.columns < m2.columns) {
            swap(&m1, &m2)
        }
        m1.add(0..<rows, (m1.columns - m2.columns)..<m2.columns, m2)
        return m1
     }
}

func day13() throws {
    let lines = try input(day: 13)
    
    let coordinateLines = lines.filter({ !$0.starts(with: "fold") })
    let foldLines = lines.filter({ $0.starts(with: "fold") })
    let coordinates = coordinateLines.map({ $0.components(separatedBy: ",")}).map({ (Int($0[0])!, Int($0[1])! )})
    let columns = coordinates.max(by: { $0.0 < $1.0 })!.0 + 1
    let rows = coordinates.max(by: { $0.1 < $1.1 })!.1 + 1
    var m = Matrix(rows: rows, columns: columns)
    for c in coordinates {
        m.data[c.1][c.0] = 1
    }
        
    for fold in foldLines {
        let fx = "fold along x="
        let fy = "fold along y="
        if (fold.starts(with: fx)) {
            // Dragon #4: While Swift might have good motivation to disallow int indexing for string,
            // the end result is quite ugly.
            let v: String = String(fold.suffix(from: fold.index(fold.startIndex, offsetBy: fx.count)))
            m = m.foldX(x: Int(v)!)
        } else if (fold.starts(with: fy)) {
            let v: String = String(fold.suffix(from: fold.index(fold.startIndex, offsetBy: fy.count)))
            m = m.foldY(y: Int(v)!)
        }
    }
    print(m)
}
