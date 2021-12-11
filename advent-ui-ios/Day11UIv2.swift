
import SwiftUI

struct Day11UIv2: View {
    let initialState: Day11
    @State var state: Day11
    
    init() {
        initialState = day11_testData()
        state = initialState
    }
    
    func reset() {
        state = initialState
    }
    
    func step() {
        state = state.step()
    }
    
    var body: some View {
        VStack {
            Spacer()
            // Dragon #1: showing an array of data requires 'enumerated'.
            // Because the Binding turns array into a sequence, we need to
            // create Array again.
            ForEach(Array($state.board.enumerated()), id: \.0) { row in
                HStack {
                    Spacer()
                    ForEach(Array(row.1.enumerated()), id: \.0) { cell in
                        // Dragon #2: cell.1 here is Binding<Int>, we need to
                        // explicitly convert it back to Int for rendering.
                        Text(String(cell.1.wrappedValue))
                            .foregroundColor(.white)
                            .font(.system(.body, design: .monospaced))
                            // Dragon #3: without .wrappedValue, we get:
                            // The compiler is unable to type-check this expression in reasonable time
                            .shadow(color: .white, radius: (cell.1.wrappedValue == 0 ? 6 : 0))
                            // Dragon #4: here again we find that normal procedural code does
                            // not work inside SwiftUI, resulting in either code duplicaiton
                            // or having to invent 'conditional view modifiers' yourself.
                            .shadow(color: .white, radius: (cell.1.wrappedValue == 0 ? 6 : 0))
                            .shadow(color: .white, radius: (cell.1.wrappedValue == 0 ? 6 : 0))
                        Spacer()
                    }
                }
            }
            Spacer()
            HStack {
                Button(action: reset) {
                    Text("Reset")
                }
                .padding()
                Spacer()
                Button(action: step) {
                    Text("Step")
                }.padding()
            }.buttonStyle(.bordered)
        }.background(.black)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Day11UIv2()
    }
}
