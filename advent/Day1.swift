
import Foundation

class AsyncSlidingWindowIterator<Inner: AsyncIteratorProtocol>: AsyncIteratorProtocol {
    init(count: Int, iterator inner: Inner) {
        self.inner = inner
        self.count = count
    }
    func next() async throws -> [Inner.Element]? {
        if window == nil {
             // Fill in the window
            window = [Inner.Element]()
            for _ in 0..<count {
                let n: Inner.Element? = try await inner.next()
                if n == nil {
                    return nil
                }
                window!.append(n!)
            }
            return window
        } else {
            if let n = try await inner.next() {
                window!.remove(at: 0)
                window!.append(n)
                return window
            } else {
                return nil
            }
        }
    }
    
    private var inner: Inner
    private var count: Int
    private var window: [Inner.Element]? = nil
}

class AsyncSlidingWindowSequence<Inner: AsyncSequence>: AsyncSequence {
    typealias AsyncIterator = AsyncSlidingWindowIterator<Inner.AsyncIterator>
    typealias Element = [Inner.Element]
    
    init(count: Int, sequence inner: Inner) {
        self.count = count
        self.inner = inner
    }
    __consuming func makeAsyncIterator() -> AsyncIterator {
        AsyncIterator(count: count, iterator: inner.makeAsyncIterator())
    }
    
    private let count: Int
    private let inner: Inner
}

extension AsyncSequence {
    func slidingWindows(_ count: Int) -> AsyncSlidingWindowSequence<Self> {
        return AsyncSlidingWindowSequence<Self>(count: count, sequence: self)
    }
}

enum Errors: Error {
    case parseError(input: String)
}

@main
struct Day1 {
    static func main() async throws {
        
        if let url = URL(string: "file:///Users/vladimir/Downloads/day1-input.txt") {
            let windows = url.lines.map({ l -> Int in
                if let value = Int(l) {
                    return value
                } else {
                    throw Errors.parseError(input: l)
                }
            })
            .slidingWindows(3)
            .map({w -> Int in w[0] + w[1] + w[2]})
            .slidingWindows(2)
            // Without explicit types, the code below results in:
            //     The compiler is unable to type-check this expression in reasonable time;
            //     try breaking up the expression into distinct sub-expressions
            .map({(w: [Int]) -> Int in
                if w[1] > w[0] {
                    return 1
                } else {
                    return 0
                }
            })
            
            print(try await windows.reduce(0, {a, b in a + b}))
        } else {
            print("Could not parse URL")
        }
    }
}
