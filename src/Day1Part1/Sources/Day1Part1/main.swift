import Shared
import Foundation

if let input: [Int] = readInput(day: 1) {
    print(input.reduce(0, +))
}