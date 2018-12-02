import Shared
import Foundation

func stringDifference(a: String, b: String) -> Int {
    var diff = 0
    for i in a.indices {
        if a[i] != b[i] {
            diff += 1
        }
    }

    return diff
}

func commonLetters(a: String, b: String) -> String {
    var common = ""
    for i in a.indices {
        if a[i] == b[i] {
            common.append(a[i])
        }
    }

    return common
}

if let input: [String] = readInput(day: 2) {
    var a: String? = nil
    var b: String? = nil

    outerloop: for i in input {
        for j in input {
            if stringDifference(a: i, b: j) == 1 {
                a = i
                b = j
                break outerloop
            }
        }
    }

    if let a = a, let b = b {
        print(commonLetters(a: a, b: b))
    }
}