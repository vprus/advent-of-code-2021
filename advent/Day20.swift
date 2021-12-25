
import Foundation
import Algorithms

func day20() throws {
    let lines = try input(day: 20)
    let algorithmLine = lines[0]
    let imageLines = lines[1...]
    
    let algorithm = algorithmLine.map({ $0 == "#" ? 1 : 0 })
    let imageArray = imageLines.map({ $0.map { $0 == "#" ? 1 : 0 } })
    
    var defaultCharacter = 0
    var imageDictionary = [RC: Int]()
    for row in 0..<imageArray.count {
        for column in 0..<imageArray[row].count {
            imageDictionary[RC(row: row, column: column)] = imageArray[row][column]
        }
    }
    
    func enhance() {
        let (rowMin, rowMax) = imageDictionary.map({ $0.key.row }).minAndMax()!
        let (colMin, colMax) = imageDictionary.map({ $0.key.column }).minAndMax()!
        var result = [RC: Int]()
        for row in (rowMin-1)...(rowMax+1) {
            for col in (colMin-1)...(colMax+1) {
                let bits = product([-1, 0, 1], [-1, 0, 1]).map { imageDictionary[RC(row: row + $0.0, column: col + $0.1), default: defaultCharacter] }
                let index = bits.reduce(0, { $0 * 2 + $1 })
                result[RC(row: row, column: col)] = algorithm[index]
            }
        }
        defaultCharacter = algorithm[[Int](repeating: defaultCharacter, count: 9).reduce(0, { $0 * 2 + $1 })]
        imageDictionary = result
    }
    
    for _ in 1...2 { enhance() }
    print(imageDictionary.countIf({ $0.value > 0}))
    for _ in 1...48 { enhance() }
    print(imageDictionary.countIf({ $0.value > 0}))
}

/*
 
 func printImage() {
     let (rowMin, rowMax) = imageDictionary.map({ $0.key.row }).minAndMax()!
     let (colMin, colMax) = imageDictionary.map({ $0.key.column }).minAndMax()!
     
     for row in (rowMin-5)...(rowMax+5) {
         for col in (colMin-5)...(colMax+5) {
             let p = imageDictionary[RC(row: row, column: col), default: 0]
             if p > 0 {
                 print("#", terminator: "")
             } else {
                 print(".", terminator: "")
             }
         }
         print("")
     }
 }
 
 */
