import Shared
import Foundation

class Node {
    var value = 0
    var previous: Node? = nil
    var next: Node? = nil
}

extension Node: CustomStringConvertible {
    public var description: String {
        get {
            var desc = ""
            desc += String(format: "%5d\t", arguments: [self.value])
            var next = self.next
            while next != nil && next!.value != self.value {
                desc += String(format: "%5d\t", arguments: [next!.value])
                next = next!.next
            }
            return desc
        }
    }
}

func insertAfter(node: Node, newNode: Node) {
    if let afterThat = node.next {
        newNode.previous = node
        newNode.next = afterThat
        node.next = newNode
        afterThat.previous = newNode
    } else {
        exit(1)
    }
}

func removeNode(node: Node) {
    if let prev = node.previous,
       let next = node.next {
        prev.next = next
        next.previous = prev
    } else {
        exit(1)
    }
}

if let input: String = readInput(day: 9) {
    let scanner = Scanner(string: input)

    var numPlayers = 0
    var lastMarble = 0
    scanner.scanInt(&numPlayers)
    scanner.scanString("players; last marble is worth", into: nil)
    scanner.scanInt(&lastMarble)

    var scores = Array<Int>(repeating: 0, count: numPlayers)

    var currentNode = Node()
    currentNode.previous = currentNode
    currentNode.next = currentNode
    let start = currentNode

    var player = 0

    for marble in 1...lastMarble {
        if let next = currentNode.next {
            if marble % 23 == 0 {
                scores[player] += marble
                if let p1 = currentNode.previous,
                   let p2 = p1.previous,
                   let p3 = p2.previous,
                   let p4 = p3.previous,
                   let p5 = p4.previous,
                   let p6 = p5.previous,
                   let p7 = p6.previous {
                    scores[player] += p7.value
                    currentNode = p6
                    removeNode(node: p7)
                }
            } else {
                // Create a new node, place it between the two
                let newNode = Node()
                newNode.value = marble
                insertAfter(node: next, newNode: newNode)
                currentNode = newNode
            }
        } else {
            exit(1)
        }

        player = (player + 1) % numPlayers
    }

    print(scores.max()!)
}