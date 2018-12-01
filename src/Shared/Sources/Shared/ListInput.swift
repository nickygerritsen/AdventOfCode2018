//
// Created by Nicky Gerritsen on 2018-12-01.
//

import Foundation

extension Array: Input where Element: Input {
    public static func convert(contents: String) -> Array<Element>? {
        return contents
                .split(separator: "\n", maxSplits: Int.max, omittingEmptySubsequences: true)
                .map({ Element.convert(contents: String($0)) })
                .compactMap { $0 }
    }
}
