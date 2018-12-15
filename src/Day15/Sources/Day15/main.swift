import Shared
import Foundation

enum UnitType {
    case elf
    case goblin
}

extension UnitType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .elf:
            return "E"
        case .goblin:
            return "G"
        }
    }
}

class Unit {
    let id: Int
    let type: UnitType
    var position: Point
    var initialPosition: Point
    var health: Int
    let initialhealth: Int

    init(id: Int, type: UnitType, position: Point, health: Int) {
        self.id = id
        self.type = type
        self.position = position
        self.initialPosition = position
        self.health = health
        self.initialhealth = health
    }

    func move(to: Point) {
        position = to
    }

    func takeDamage(amount: Int) {
        health -= amount
    }

    func reset() {
        position = initialPosition
        health = initialhealth
    }

    var alive: Bool {
        return health > 0
    }
}

extension Unit: Equatable {
    public static func ==(lhs: Unit, rhs: Unit) -> Bool {
        return lhs.id == rhs.id
    }
}

extension Unit: Hashable {
    func hash(into hasher: inout Hasher) {
        id.hash(into: &hasher)
    }
}

extension Unit: CustomStringConvertible {
    public var description: String {
        return "\(self.type) (\(self.position.x), \(self.position.y)): \(self.health)"
    }
}

extension Set where Element == Unit {
    func reset() {
        for unit in self {
            unit.reset()
        }
    }
}

enum FieldType {
    case wall
    case floor
}

extension FieldType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .wall:
            return "#"
        case .floor:
            return "."
        }
    }
}

struct Point {
    let x: Int
    let y: Int
}

extension Point {
    public static func +(lhs: Point, rhs: Point) -> Point {
        return Point(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
}

extension Point: CustomStringConvertible {
    public var description: String {
        return "(\(x), \(y))"
    }
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
        }
        return lhs.y < rhs.y
    }
}

extension Point: Hashable {
    public func hash(into hasher: inout Hasher) {
        x.hash(into: &hasher)
        y.hash(into: &hasher)
    }
}

extension Array where Element == Array<FieldType> {
    subscript(index: Point) -> FieldType {
        get {
            return self[index.y][index.x]
        }
        set {
            self[index.y][index.x] = newValue
        }
    }
}

func printBoard(board: [[FieldType]], units: Set<Unit>) {
    return
    for y in 0..<board.count {
        for x in 0..<board[y].count {
            let position = Point(x: x, y: y)
            if let unit = units.first(where: { $0.position == position }) {
                print("\(unit.type)", separator: "", terminator: "")
            } else {
                print(board[y][x], separator: "", terminator: "")
            }
        }
        print()
    }
    print()
    print("Units:")
    for unit in units.sorted(by: { $0.position < $1.position }) {
        print(unit)
    }
    print()
}

struct Queue<T> {
    var list = [T]()

    mutating func enqueue(_ element: T) {
        list.append(element)
    }

    mutating func dequeue() -> T? {
        if !list.isEmpty {
            return list.removeFirst()
        } else {
            return nil
        }
    }

    var isEmpty: Bool {
        return list.isEmpty
    }
}

// Order in which to consider points if we have multiple
let readingOrder = [Point(x: 0, y: -1), Point(x: -1, y: 0), Point(x: 1, y: 0), Point(x: 0, y: 1)]
let attackPower = 3
let startHealth = 200

func distances(board: [[FieldType]], units: Set<Unit>, from: Point) -> [Point: Int] {
    var distance: [Point: Int] = [:]

    var q = Queue<(Point, Int)>()
    q.enqueue((from, 0))
    distance[from] = 0

    while !q.isEmpty {
        if let current = q.dequeue() {
            for direction in readingOrder {
                let newPoint = current.0 + direction
                if distance[newPoint] == nil && board[newPoint] == .floor && units.first(where: { $0.position == newPoint }) == nil {
                    distance[newPoint] = current.1 + 1
                    q.enqueue((newPoint, current.1 + 1))
                }
            }
        }
    }

    return distance
}

