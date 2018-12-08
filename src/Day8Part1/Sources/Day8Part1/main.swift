import Shared
import Foundation

class Node {
    var metadata: [Int] = []
    var children: [Node] = []
}

func parseNode(scanner: Scanner, into: Node) {
    var numChildren = 0
    var numMetadata = 0
    scanner.scanInt(&numChildren)
    scanner.scanInt(&numMetadata)
    for _ in 0..<numChildren {
        let child = Node()
        parseNode(scanner: scanner, into: child)
        into.children.append(child)
    }
    for _ in 0..<numMetadata {
        var metadata = 0
        scanner.scanInt(&metadata)
        into.metadata.append(metadata)
    }
}

func metadataSum(node: Node) -> Int {
    return node.metadata.reduce(0, +) + node.children.map({ metadataSum(node: $0) }).reduce(0, +)
}

if let input: String = readInput(day: 8) {
    let scanner = Scanner(string: input)

    let tree = Node()
    parseNode(scanner: scanner, into: tree)

    print(metadataSum(node: tree))
}