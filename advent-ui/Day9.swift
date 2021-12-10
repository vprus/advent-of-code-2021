
import SwiftUI

func getInput() -> [[Int]] {
    let url = Bundle.main.url(forResource: "day9-input", withExtension: "txt")!
    let lines = try! String(contentsOf: url).components(separatedBy: "\n")
   
    return lines.map({ $0.map { Int(String($0))! }})
}

struct Position: Hashable {
    var row: Int
    var column: Int
}

struct Day9: View {
    
    @State var input = getInput()
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State var highlights = Set<Position>()
    
    var body: some View {
        HStack {
            Text("Day 9: Smoke Basin").font(.largeTitle)
            Spacer()
        }
        HStack {
            Text("\(input.count) rows, \(input[0].count) columns")
            Spacer()
        }
        // Apparently, a 100x100 grid of Text is enough to make scrolling laggy,
        // and adding any attempt to coloring regions makes things worse.
        ScrollView([.horizontal, .vertical]) {
            VStack {
                ForEach(Array(input.enumerated()), id: \.0) { row in
                    HStack {
                        ForEach(Array(row.1.enumerated()), id: \.0) { n in
                            Text(String(n.1)).font(.system(.body, design: .monospaced))
                            // That's fairly ugly duplication, but a clusure inside SwiftUI
                            // can't declare variable and then return it, and
                            .foregroundColor(
                                highlights.contains(Position(row: row.0, column: n.0))  ? .green : .black
                            ).fontWeight(
                                highlights.contains(Position(row: row.0, column: n.0)) ? .bold : .regular
                            )
                        }
                    }
                }
            }
        }
        .onReceive(timer) { _ in
            var s = Set<Position>()
            for _ in 0...99 {
                s.insert(Position(row: Int.random(in: 0..<input.count), column: Int.random(in: 0..<input[0].count)))
            }
            highlights = s
        }
    }
}

struct Day9_Previews: PreviewProvider {
    static var previews: some View {
        Day9()
    }
}
