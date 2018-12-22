import Shared
import Foundation

enum Type: Int {
    case rocky = 0
    case wet = 1
    case narrow = 2

    func toolAllowed(tool: Tool) -> Bool {
        switch self {
        case .rocky:
            return tool == .climbingGear || tool == .torch
        case .wet:
            return tool == .none || tool == .climbingGear
        case .narrow:
            return tool == .none || tool == .torch
        }
    }
}

enum Tool {
    case none
    case torch
    case climbingGear
}

extension Tool: CaseIterable {
}

struct Node {
    let x: Int
    let y: Int
    let tool: Tool
}

extension Node: Hashable {
    public func hash(into hasher: inout Hasher) {
        x.hash(into: &hasher)
        y.hash(into: &hasher)
        tool.hash(into: &hasher)
    }
}

let directions = [(-1, 0), (1, 0), (0, -1), (0, 1)]

if let input: [String] = readInput(day: 22) {
    let target = input[1].split(separator: " ")[1].split(separator: ",")
    if let depth = Int(input[0].split(separator: " ")[1]),
       let tx = Int(target[0]),
       let ty = Int(target[1]) {

        let row = [Type](repeating: .rocky, count: tx * 2 + 1)
        var grid = [[Type]](repeating: row, count: ty * 2 + 1)
        let erosionRow = [Int](repeating: 0, count: tx * 2 + 1)
        var erosionGrid = [[Int]](repeating: erosionRow, count: ty * 2 + 1)

        for y in 0...ty * 2 {
            for x in 0...tx * 2 {
                let geologicalIndex: Int
                switch (x, y) {
                case (0, 0):
                    geologicalIndex = 0
                case (tx, ty):
                    geologicalIndex = 0
                case (_, 0):
                    geologicalIndex = x * 16807
                case (0, _):
                    geologicalIndex = y * 48271
                default:
                    geologicalIndex = erosionGrid[y][x - 1] * erosionGrid[y - 1][x]
                }
                let erosionLevel = (geologicalIndex + depth) % 20183
                erosionGrid[y][x] = erosionLevel
                if let type = Type(rawValue: erosionLevel % 3) {
                    grid[y][x] = type
                } else {
                    exit(1)
                }
            }
        }

        var sum = 0
        for y in 0...ty {
            for x in 0...tx {
                sum += grid[y][x].rawValue
            }
        }

        print(sum)

        // Too lazy to use real Dijkstra :-)
        var distances: [Node: Int] = [:]
        let startNode = Node(x: 0, y: 0, tool: .torch)
        var q: [Node] = []
        q.append(startNode)
        distances[startNode] = 0
        while !q.isEmpty {
            let elem = q.removeFirst()
            let p = grid[elem.y][elem.x]
            // Loop over all tools
            for tool in Tool.allCases {
                // Only check OTHER tools
                if tool != elem.tool {
                    if p.toolAllowed(tool: tool) {
                        let newNode = Node(x: elem.x, y: elem.y, tool: tool)
                        let newDist = distances[elem]! + 7
                        let currentDist = distances[newNode] ?? Int.max
                        if newDist < currentDist {
                            distances[newNode] = newDist
                            q.append(newNode)
                        }
                    }
                }
            }

            // Loop over all directions, without switching tool
            for d in directions {
                let x = elem.x + d.0
                let y = elem.y + d.1
                if x >= 0 && y >= 0 && x <= tx * 2 && y <= ty * 2 {
                    let p = grid[y][x]
                    if p.toolAllowed(tool: elem.tool) {
                        let newNode = Node(x: x, y: y, tool: elem.tool)
                        let newDist = distances[elem]! + 1
                        let currentDist = distances[newNode] ?? Int.max
                        if newDist < currentDist {
                            distances[newNode] = newDist
                            q.append(newNode)
                        }
                    }
                }
            }
        }

        let destinationNode = Node(x: tx, y: ty, tool: .torch)
        if let distance = distances[destinationNode] {
            print(distance)
        }
    }
}