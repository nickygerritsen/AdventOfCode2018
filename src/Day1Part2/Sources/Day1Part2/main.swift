import Shared
import Foundation

if let input: [Int] = readInput(day: 1) {
    var encountered: Set<Int> = []
    var currentIndex = 0
    var currentNumber = 0

    while true {
        currentNumber = currentNumber + input[currentIndex]
        if encountered.contains(currentNumber) {
            print(currentNumber)
            break
        }

        encountered.insert(currentNumber)
        currentIndex = (currentIndex + 1) % input.count
    }
}