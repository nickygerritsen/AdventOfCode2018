import Shared
import Foundation

struct Point {
    let pos: [Int]

    func inRange(other: Point) -> Bool {
        var dist = 0
        for idx in 0..<pos.count {
            dist += abs(pos[idx] - other.pos[idx])
        }

        return dist <= 3
    }
}

extension Point: Hashable {}

extension Point: Input {
    public static func convert(contents: String) -> Point? {
        let parts = contents.split(separator: ",")
        return Point(pos: parts.compactMap({ Int.convert(contents: String($0)) }))
    }
}

if let input: [Point] = readInput(day: 25) {
    var pointsPerClique: [Int: [Int]] = [:]
    var cliqueForPoint: [Int: Int] = [:]

    for idx in 0..<input.count {
        pointsPerClique[idx] = [idx]
        cliqueForPoint[idx] = idx
    }

    var changed = true
    while changed {
        changed = false
        for p in 0..<input.count {
            for p2 in 0..<input.count {
                // Already in same clique
                if cliqueForPoint[p] == cliqueForPoint[p2] {
                    continue
                }

                if input[p].inRange(other: input[p2]) {
                    if let pclique = cliqueForPoint[p], let p2clique = cliqueForPoint[p2] {
                        changed = true
                        // Merge the two cliques
                        if let points = pointsPerClique[p2clique] {
                            for p3 in points {
                                cliqueForPoint[p3] = pclique
                            }
                            if let points1 = pointsPerClique[pclique], let points2 = pointsPerClique[p2clique] {
                                pointsPerClique[pclique] = points1 + points2
                                pointsPerClique[p2clique] = nil
                            }
                        }
                    }
                }
            }
        }
    }

    print(pointsPerClique.count)
}
