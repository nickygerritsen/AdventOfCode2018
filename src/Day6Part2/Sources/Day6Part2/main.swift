import Shared
import Foundation

struct Point {
    let x: Int
    let y: Int

    static func distance(_ p1: Point, _ p2: Point) -> Int {
        return abs(p1.x - p2.x) + abs(p1.y - p2.y)
    }
}

extension Point: Input {
    static func convert(contents: String) -> Point? {
        let parts = contents.split(separator: ",")
        if let x = Int(parts[0]), let y = Int(parts[1].trimmingCharacters(in: .whitespacesAndNewlines)) {
            return Point(x: x, y: y)
        }
        return nil
    }
}

if let input: [Point] = readInput(day: 6) {
    var points: [Int: Point] = [:]
    for idx in 0..<input.count {
        points[idx] = input[idx]
    }

    let maxDistance = 10000
    // Determine the max distance we should check: this is maxDistance / #points
    let maxCheck = maxDistance / points.count

    var answer = 0

    if let maxXP = input.min(by: { $0.x > $1.x }),
       let maxYP = input.min(by: { $0.y > $1.y }) {
        let maxX = maxXP.x
        let maxY = maxYP.y

        for x in -maxCheck...maxX + maxCheck {
            for y in -maxCheck...maxY + maxCheck {
                let p = Point(x: x, y: y)
                let totalDistance = points.map({ Point.distance(p, $0.value) }).reduce(0, +)
                if totalDistance < maxDistance {
                    answer += 1
                }
            }
        }
    }

    print(answer)
}