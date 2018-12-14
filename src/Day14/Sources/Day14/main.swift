import Shared
import Foundation


if let input: Int = readInput(day: 14) {
    var recipes = [3, 7]
    var elfPositions = [0, 1]

    let recipeCopy = recipes
    let elfPositionsCopy = elfPositions

    while recipes.count < 10 + input {
        let newNumber = recipes[elfPositions[0]] + recipes[elfPositions[1]]
        if newNumber >= 10 {
            recipes.append(1)
        }
        recipes.append(newNumber % 10)

        elfPositions[0] = (elfPositions[0] + 1 + recipes[elfPositions[0]]) % recipes.count
        elfPositions[1] = (elfPositions[1] + 1 + recipes[elfPositions[1]]) % recipes.count
    }

    print(recipes[input..<input + 10].map({ String($0) }).joined())

    recipes = recipeCopy
    elfPositions = elfPositionsCopy

    let mappedInput = String(input).compactMap({ Int(String($0)) })
    let n = mappedInput.count

    // I'm lazy. This can probably be sped up if you don't do a lookup of the last five numbers every time but meh
    repeat {
        let newNumber = recipes[elfPositions[0]] + recipes[elfPositions[1]]
        if newNumber >= 10 {
            recipes.append(1)
            if recipes.count >= n {
                if Array(recipes[recipes.count - n..<recipes.count]) == mappedInput {
                    print(recipes.count - n)
                    break
                }
            }
        }

        recipes.append(newNumber % 10)
        if recipes.count >= n {
            if Array(recipes[recipes.count - n..<recipes.count]) == mappedInput {
                print(recipes.count - n)
                break
            }
        }

        elfPositions[0] = (elfPositions[0] + 1 + recipes[elfPositions[0]]) % recipes.count
        elfPositions[1] = (elfPositions[1] + 1 + recipes[elfPositions[1]]) % recipes.count
    } while true
}