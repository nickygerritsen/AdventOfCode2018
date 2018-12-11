import Shared
import Foundation

// Both parts

let row = Array<Int>(repeating: 0, count: 301)
var grid = Array<Array<Int>>(repeating: row, count: 301)
var gridAnswers = Array<Array<Array<Int>>>(repeating: grid, count: 301)

func powerLevel(serialNumber: Int, x: Int, y: Int) -> Int {
    let rackID = x + 10
    let powerLevelIntermediate = (rackID * y + serialNumber) * rackID
    let powerLevelCapped = powerLevelIntermediate % 1000
    let powerLevelSmallPart = powerLevelCapped % 100
    return ((powerLevelCapped - powerLevelSmallPart) / 100) - 5
}

func maxPower(serialNumber: Int, squareSize: Int) -> (Int, Int, Int) {
    var maxPower = Int.min
    var maxX = -1
    var maxY = -1
    for x in 1...300 {
        for y in 1...300 {
            var power = gridAnswers[squareSize - 1][x][y]
            for dx in 0..<squareSize {
                let dy = squareSize - 1
                if x + dx <= 300 && y + dy <= 300 {
                    power += grid[x + dx][y + dy]
                }
            }
            for dy in 0..<squareSize {
                let dx = squareSize - 1
                if x + dx <= 300 && y + dy <= 300 {
                    power += grid[x + dx][y + dy]
                }
            }
            let dx = squareSize - 1
            let dy = squareSize - 1
            if x + dx <= 300 && y + dy <= 300 {
                power -= grid[x + dx][y + dy]
            }
            gridAnswers[squareSize][x][y] = power
            if power > maxPower {
                maxPower = power
                maxX = x
                maxY = y
            }
        }
    }

    return (maxX, maxY, maxPower)
}

if let serialNumber: Int = readInput(day: 11) {
    for x in 1...300 {
        for y in 1...300 {
            grid[x][y] = powerLevel(serialNumber: serialNumber, x: x, y: y)
        }
    }

    var maxP = Int.min
    var maxX = 0
    var maxY = 0
    var maxSize = 0

    for size in 1...300 {
        let (x, y, power) = maxPower(serialNumber: serialNumber, squareSize: size)
        if size == 3 {
            print(String(format: "%d,%d", arguments: [x, y]))
        }

        if power > maxP {
            maxP = power
            maxX = x
            maxY = y
            maxSize = size
        }
    }

    print(String(format: "%d,%d,%d", arguments: [maxX, maxY, maxSize]))
}