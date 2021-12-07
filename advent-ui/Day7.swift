
import SwiftUI
import Algorithms

struct ChartScaler {
    var xBounds: (Int, Int)
    var yBounds: (Int, Int)
    var size: CGSize
    func callAsFunction(_ point: (Int, Int)) -> CGPoint {
        let scaledX = (CGFloat(point.0)-CGFloat(xBounds.0))/(CGFloat(xBounds.1) - CGFloat(xBounds.0))*size.width
        let scaledY = size.height - (CGFloat(point.1)/CGFloat(yBounds.1))*size.height
        return CGPoint(x: scaledX, y: scaledY)
    }
}

struct Day7: View {

    var points: [(Int, Int)] { get throws {
        let input = [16,1,2,0,4,2,7,1,2,14]

        let (min, max) = input.minAndMax(by: <)!
        let range = min...max

        let optimal_step1 = range.map({ guess in
            (guess, input.map({ abs($0 - guess)}).reduce(0, { $0 + $1 }))
        })
        return optimal_step1
    }}

    var body: some View {
        let points = try! self.points
        let xBounds = points.map { $0.0 }.minAndMax()!
        let yBounds = points.map { $0.1 }.minAndMax()!

        return GeometryReader { geometry in

            let scaler = ChartScaler(xBounds: xBounds, yBounds: yBounds, size: geometry.size)

            Path { path in
                path.move(to: scaler(points[0]))
                for point in points {
                    path.addLine(to: scaler(point))
                }
            }
            .stroke(.green, lineWidth: 3.0)
            .background(Color(white: 0.2))

            Path { path in
                (0...5).forEach { i in
                    let y = CGFloat(i)/5*geometry.size.height
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: geometry.size.width, y: y))
                }
            }
            .stroke(.gray, lineWidth: 0.5)
        }
    }
}

struct Day7_Previews: PreviewProvider {
    static var previews: some View {
        Day7().frame(width: 640, height: 320)
    }
}
