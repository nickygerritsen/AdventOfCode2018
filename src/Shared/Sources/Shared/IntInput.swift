//
// Created by Nicky Gerritsen on 2018-12-01.
//

import Foundation

extension Int: Input {
    public static func convert(contents: String) -> Int? {
        if contents.isEmpty {
            return nil
        }

        // Check if the first character if the string is a + or -
        let modifier: Int
        let stringToParse: Substring
        if contents.first == "-" {
            modifier = -1
            stringToParse = contents.dropFirst()
        } else if contents.first == "+" {
            modifier = 1
            stringToParse = contents.dropFirst()
        } else {
            modifier = 1
            stringToParse = contents[contents.startIndex...contents.endIndex]
        }

        if let number = Int(stringToParse) {
            return modifier * number
        }

        return nil
    }
}