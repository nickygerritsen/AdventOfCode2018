//
// Created by Nicky Gerritsen on 2018-11-30.
//

import Foundation

public protocol Input {
    static func convert(contents: String) -> Self?
}
