import Shared
import Foundation

enum Square {
    case open
    case tree
    case lumberyard
}

extension Square: CustomStringConvertible {
    public var description: String {
        switch self {
        case .open:
            return "."
        case .tree:
            return "|"
        case .lumberyard:
            return "#"
        }
    }
}

extension Square {
    func nextValue(adjacent: [Square]) -> Square {
        switch self {
        case .open:
            return adjacent.filter({ $0 == .tree }).count >= 3 ? .tree : .open
        case .tree:
            return adjacent.filter({ $0 == .lumberyard }).count >= 3 ? .lumberyard : .tree
        case .lumberyard:
            return (adjacent.filter({ $0 == .lumberyard }).count >= 1 && adjacent.filter({ $0 == .tree }).count >= 1) ? .lumberyard : .open
        }
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

    subscript(index: Point) -> Square {
        get {
            return self[index.y][index.x]
        }
        set {
            self[index.y][index.x] = newValue
        }
    }

    func adjacent(point: Point) -> [Square] {
        var squares = [Square]()
        for x in -1...1 {
            for y in -1...1 {
                if x != 0 || y != 0 {
                    squares.append(self[point + Point(x: x, y: y)])
                }
            }
        }

        return squares
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

if let input: [String] = readInput(day: 18) {
    let row = Array<Square>(repeating: .open, count: input[0].count + 2)
    var grid = Array<Array<Square>>(repeating: row, count: input.count + 2)

    for y in 0..<input.count {
        let line = Array(input[y])
        for x in 0..<line.count {
            let c = line[x]
            switch c {
            case ".":
                grid[y + 1][x + 1] = .open
            case "|":
                grid[y + 1][x + 1] = .tree
            case "#":
                grid[y + 1][x + 1] = .lumberyard
            default:
                // Nothing
                break
            }
        }
    }

    var answers: [Int: Int] = [:]

    for i in 1...1000 {
        var newGrid = grid
        for y in 1..<grid.count - 1 {
            for x in 1..<grid[y].count - 1 {
                newGrid[y][x] = grid[y][x].nextValue(adjacent: grid.adjacent(point: Point(x: x, y: y)))
            }
        }
        grid = newGrid

        var trees = 0
        var lumberyard = 0
        for y in 1..<grid.count - 1 {
            for x in 1..<grid[y].count - 1 {
                if grid[y][x] == .lumberyard {
                    lumberyard += 1
                } else if grid[y][x] == .tree {
                    trees += 1
                }
            }
        }

        answers[i] = trees * lumberyard
    }

    print(answers[10]!)

    // The whole thing starts repeating with an interval of 28 somewhere between 600 and 1000, so now we can interpolate
    let needed = 1000000000
    let mod = (needed - 1000) % 28
    print(answers[1000 - 28 + mod]!)
}