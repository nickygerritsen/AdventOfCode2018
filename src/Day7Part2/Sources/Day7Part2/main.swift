import Shared
import Foundation

struct Node {
    let label: Character
    var outEdges: Set<Character> = []

    func duration() -> Int {
        let a: Character = "A"
        return Int(self.label.unicodeScalars.first!.value - a.unicodeScalars.first!.value + 1 + 60)
    }
}

struct Graph {
    var nodes: [Character: Node] = [:]
}

if let input: [String] = readInput(day: 7) {
    var graph = Graph()
    for line in input {
        let scanner = Scanner(string: line)
        scanner.scanString("Step", into: nil)
        var nodeString: NSString? = ""
        scanner.scanCharacters(from: .letters, into: &nodeString)
        let nodeA = String(nodeString!).first!
        scanner.scanString("must be finished before step", into: nil)
        scanner.scanCharacters(from: .letters, into: &nodeString)
        let nodeB = String(nodeString!).first!

        var firstNode = graph.nodes[nodeA] ?? Node(label: nodeA, outEdges: [])
        let secondNode = graph.nodes[nodeB] ?? Node(label: nodeB, outEdges: [])
        firstNode.outEdges.insert(nodeB)

        graph.nodes[nodeA] = firstNode
        graph.nodes[nodeB] = secondNode
    }

    var totalTime = 0
    var lastFinished = 0
    let numWorkers = 5
    var done: Set<Character> = []
    var workers: [(Character?, Int)] = []
    for _ in 0..<numWorkers {
        workers.append((nil, 0))
    }

    while done.count < graph.nodes.count {
        for i in 0..<workers.count {
            var w = workers[i]
            if let c = w.0 {
                if w.1 == totalTime {
                    done.insert(c)
                    w.0 = nil
                    lastFinished = max(lastFinished, w.1)
                }
            }
            workers[i] = w
        }

        for (key, node) in graph.nodes {
            if done.contains(key) {
                continue
            }

            // If we are working on this thing, skip it
            if !workers.filter({ $0.0 == key }).isEmpty {
                continue
            }

            // If it has unfinished dependencies, skip it
            var allDone = true
            for n in node.outEdges {
                if !done.contains(n) {
                    allDone = false
                }
            }

            // If all dependencies are done, find an available worker
            if allDone {
                for i in 0..<workers.count {
                    var w = workers[i]
                    if w.0 == nil {
                        w.0 = key
                        w.1 = totalTime + node.duration()
                        workers[i] = w
                        break
                    }
                }
            }
        }

        totalTime += 1
    }

    print(lastFinished)
}