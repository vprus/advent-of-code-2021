
import Foundation

class Dice {
    func roll() -> Int {
        let r = next;
        rolls += 1;
        next += 1
        if (next > 100) {
            next = 1;
        }
        return r;
    }
    
    var next = 1;
    var rolls = 0;
}

class Player {
    init(position: Int) {
        self.position = position
    }
    
    func move(dice: Int) {
        position = (position + dice) % 10
        score += (position + 1)
    }
    
    var position: Int
    var score: Int = 0
}
func day21() throws {
    var p1 = Player(position: 4 - 1)
    var p2 = Player(position: 7 - 1)
    var dice = Dice()
    while true {
        let d1 = dice.roll() + dice.roll() + dice.roll()
        p1.move(dice: d1)
        if (p1.score >= 1000) {
            print("Part 1: \(p2.score * dice.rolls)")
            break
        }
        let d2 = dice.roll() + dice.roll() + dice.roll()
        p2.move(dice: d2)
        if (p2.score >= 1000) {
            print("Part 2: \(p1.score * dice.rolls)")
            break
        }
    }
}
