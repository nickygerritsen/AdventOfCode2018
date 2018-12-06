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

    if let minXP = input.min(by: { $0.x < $1.x }),
       let maxXP = input.min(by: { $0.x > $1.x }),
       let minYP = input.min(by: { $0.y < $1.y }),
       let maxYP = input.min(by: { $0.y > $1.y }) {
        let minX = minXP.x
        let maxX = maxXP.x
        let minY = minYP.y
        let maxY = maxYP.y

        var grid: [Int: [Int: Int]] = [:]
        for x in minX - 1...maxX + 1 {
            var row: [Int: Int] = [:]
            for y in minY - 1...maxY + 1 {
                row[y] = 0
            }
            grid[x] = row
        }

        for (idx, p) in points {
            grid[p.x]![p.y] = idx + 1
        }

        for y in minY - 1...maxY + 1 {
            for x in minX - 1...maxX + 1 {
                let thisPoint = Point(x: x, y: y)
                let distances = points.map {
                    Point.distance(thisPoint, $0.value)
                }
                if let minDistance = distances.min(), minDistance > 0 {
                    let allWithMinDistance = points.filter {
                        minDistance == Point.distance(thisPoint, $0.value)
                    }
                    if allWithMinDistance.count == 1 {
                        if let closestPoint = allWithMinDistance.first {
                            grid[thisPoint.x]![thisPoint.y] = closestPoint.key + 1
                        }
                    }
                }
            }
        }

//        for y in minY - 1...maxY + 1 {
//            for x in minX - 1...maxX + 1 {
//                print(String(format: "%2d", arguments: [grid[x]![y]!]), separator: "", terminator: "")
//                print(" ", separator: "", terminator: "")
//            }
//            print()
//        }

        // Determine the points to skip by looking at the othermost distances
        let rightMost = maxX * 2
        let leftMost = -rightMost
        let topMost = maxY * 2
        let bottomMost = -topMost
        var pointsToSkip = Set<Int>()

        for x in leftMost...rightMost {
            for y in [bottomMost, topMost] {
                let thisPoint = Point(x: x, y: y)
                let distances = points.map {
                    Point.distance(thisPoint, $0.value)
                }
                if let minDistance = distances.min(), minDistance > 0 {
                    let allWithMinDistance = points.filter {
                        minDistance == Point.distance(thisPoint, $0.value)
                    }
                    if allWithMinDistance.count == 1 {
                        for minDistanceItem in allWithMinDistance {
                            pointsToSkip.insert(minDistanceItem.key + 1)
                        }
                    }
                }
            }
        }
        for y in leftMost...rightMost {
            for x in [bottomMost, topMost] {
                let thisPoint = Point(x: x, y: y)
                let distances = points.map {
                    Point.distance(thisPoint, $0.value)
                }
                if let minDistance = distances.min(), minDistance > 0 {
                    let allWithMinDistance = points.filter {
                        minDistance == Point.distance(thisPoint, $0.value)
                    }
                    if allWithMinDistance.count == 1 {
                        for minDistanceItem in allWithMinDistance {
                            pointsToSkip.insert(minDistanceItem.key + 1)
                        }
                    }
                }
            }
        }

        var maxSize = -1
        for (idx, p) in points {
            if !pointsToSkip.contains(idx + 1) {
                var size = 0
                for y in minY - 1...maxY + 1 {
                    for x in minX - 1...maxX + 1 {
                        if grid[x]![y] == idx + 1 {
                            size += 1
                        }
                    }
                }

                if size > maxSize {
                    maxSize = size
                }
            }
        }

        print(maxSize)
    }
}