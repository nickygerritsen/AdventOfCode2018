import Shared
import Foundation

if let input: [String] = readInput(day: 4) {
    let sortedInput = input.sorted()

    var guardData: [Int: [Int]] = [:]

    var lastGuard = -1
    var asleepSince = -1

    for i in sortedInput {
        let s = Scanner(string: i)
        s.scanString("[", into: nil)
        s.scanInt(nil)
        s.scanString("-", into: nil)
        s.scanInt(nil)
        s.scanString("-", into: nil)
        s.scanInt(nil)
        s.scanString(" ", into: nil)
        s.scanInt(nil)
        s.scanString(":", into: nil)
        var minute: Int = 0
        s.scanInt(&minute)

        if s.scanString("] Guard #", into: nil) {
            s.scanInt(&lastGuard)
        } else if s.scanString("] falls asleep", into: nil) {
            asleepSince = minute
        } else if s.scanString("] wakes up", into: nil) {
            if guardData[lastGuard] == nil {
                guardData[lastGuard] = Array<Int>(repeating: 0, count: 60)
            }
            for i in asleepSince..<minute {
                guardData[lastGuard]![i] = guardData[lastGuard]![i] + 1
            }
        }
    }

    let mostAsleep = guardData.mapValues({ data in
        return data.max()!
    })
    if let guardThatIsMostAsleep = mostAsleep.max(by: { $0.value < $1.value }),
       let data = guardData[guardThatIsMostAsleep.key],
       let minute = data.firstIndex(where: { $0 == guardThatIsMostAsleep.value }) {
        print(guardThatIsMostAsleep.key * minute)
    }
}