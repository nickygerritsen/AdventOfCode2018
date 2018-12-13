import Shared
import Foundation

struct Point {
    var x: Int
    var y: Int
}

extension Point: Equatable {
    public static func ==(lhs: Point, rhs: Point) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }
}

extension Point: Comparable {
    public static func <(lhs: Point, rhs: Point) -> Bool {
        if lhs.y == rhs.y {
            return lhs.x < rhs.x
        } else {
            return lhs.y < rhs.y
        }
    }
}

enum Direction {
    case up
    case down
    case left
    case right

    var isVertical: Bool {
        return self == .up || self == .down
    }

    var nextOnIntersection: Direction {
        switch self {
        case .left:
            return .up
        case .up:
            return .right
        case .down:
            return .down
        case .right:
            return .left
        }
    }

    var rotateRight: Direction {
        switch self {
        case .up:
            return .right
        case .right:
            return .down
        case .down:
            return .left
        case .left:
            return .up
        }
    }

    var rotateLeft: Direction {
        switch self {
        case .up:
            return .left
        case .left:
            return .down
        case .down:
            return .right
        case .right:
            return .up
        }
    }

    func rotate(direction: Direction) -> Direction {
        if direction == .left {
            return self.rotateLeft
        } else if direction == .right {
            return self.rotateRight
        } else {
            return self
        }
    }
}

enum Track: Equatable {
    case none
    case vertical
    case horizontal
    case intersection
    case corner(Direction, Direction)
}

extension Track: CustomStringConvertible {
    public var description: String {
        switch self {
        case .none:
            return " "
        case .vertical:
            return "|"
        case .horizontal:
            return "-"
        case .intersection:
            return "+"
        case let .corner(d1, d2):
            switch (d1, d2) {
            case (.up, .right):
                return "\\"
            case (.down, .left):
                return "\\"
            case (.down, .right):
                return "/"
            case (.up, .left):
                return "/"
            default:
                return "?"
            }
        }
    }
}

extension Train: CustomStringConvertible {
    public var description: String {
        switch self.direction {
        case .up:
            return "^"
        case .down:
            return "v"
        case .left:
            return "<"
        case .right:
            return ">"
        }
    }
}

struct Train {
    let index: Int
    var position: Point
    var direction: Direction
    var nextIntersectionDirection: Direction

    init(index: Int, position: Point, direction: Direction) {
        self.index = index
        self.position = position
        self.direction = direction
        self.nextIntersectionDirection = .left
    }

    mutating func move(grid: [[Track]]) {
        switch direction {
        case .up:
            position.y -= 1
        case .down:
            position.y += 1
        case .left:
            position.x -= 1
        case .right:
            position.x += 1
        }

        // Now check if the train is on a special kind of track, i.e. corner or intersection
        switch grid[position.y][position.x] {
        case .none:
            fatalError("Train off track")
        case .intersection:
            direction = direction.rotate(direction: nextIntersectionDirection)
            nextIntersectionDirection = nextIntersectionDirection.nextOnIntersection
        case let .corner(d1, d2):
            // d1 is always up or down, d2 is always left or right
            assert(d1.isVertical)
            assert(!d2.isVertical)
            if direction.isVertical {
                // We are now vertical, so we should be going horizontal
                direction = d2
            } else {
                // We are now horizontal, so we should be going vertical
                direction = d1
            }
            break
        default:
            // Nothing
            break
        }
    }
}

func printTracks(grid: [[Track]], trains: [Train]) {
    for y in 0..<grid.count {
        let row = grid[y]
        for x in 0..<row.count {
            let position = Point(x: x, y: y)
            let trainsAtPosition = trains.filter {
                $0.position == position
            }
            if trainsAtPosition.count > 1 {
                print("X", separator: "", terminator: "")
            } else if let trainAtPosition = trainsAtPosition.first {
                if row[x] == .none {
                    fatalError("FOUT")
                }
                print(trainAtPosition, separator: "", terminator: "")
            } else {
                print(row[x], separator: "", terminator: "")
            }
        }
        print()
    }
    print()
}

func crashPosition(grid: [[Track]], trains: [Train]) -> Point? {
    for train in trains {
        assert(grid[train.position.y][train.position.x] != .none, "Train off track")
        if trains.first(where: { otherTrain in
            return otherTrain.index != train.index && otherTrain.position == train.position
        }) != nil {
            return train.position
        }
    }

    return nil
}

func crashPositions(grid: [[Track]], trains: [Train]) -> [Point] {
    var crashes: [Point] = []
    for train in trains {
        assert(grid[train.position.y][train.position.x] != .none, "Train off track")
        if trains.first(where: { otherTrain in
            return otherTrain.index != train.index && otherTrain.position == train.position
        }) != nil {
            crashes.append(train.position)
        }
    }

    return crashes
}

