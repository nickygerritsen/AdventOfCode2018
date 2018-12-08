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
    if node.children.isEmpty {
        return node.metadata.reduce(0, +)
    } else {
        return node.metadata
                .map({ $0 - 1 })
                .filter({ $0 < node.children.count })
                .map({ metadataSum(node: node.children[$0]) }).reduce(0, +)
    }
}

if let input: String = readInput(day: 8) {
    let scanner = Scanner(string: input)

    let tree = Node()
    parseNode(scanner: scanner, into: tree)

    print(metadataSum(node: tree))
}