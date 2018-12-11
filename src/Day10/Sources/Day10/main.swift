import Shared
import Foundation

// Both parts

struct Point {
    var x: Int
    var y: Int
    var dx: Int
    var dy: Int

    mutating func move(n: Int) {
        x += n * dx
        y += n * dy
    }

    static func distance(p1: Point, p2: Point) -> Int {
        return abs(p1.x - p2.x) + abs(p1.y - p2.y)
    }
}

extension Array where Element == Point {
    mutating func move(n: Int) {
        for i in 0..<self.count {
            self[i].move(n: n)
        }
    }

    func maxDistance() -> Int {
        var maxDist = -1
        for p1 in self {
            for p2 in self {
                maxDist = Swift.max(maxDist, Point.distance(p1: p1, p2: p2))
            }
        }

        return maxDist
    }
}

func printPoints(points: [Point]) {
    if let minX = points.min(by: { $0.x < $1.x }),
       let minY = points.min(by: { $0.y < $1.y }),
       let maxX = points.min(by: { $0.x > $1.x }),
       let maxY = points.min(by: { $0.y > $1.y }) {
        let w = maxX.x - minX.x + 1
        let h = maxY.y - minY.y + 1
        let row = Array<Character>(repeating: ".", count: w)
        var grid = Array<Array<Character>>(repeating: row, count: h)
        for p in points {
            grid[p.y - minY.y][p.x - minX.x] = "#"
        }

        for y in 0..<h {
            for x in 0..<w {
                print(grid[y][x], separator: "", terminator: "")
            }
            print()
        }
    }
}

if let input: [String] = readInput(day: 10) {
    var points: [Point] = []
    for line in input {
        let scanner = Scanner(string: line)
        var x = 0
        var y = 0
        var dx = 0
        var dy = 0
        scanner.scanString("position=<", into: nil)
        scanner.scanInt(&x)
        scanner.scanString(",", into: nil)
        scanner.scanInt(&y)
        scanner.scanString("> velocity=<", into: nil)
        scanner.scanInt(&dx)
        scanner.scanString(",", into: nil)
        scanner.scanInt(&dy)
        let point = Point(x: x, y: y, dx: dx, dy: dy)
        points.append(point)
    }

    let toMove: Int
    // First, move the points such that they are within 10000 of the 0-point
    if let firstPoint = points.first {
        if firstPoint.dx != 0 {
            toMove = abs(firstPoint.x / firstPoint.dx) / 10000 * 10000
        } else {
            toMove = abs(firstPoint.y / firstPoint.dy) / 10000 * 10000
        }

        points.move(n: toMove)
    } else {
        toMove = 0
    }

    // Now keep moving until the max distance increases again
    var currentDistance = points.maxDistance()
    var stop = false
    var moves = toMove
    repeat {
        points.move(n: 1)
        let newDistance = points.maxDistance()
        if newDistance > currentDistance {
            stop = true
        }
        currentDistance = newDistance
        moves += 1
    } while !stop

    // Move back once
    points.move(n: -1)

    // Print the grid
    printPoints(points: points)
    print(moves - 1)
}