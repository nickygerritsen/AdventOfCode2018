import Shared
import Foundation

struct Claim {
    let id: Int
    let x: Int
    let y: Int
    let w: Int
    let h: Int
}

extension Claim: Input {
    static func convert(contents: String) -> Claim? {
        let scanner = Scanner(string: contents)

        var id: Int = 0
        var x: Int = 0
        var y: Int = 0
        var w: Int = 0
        var h: Int = 0

        scanner.scanString("#", into: nil)
        scanner.scanInt(&id)
        scanner.scanString("@", into: nil)
        scanner.scanInt(&x)
        scanner.scanString(",", into: nil)
        scanner.scanInt(&y)
        scanner.scanString(":", into: nil)
        scanner.scanInt(&w)
        scanner.scanString("x", into: nil)
        scanner.scanInt(&h)

        return Claim(id: id, x: x, y: y, w: w, h: h)
    }
}

var row = Array<Array<Int>>(repeating: [], count: 1000)
var grid = Array<Array<Array<Int>>>(repeating: row, count: 1000)

if let input: [Claim] = readInput(day: 3) {
    for claim in input {
        for x in claim.x..<claim.x + claim.w {
            for y in claim.y..<claim.y + claim.h {
                grid[x][y].append(claim.id)
            }
        }
    }

    var cnt = 0
    for x in 0..<1000 {
        for y in 0..<1000 {
            if grid[x][y].count > 1 {
                cnt += 1
            }
        }
    }

    print(cnt)
}