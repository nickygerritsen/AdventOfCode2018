import Shared
import Foundation

func polymerLength(input: [Character]) -> Int {
    var current = input
    var changed = true
    repeat {
        var doubleIndices = [Int]()
        var idx = 0
        while idx < current.count - 1 {
            let uppercaseCurrent = Character(String(current[idx]).uppercased())
            let uppercaseNext = Character(String(current[idx + 1]).uppercased())
            if uppercaseCurrent == uppercaseNext && current[idx] != current[idx + 1] {
                doubleIndices.append(idx)
                idx += 1
            }
            idx += 1
        }

        var new = [Character]()
        var start = 0
        for idx in doubleIndices {
            new += current[start..<idx]
            start = idx + 2
        }
        new += current[start..<current.count]
        if new == current {
            changed = false
        } else {
            current = new
        }
    } while changed

    return current.count
}

if let input: String = readInput(day: 5) {
    let inputStripped = input.trimmingCharacters(in: .whitespacesAndNewlines)
    let input = Array(inputStripped)

    print(polymerLength(input: input))
}