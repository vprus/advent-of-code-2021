
import Foundation
import Algorithms
import simd

// The default simd_int will truncate doubles.
func rounded_simd_int(_ s: simd_double3) -> simd_int3 {
    return simd_int3(Int32(s.x.rounded(.toNearestOrEven)),
                     Int32(s.y.rounded(.toNearestOrEven)),
                     Int32(s.z.rounded(.toNearestOrEven)))
}

struct Scanner {
    var readings: [simd_double3]
    var delta = simd_double3(0.0, 0.0, 0.0)
    
    func intersect(_ b: inout Scanner) -> Bool {
        for t in Scanner.transformations {
            var deltas = [simd_int3: Int]()
            for ar in readings {
                for br in b.readings {
                    deltas[rounded_simd_int(ar - t.act(br)), default: 0] += 1
                }
            }
            
            if let entry = deltas.first(where: { $0.value >= 12 }) {
                b.normalize(q: t, delta: simd_double(entry.key))
                return true
            }
        }
        return false
    }
    
    mutating func normalize(q: simd_quatd, delta: simd_double3) {
        self.delta = delta
        readings = readings.map { q.act($0) + delta}
    }
    
    static var transformations: [simd_quatd] = {
        let angles = [0.0, 90.0, 180.0, 270.0]
        let v = simd_double3(1, 2, 3)
        var results = Set<simd_int3>()
        var transformations = [simd_quatd]()
        
        for rz in angles {
            let qz = simd_quatd(angle: rz * .pi / 180, axis: simd_double3(0, 0, 1)).normalized
            for ry in angles {
                let qy = simd_quatd(angle: ry * .pi / 180, axis: simd_double3(0, 1, 0)).normalized
                for rx in angles {
                    let qx = simd_quatd(angle: rx * .pi / 180, axis: simd_double3(1, 0, 0)).normalized
                    let v3 = (qz * qy * qx).act(v)
                    let v3i = rounded_simd_int(v3)
                    if results.insert(v3i).inserted {
                        transformations.append(qz * qy * qx)
                    }
                }
            }
        }
        
        return transformations
    }()
}


func day19() throws {
    let lines = try input(day: 19)
    var scanners = lines.split(whereSeparator: { $0.starts(with: "---") }).map { scannerStrings in
        Scanner(readings: scannerStrings.map { reading in
            let v = reading.split(separator: ",").map({ Double($0)! })
            return simd_double3(v[0], v[1], v[2])
        })
    }
   
    var visited = Set<Int>()
    var positions = Set<simd_int3>()
    func traverse(_ i: Int) {
        scanners[i].readings.forEach { positions.insert(rounded_simd_int($0)) }
        visited.insert(i)
        for j in 0..<scanners.count {
            if !visited.contains(j) {
                if scanners[i].intersect(&scanners[j]) {
                    print("Matched \(i) and \(j)")
                    traverse(j)
                }
            }
        }
    }
    traverse(0)
    print("Part 1: \(positions.count)")
    
    let mmd = product(scanners, scanners).map({ (s1: Scanner, s2: Scanner) -> Int in
        let d = (s1.delta - s2.delta)
        return abs(Int(d.x)) + abs(Int(d.y)) + abs(Int(d.z))
    }).max()
    print("Part 2: \(mmd!)")
}
