import Shared
import Foundation

func calculate(input: [String], generations: Int) {
    let scanner = Scanner(string: input[0])
    scanner.scanString("initial state:", into: nil)
    var initialStateNSString: NSString? = ""
    let set = CharacterSet(charactersIn: "#.")
    scanner.scanCharacters(from: set, into: &initialStateNSString)
    if let initialNSString = initialStateNSString {
        let initialString = initialNSString as String

        // We will add 2 * the number of generations + 2 before and after the state, as that is the maximum that we can extend to
        let initialState = Array<Bool>(repeating: false, count: generations * 2 + 2) + initialString.map {
            $0 == "#"
        } + Array<Bool>(repeating: false, count: generations * 2 + 2)

        // Now we need all the possible transformations
        var transformations: Set<[Bool]> = []
        for transformation: String in input[1..<input.count] {
            if transformation.last != "#" {
                continue
            }

            transformations.insert(transformation[transformation.startIndex..<transformation.firstIndex(of: " ")!].map({ $0 == "#" }))
        }

        var currentState = initialState

        for generation in (1...generations) {
            var nextState = currentState
            for idx in 2..<currentState.count - 2 {
                let part = Array<Bool>(currentState[(idx - 2)...(idx + 2)])
                nextState[idx] = transformations.contains(part)
            }

            currentState = nextState
        }

        var total = 0
        for idx in 2..<currentState.count - 2 {
            let pot = idx - (generations * 2 + 2)
            if currentState[idx] {
                total += pot
            }
        }

        print(total)
    }
}

if let input: [String] = readInput(day: 12) {
    calculate(input: input, generations: 20)

    // For the second one: the first filled pot is `generations - 75`
    // The last filled pot is `generations + 97` and we have a pot every other pot, so just calculate the number

    // For 500:
    // 44457 - 425 = 44032 = location of first pot
    // (75 + 97) / 2 = 86 = number of pots
    // 44032 / 86 = 512 = magic number to add
    // We get to the magic number using 500-75+86+1 = generations + 12

    // So for 600 it will be:
    // 600+12 = 612
    // 612 * 86 = 52632
    // 52632 + 525 = 53157

    let generations = 50000000000
    let magicNumber = generations + 12
    let multiplied = magicNumber * 86
    let start = generations - 75
    let answer = multiplied + start
    print(answer)
}