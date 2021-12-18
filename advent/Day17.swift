
import Foundation

func day17() throws {
    // Sorry, won't be parsing Day 17 input until Swift has proper regexps
    let min_x = 153
    let max_x = 199
    let min_y = -114
    let max_y = -75
    
    // If target spans y=0, we can set initial y velocity as high as we wish, since we'll still
    // return to y=0
    assert(min_y < 0 && max_y < 0, "If target spans y=0, infinite solutions exist")
    
    var matches = Set<String>()
    var heights = [Int]()
    for sy in (min_y - 1)...(-min_y + 1)
    {
        let height = sy * (sy + 1) / 2
        for sx in 1...(max_x + 10)
        {
            let final_x = sx * (sx + 1) / 2
            for steps in 1... {
                let y = steps * (sy + sy - steps + 1) / 2
                let x = steps >= sx ? final_x : (steps * (sx + sx - steps + 1) / 2)
                if (y < min_y) {
                    break
                }
                if min_x <= x && x <= max_x && min_y <= y && y <= max_y {
                    matches.insert("\(sx)-\(sy)")
                    heights.append(height)
                }
            }
        }
    }
    print(heights.max()!)
    print(matches.count)
}
