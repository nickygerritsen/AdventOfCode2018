import Shared
import Foundation

func letterCounts(input: String) -> [Character: Int] {
    var counts = [Character: Int]()
    for char in input {
        if let count = counts[char] {
            counts[char] = count + 1
        } else {
            counts[char] = 1
        }
    }

    return counts
}

func hasCount(input: [Character: Int], num: Int) -> Bool {
    return !input.filter({ $0.value == num }).isEmpty
}

func hasCount(input: [[Character: Int]], num: Int) -> Int {
    return input.filter({ hasCount(input: $0, num: num) }).count
}

if let input: [String] = readInput(day: 2) {
    let counts = input.map {
        letterCounts(input: $0)
    }

    let numWithTwo = hasCount(input: counts, num: 2)
    let numWithThree = hasCount(input: counts, num: 3)

    print(numWithTwo * numWithThree)
}