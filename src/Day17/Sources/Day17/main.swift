import Shared
import Foundation

enum Square {
    case sand
    case clay
    case waterflow
    case waterstill
    case waterstart
}

extension Square: CustomStringConvertible {
    public var description: String {
        switch self {
        case .sand:
            return "."
        case .clay:
            return "#"
        case .waterflow:
            return "~"
        case .waterstill:
            return "|"
        case .waterstart:
            return "+"
        }
    }

    var canHaveWater: Bool {
        return self == .sand
    }

    var canHaveWaterAbove: Bool {
        return self == .clay || self == .waterflow
    }

    var isWater: Bool {
        return self == .waterstill || self == .waterflow
    }
}

extension Array where Element == [Square] {
    func print() {
        for y in 0..<count {
            for x in 0..<self[y].count {
                Swift.print(self[y][x], separator: "", terminator: "")
            }
            Swift.print()
        }

        Swift.print()
    }

    var waterCount: Int {
        var cnt = 0
        for y in 0..<count {
            for x in 0..<self[y].count {
                if self[y][x].isWater {
                    cnt += 1
                }
            }
        }

        return cnt
    }

    var flowingWaterCount: Int {
        var cnt = 0
        for y in 0..<count {
            for x in 0..<self[y].count {
                if self[y][x] == .waterflow {
                    cnt += 1
                }
            }
        }

        return cnt
    }

    subscript(index: Point) -> Square {
        get {
            if index.y < 0 || index.y >= self.count {
                Swift.print("CRASH y")
                print()
                exit(2)
            }
            if index.x < 0 || index.x >= self[index.y].count {
                Swift.print("CRASH x")
                print()
                exit(2)
            }
            return self[index.y][index.x]
        }
        set {
            if index.y < 0 || index.y >= self.count {
                Swift.print("CRASH y")
                print()
                exit(3)
            }
            if index.x < 0 || index.x >= self[index.y].count {
                Swift.print("CRASH x")
                print()
                exit(3)
            }
            self[index.y][index.x] = newValue
        }
    }
}

struct Point {
    let x: Int
    let y: Int