if let input: [String] = readInput(day: 13) {
    if let firstLine = input.first {
        let row = Array<Track>(repeating: .none, count: firstLine.count)
        var grid = Array<Array<Track>>(repeating: row, count: input.count)
        var trains: [Train] = []
        var trainIndex = 0
        for y in 0..<input.count {
            let line = Array<Character>(input[y])
            var track: Track
            for x in 0..<line.count {
                switch line[x] {
                case " ":
                    track = .none
                case "|":
                    track = .vertical
                case "-":
                    track = .horizontal
                case "+":
                    track = .intersection
                case "^":
                    let position = Point(x: x, y: y)
                    let train = Train(index: trainIndex, position: position, direction: .up)
                    trains.append(train)
                    trainIndex += 1
                    track = .vertical
                case "v":
                    let position = Point(x: x, y: y)
                    let train = Train(index: trainIndex, position: position, direction: .down)
                    trains.append(train)
                    trainIndex += 1
                    track = .vertical
                case "<":
                    let position = Point(x: x, y: y)
                    let train = Train(index: trainIndex, position: position, direction: .left)
                    trains.append(train)
                    trainIndex += 1
                    track = .horizontal
                case ">":
                    let position = Point(x: x, y: y)
                    let train = Train(index: trainIndex, position: position, direction: .right)
                    trains.append(train)
                    trainIndex += 1
                    track = .horizontal
                case "/":
                    /*
                    Corner cases (padum tsj) are hard: we need to know how the corner goes. We do this by looking
                    at the tracks next to it in all four directions and determining if it is either straight or
                    an intersection. Note that the following cases will not be handled by it, but they don't seem to happen:

                    -\
                     \-

                      |
                     //
                     |

                    */
                    let allowedUp: Set<Character> = ["|", "+", "v", "^"]
                    if y == 0 {
                        let rownDown = Array<Character>(input[y + 1])
                        let charDown = rownDown[x]
                        assert(allowedUp.contains(charDown), String(charDown))
                        track = .corner(.down, .right)
                    } else {
                        let rowUp = Array<Character>(input[y - 1])
                        let charUp = rowUp[x]
                        if allowedUp.contains(charUp) {
                            track = .corner(.up, .left)
                        } else {
                            let rownDown = Array<Character>(input[y + 1])
                            let charDown = rownDown[x]
                            assert(allowedUp.contains(charDown), String(charDown))
                            track = .corner(.down, .right)
                        }
                    }
                case "\\":
                    let allowedUp: Set<Character> = ["|", "+", "v", "^"]
                    if y == 0 {
                        let rownDown = Array<Character>(input[y + 1])
                        let charDown = rownDown[x]
                        assert(allowedUp.contains(charDown), String(charDown))
                        track = .corner(.down, .left)
                    } else {
                        let rowUp = Array<Character>(input[y - 1])
                        let charUp = rowUp[x]
                        if allowedUp.contains(charUp) {
                            track = .corner(.up, .right)
                        } else {
                            let rownDown = Array<Character>(input[y + 1])
                            let charDown = rownDown[x]
                            assert(allowedUp.contains(charDown), String(charDown))
                            track = .corner(.down, .left)
                        }
                    }
                default:
                    track = .none
                }
                grid[y][x] = track
            }
        }

//        printTracks(grid: grid, trains: trains)

        let gridCopy = grid
        let trainsCopy = trains

        let performTick: (Bool) -> (Bool) = { printFirstCrash in
            trains = trains.sorted(by: { t1, t2 in
                return t1.position < t2.position
            })

            var trainsToRemove: Set<Int> = []

            for trainIdx in 0..<trains.count {
                var train = trains[trainIdx]
                train.move(grid: grid)
                trains[trainIdx] = train

                if printFirstCrash {
                    if let crash = crashPosition(grid: grid, trains: trains) {
                        print(String(format: "%d,%d", arguments: [crash.x, crash.y]))
                        return false
                    }
                } else {
                    for position in crashPositions(grid: grid, trains: trains) {
                        // Remove the trains crashing
                        for trainIdx in 0..<trains.count {
                            if trains[trainIdx].position == position {
                                trainsToRemove.insert(trainIdx)
                            }
                        }
                    }
                }
            }

            if !printFirstCrash {
                var newTrains: [Train] = []
                for trainIdx in 0..<trains.count {
                    if !trainsToRemove.contains(trainIdx) {
                        newTrains.append(trains[trainIdx])
                    }
                }
                trains = newTrains
            }

//            printTracks(grid: grid, trains: trains)

            return true
        }

        var crash: Point? = nil
        repeat {
            if !performTick(true) {
                crash = nil
                break
            }
            crash = crashPosition(grid: grid, trains: trains)
        } while crash == nil

        if let crash = crash {
            print(String(format: "%d,%d", arguments: [crash.x, crash.y]))
        }

        grid = gridCopy
        trains = trainsCopy

//        printTracks(grid: grid, trains: trains)

        while trains.count > 1 {
            _ = performTick(false)
        }

        if let train = trains.first {
            print(String(format: "%d,%d", arguments: [train.position.x, train.position.y]))
        }
    }
}