func calculateOutCome(board: [[FieldType]], units: Set<Unit>, elfAttackPower: Int) -> (Int, Int, Int) {
    var round = 0
    var units = units
    while units.filter({ $0.type == .elf }).count > 0 && units.filter({ $0.type == .goblin }).count > 0 {
        // Each unit takes a turn
        var increaseRound = true
        for unit in units.sorted(by: { $0.position < $1.position }) {
            if unit.health <= 0 {
                continue
            }
//            print("Moving unit \(unit)...")

            // First, determine all points in range
            var inRange: Set<Point> = []
            for enemyUnit in units.filter({ $0.type != unit.type }) {
                for adjacent in readingOrder {
                    let point = enemyUnit.position + adjacent
                    if board[point] == .floor {
                        inRange.insert(point)
                    }
                }
            }

            // Continue moving only if the unit is not in range of an enemy yet
            if !inRange.contains(unit.position) {
                // Now determine which of these are reachable and also look at the distances, as we need them anyway
                let d = distances(board: board, units: units, from: unit.position)

                // Determine which of the inRange points have the closest distance
                var minDistance = Int.max
                var closest: Set<Point> = []
                for point in inRange {
                    if let dist = d[point] {
                        // Ignore all distances <= 0 as that is either our current spot or it is not reachable
                        if dist > 0 && dist < minDistance {
                            closest = [point]
                            minDistance = dist
                        } else if dist > 0 && dist == minDistance {
                            closest.insert(point)
                        }
                    }
                }

                if let closestInRange = closest.min(by: { $0 < $1 }) {
//                    print("Move toward \(closestInRange)...")

                    // Now we want the distances from closestInRange
                    let distancesToGoal = distances(board: board, units: units, from: closestInRange)

                    // Now, we need to look at our four directions and see which ones are the closest to our goal
                    var closest = Int.max
                    var moveTo: Point? = nil
                    for direction in readingOrder {
                        if let thisDistance = distancesToGoal[unit.position + direction] {
                            // Only consider reachable spots that are closer than our current pick
                            if thisDistance >= 0 && thisDistance < closest {
                                closest = thisDistance
                                moveTo = unit.position + direction
                            }
                        }
                    }

                    if let moveTo = moveTo {
//                        print("Move to \(moveTo)...")
                        unit.move(to: moveTo)
                    }
                }
            }

//            print("Attacking for \(unit)...")

            // Check if there are no more enemies
            if units.filter({ $0.type != unit.type }).isEmpty {
                // End it now, as the round should not finish
                increaseRound = false
                break
            }

            // Now do the attack
            let positions = Set(readingOrder.map({ $0 + unit.position }))
            let enemies = units.filter({ $0.type != unit.type && positions.contains($0.position) })
            if let minHealth = enemies.min(by: { $0.health <= $1.health }) {
                let enemiesWithLeastHealth = enemies.filter({ $0.health == minHealth.health })
                for position in readingOrder {
                    let attackPosition = unit.position + position
                    if let enemy = enemiesWithLeastHealth.first(where: { $0.position == attackPosition }) {
//                        print("Attack \(enemy)!")
                        enemy.takeDamage(amount: unit.type == .goblin ? attackPower : elfAttackPower)
                        if !enemy.alive {
//                            print("\(enemy) dies!")
                            units.remove(enemy)
                        }

                        break
                    }
                }
            }
        }
        printBoard(board: board, units: units)
        if increaseRound {
            round += 1
        }
    }

    return (round, units.reduce(0, { $0 + $1.health }), units.filter({ $0.type == .elf }).count)
}

if let input: [String] = readInput(day: 15) {
    let row = Array<FieldType>(repeating: .wall, count: input[0].count)
    var board = Array<Array<FieldType>>(repeating: row, count: input.count)
    var units: Set<Unit> = []
    var unitId = 0

    for y in 0..<input.count {
        let line = Array(input[y])
        for x in 0..<line.count {
            switch line[x] {
            case "#":
                board[y][x] = .wall
            case ".":
                board[y][x] = .floor
            case "E":
                board[y][x] = .floor
                units.insert(Unit(id: unitId, type: .elf, position: Point(x: x, y: y), health: 200))
                unitId += 1
            case "G":
                board[y][x] = .floor
                units.insert(Unit(id: unitId, type: .goblin, position: Point(x: x, y: y), health: 200))
                unitId += 1
            default:
                // Nothing
                break
            }
        }
    }

    printBoard(board: board, units: units)

    var (round, totalHitpoints, numElves) = calculateOutCome(board: board, units: units, elfAttackPower: attackPower)
    print(round, totalHitpoints, round * totalHitpoints)

    let wantedElves = units.filter({$0.type == .elf}).count
    var elfAttackPower = attackPower
    while numElves < wantedElves {
        units.reset()
        elfAttackPower += 1
        (round, totalHitpoints, numElves) = calculateOutCome(board: board, units: units, elfAttackPower: elfAttackPower)
    }

    print(round, totalHitpoints, elfAttackPower, round * totalHitpoints)
}