    static func +(lhs: Point, rhs: Point) -> Point {
        return Point(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
}

extension Point: Hashable {
    public func hash(into hasher: inout Hasher) {
        x.hash(into: &hasher)
        y.hash(into: &hasher)
    }
}

// Find the spot where the water ends for this level
func findEnd(grid: [[Square]], current: Point, direction: Point) -> Point {
    let below = Point(x: 0, y: 1)
    // We check this by looking for the first spot were we have either sand below or clay to the side
    var spot = current
    repeat {
        if !grid[spot + below].canHaveWaterAbove {
            return spot
        } else if grid[spot + direction] == .clay {
            return spot
        }
        spot = spot + direction
    } while true
}

class Queue<T: Hashable> {
    var q: [T] = []

    func enqueue(_ t: T) {
        if q.contains(t) {
            return
        }
        q.append(t)
    }

    func dequeue() -> T {
        return q.removeFirst()
    }

    var isEmpty: Bool {
        return q.isEmpty
    }
}

if let input: [String] = readInput(day: 17) {
    var minX = Int.max
    var maxX = Int.min
    var minY = Int.max
    var maxY = Int.min

    for line in input {
        let scanner = Scanner(string: line)
        let firstIsX = scanner.scanString("x", into: nil)
        scanner.scanString("y", into: nil)
        scanner.scanString("=", into: nil)
        var first = 0
        scanner.scanInt(&first)
        scanner.scanString(", x=", into: nil)
        scanner.scanString(", y=", into: nil)
        var lower = 0
        var upper = 0
        scanner.scanInt(&lower)
        scanner.scanString("..", into: nil)
        scanner.scanInt(&upper)

        if firstIsX {
            minX = min(minX, first)
            maxX = max(maxX, first)
            minY = min(minY, lower)
            maxY = max(maxY, upper)
        } else {
            minY = min(minY, first)
            maxY = max(maxY, first)
            minX = min(minX, lower)
            maxX = max(maxX, upper)
        }
    }

    let row = Array<Square>(repeating: .sand, count: maxX - minX + 5)
    var grid = Array<Array<Square>>(repeating: row, count: maxY - minY + 2)

    for line in input {
        let scanner = Scanner(string: line)
        let firstIsX = scanner.scanString("x", into: nil)
        scanner.scanString("y", into: nil)
        scanner.scanString("=", into: nil)
        var first = 0
        scanner.scanInt(&first)
        scanner.scanString(", x=", into: nil)
        scanner.scanString(", y=", into: nil)
        var lower = 0
        var upper = 0
        scanner.scanInt(&lower)
        scanner.scanString("..", into: nil)
        scanner.scanInt(&upper)

        let xs: ClosedRange<Int>
        let ys: ClosedRange<Int>
        if firstIsX {
            xs = first...first
            ys = lower...upper
        } else {
            xs = lower...upper
            ys = first...first
        }

        for y in ys {
            for x in xs {
                grid[y - minY + 1][x - minX + 2] = .clay
            }
        }
    }

    grid[0][500 - minX + 2] = .waterstart

    let below = Point(x: 0, y: 1)
    let up = Point(x: 0, y: -1)
    let left = Point(x: -1, y: 0)
    let right = Point(x: 1, y: 0)

    var loop = 0
    let queue = Queue<Point>()
    queue.enqueue(Point(x: 500 - minX + 2, y: 1))
    while !queue.isEmpty {
        loop += 1
        let next = queue.dequeue()

        if next.y >= grid.count {
            continue
        }

        if grid[next].canHaveWater {
            // If we can have water here (and thus we do not have it yet) place water
            // First check if the spot below can have water. If so, our current water will be still for now
            if (next + below).y >= grid.count {
                // Special case: we are at the bottom
                grid[next] = .waterstill
            } else if grid[next + below].canHaveWater {
                grid[next] = .waterstill
                queue.enqueue(next + below)
            } else {
                // Determine if we are in a closed basin or if the water flows outside
                let leftEnd = findEnd(grid: grid, current: next, direction: left)
                let rightEnd = findEnd(grid: grid, current: next, direction: right)
                if grid[leftEnd + below].canHaveWaterAbove && grid[rightEnd + below].canHaveWaterAbove {
                    grid[next] = .waterflow
                    for x in leftEnd.x...next.x {
                        grid[next.y][x] = .waterflow
                    }
                    for x in next.x...rightEnd.x {
                        grid[next.y][x] = .waterflow
                    }
                    queue.enqueue(next + up)
                } else {
                    grid[next] = .waterstill
                    for x in leftEnd.x...next.x {
                        grid[next.y][x] = .waterstill
                    }
                    for x in next.x...rightEnd.x {
                        grid[next.y][x] = .waterstill
                    }
                    if grid[leftEnd + left] != .clay {
                        grid[leftEnd] = .waterstill
                        queue.enqueue(leftEnd + below)
                    }
                    if grid[rightEnd + right] != .clay {
                        grid[rightEnd] = .waterstill
                        queue.enqueue(rightEnd + below)
                    }
                }
            }
        } else if grid[next] == .waterstill && (next + below).y < grid.count {
            // We had water here already, but it is still. Maybe we can turn it into flowing water?
            let leftEnd = findEnd(grid: grid, current: next, direction: left)
            let rightEnd = findEnd(grid: grid, current: next, direction: right)
            if grid[leftEnd + below].canHaveWaterAbove && grid[rightEnd + below].canHaveWaterAbove {
                grid[next] = .waterflow
                for x in leftEnd.x...next.x {
                    grid[next.y][x] = .waterflow
                }
                for x in next.x...rightEnd.x {
                    grid[next.y][x] = .waterflow
                }
                queue.enqueue(next + up)
            } else {
                grid[next] = .waterstill
                for x in leftEnd.x...next.x {
                    grid[next.y][x] = .waterstill
                }
                for x in next.x...rightEnd.x {
                    grid[next.y][x] = .waterstill
                }
                if grid[leftEnd + left] != .clay {
                    grid[leftEnd] = .waterstill
                    queue.enqueue(leftEnd + below)
                }
                if grid[rightEnd + right] != .clay {
                    grid[rightEnd] = .waterstill
                    queue.enqueue(rightEnd + below)
                }
            }
        }
    }

    grid.print()
    print(grid.waterCount)
    print(grid.flowingWaterCount)
}