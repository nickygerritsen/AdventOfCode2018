import Shared
import Foundation

struct NanoBot {
    let x: Int
    let y: Int
    let z: Int
    let r: Int

    func distance(_ other: NanoBot) -> Int {
        return abs(x - other.x) + abs(y - other.y) + abs(z - other.z)
    }
}

extension NanoBot: Input {
    public static func convert(contents: String) -> NanoBot? {
        if let regex = try? NSRegularExpression(pattern: "pos=<(-?\\d+),(-?\\d+),(-?\\d+)>, r=(-?\\d+)") {
            let matches = regex.matches(in: contents, range: NSMakeRange(0, contents.utf16.count))
            if let match = matches.first {
                if let xmatch = Range(match.range(at: 1), in: contents),
                   let ymatch = Range(match.range(at: 2), in: contents),
                   let zmatch = Range(match.range(at: 3), in: contents),
                   let rmatch = Range(match.range(at: 4), in: contents),
                   let x = Int(contents[xmatch]),
                   let y = Int(contents[ymatch]),
                   let z = Int(contents[zmatch]),
                   let r = Int(contents[rmatch]) {
                    return NanoBot(x: x, y: y, z: z, r: r)
                }
            }
        }
        return nil
    }
}

if let input: [NanoBot] = readInput(day: 23) {
    if let strongestBot = input.max(by: { $0.r < $1.r }) {
        let distances = input.map({ $0.distance(strongestBot) })
        let inRange = distances.filter({ $0 <= strongestBot.r })
        print(inRange.count)
    }
}
