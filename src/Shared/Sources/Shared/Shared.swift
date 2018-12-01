import Foundation

public func readInput<T: Input>(day: Int) -> T? {
    let filename = "/Users/nicky/Projects/AdventOfCode2018/input/day\(day).txt"
    let fileContents = try! String(contentsOf: URL(fileURLWithPath: filename), encoding: .utf8)

    return T.convert(contents: fileContents)
}