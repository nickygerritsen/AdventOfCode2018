import Shared
import Foundation

enum Square {
    case floor
    case wall
    case door
    case possibleDoor
}

extension Square: CustomStringConvertible {
    public var description: String {
        switch self {
        case .floor:
            return "."
        case .wall:
            return "#"
        case .door:
            return "+"
        case .possibleDoor:
            return "?"
        }
    }
}

enum Direction: Character {
    case N = "N"
    case E = "E"
    case S = "S"
    case W = "W"
}

struct Grid {
    var squares: [[Square]]

    init(size: Int) {
        let row = [Square](repeating: .floor, count: size * 2 + 1)
        squares = [[Square]](repeating: row, count: size * 2 + 1)

        for y in 0..<size * 2 + 1 {
            for x in 0..<size * 2 + 1 {

                if y % 2 == 1 && x % 2 == 0 && x > 0 && x < size * 2 {
                    squares[y][x] = .possibleDoor
                } else if x % 2 == 1 && y % 2 == 0 && y > 0 && y < size * 2 {
                    squares[y][x] = .possibleDoor
                } else if y % 2 == 0 || x % 2 == 0 {
                    squares[y][x] = .wall
                }
            }
        }
    }

    func print(start: Point) {
        for y in 0..<squares.count {
            for x in 0..<squares[y].count {
                if start == Point(x: x, y: y) {
                    Swift.print("X", separator: "", terminator: "")
                } else {
                    Swift.print(squares[y][x], separator: "", terminator: "")
                }
            }
            Swift.print()
        }

        Swift.print()
    }
}

extension Grid {
    subscript(index: Point) -> Square {
        get {
            return squares[index.y][index.x]
        }
        set {
            squares[index.y][index.x] = newValue
        }
    }
}

struct Point {
    let x: Int
    let y: Int
}

extension Point: Hashable {
    public func hash(into hasher: inout Hasher) {
        x.hash(into: &hasher)
        y.hash(into: &hasher)
    }
}

extension Point {
    static func +(lhs: Point, rhs: Point) -> Point {
        return Point(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
}

let directions: [Direction: Point] = [
    .N: Point(x: 0, y: -1),
    .E: Point(x: 1, y: 0),
    .S: Point(x: 0, y: 1),
    .W: Point(x: -1, y: 0)
]

var grid: Grid = Grid(size: 0)
let directionChars = Set<Character>("NESW")

func goDirection(char: Character, start: Point) -> Point {
    if let d = Direction(rawValue: char),
       let dir = directions[d] {
        grid[start + dir] = .door
        return start + dir + dir
    } else {
        exit(2)
    }
}


class Graph {
    var edges: [Point: Set<Point>] = [:]

    func addEdge(from: Point, to: Point) {
        var currentEdges = edges[from] ?? []
        currentEdges.insert(to)
        edges[from] = currentEdges
    }
}

if let input: String = readInput(day: 20) {
    let graph = Graph()
    var positions: Set<Point> = [Point(x: 0, y: 0)]
    var ends = Set<Point>()
    var starts: Set<Point> = [Point(x: 0, y: 0)]
    var stacks: [(Set<Point>, Set<Point>)] = []

    let path = [Character](input[input.index(after: input.startIndex)..<input.index(before: input.index(before: input.endIndex))])
    for c in path {
        if c == "|" {
            // OR: update endpoints and restart group
            ends.formUnion(positions)
            positions = starts
        } else if directionChars.contains(c) {
            // Just move: add edges and update positions
            if let d = Direction(rawValue: c), let direction = directions[d] {
                for p in positions {
                    graph.addEdge(from: p, to: p + direction)
                }
                positions = Set(positions.map({ $0 + direction }))
            } else {
                exit(1)
            }
        } else if c == "(" {
            // Start branch: add positions as start of group
            stacks.append((starts, ends))
            starts = positions
            ends = []
        } else if c == ")" {
            // End branch: finish group, add positions as possible ends
            positions.formUnion(ends)
            if let elem = stacks.popLast() {
                (starts, ends) = elem
            } else {
                exit(2)
            }
        }
    }

    // Now we need to calculate the distances
    var distances: [Point: Int] = [:]

    var q: [(Point, Int)] = []
    q.append((Point(x: 0, y: 0), 0))
    while !q.isEmpty {
        let elem = q.removeFirst()
        distances[elem.0] = elem.1

        if let edges = graph.edges[elem.0] {
            for p in edges {
                if distances[p] == nil {
                    q.append((p, elem.1 + 1))
                }
            }
        }
    }

    print(distances.max(by: {$0.value < $1.value})!.value)
    var cnt = 0
    for d in distances {
        if d.value >= 1000 {
            cnt += 1
        }
    }
    print(cnt)
}