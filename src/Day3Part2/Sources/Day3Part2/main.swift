import Shared
import Foundation

struct Claim {
    let id: Int
    let x: Int
    let y: Int
    let w: Int
    let h: Int
}

func overlap(a1: Int, a2: Int, b1: Int, b2: Int) -> Bool {
    // If b1 is between a1 and a2, we have overlap
    if a1 < b1 && b1 < a2 {
        return true
    }
    // Same for b2
    if a1 < b2 && b2 < a2 {
        return true
    }
    // If b1 is before a1 and b2 is after a2, it also overlaps
    if b1 <= a1 && a2 <= b2 {
        return true
    }

    // Otherwise, no overlap
    return false
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

if let input: [Claim] = readInput(day: 3) {
    let nonOverlapped = input.filter({ i in
        return input.filter({ i2 in
            if i.id == i2.id {
                return false
            }
            return overlap(a1: i.x, a2: i.x + i.w, b1: i2.x, b2: i2.x + i2.w) &&
                    overlap(a1: i.y, a2: i.y + i.h, b1: i2.y, b2: i2.y + i2.h)
        }).isEmpty
    })

    print(nonOverlapped[0].id)
}