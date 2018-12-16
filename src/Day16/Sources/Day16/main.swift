import Shared
import Foundation

enum Operation: String, CaseIterable {
    case addr
    case addi
    case mulr
    case muli
    case banr
    case bani
    case borr
    case bori
    case setr
    case seti
    case gtir
    case gtri
    case gtrr
    case eqir
    case eqri
    case eqrr
}

struct Instruction {
    let operation: Operation
    let a: Int
    let b: Int
    let c: Int

    func apply(registers: [Int]) -> [Int] {
        var registers = registers

        switch operation {
        case .addr:
            registers[c] = registers[a] + registers[b]
        case .addi:
            registers[c] = registers[a] + b
        case .mulr:
            registers[c] = registers[a] * registers[b]
        case .muli:
            registers[c] = registers[a] * b
        case .banr:
            registers[c] = registers[a] & registers[b]
        case .bani:
            registers[c] = registers[a] & b
        case .borr:
            registers[c] = registers[a] | registers[b]
        case .bori:
            registers[c] = registers[a] | b
        case .setr:
            registers[c] = registers[a]
        case .seti:
            registers[c] = a
        case .gtir:
            registers[c] = a > registers[b] ? 1 : 0
        case .gtri:
            registers[c] = registers[a] > b ? 1 : 0
        case .gtrr:
            registers[c] = registers[a] > registers[b] ? 1 : 0
        case .eqir:
            registers[c] = a == registers[b] ? 1 : 0
        case .eqri:
            registers[c] = registers[a] == b ? 1 : 0
        case .eqrr:
            registers[c] = registers[a] == registers[b] ? 1 : 0
        }

        return registers
    }

    func producesOutput(registersIn: [Int], registersOut: [Int]) -> Bool {
        return apply(registers: registersIn) == registersOut
    }
}

func determineMapping(possibleInstructions: [Int: [Set<Operation>]], allOperations: Set<Operation>) -> [Int: Operation] {
    var mapping: [Int: Operation] = [:]
    var todo: [Int: [Set<Operation>]] = [:]
    for (operationId, instructions) in possibleInstructions {
        let intersected = instructions.reduce(allOperations, { current, next in
            return next.intersection(current)
        })
        if intersected.count == 1, let operation = intersected.first {
            mapping[operationId] = operation
        } else {
            todo[operationId] = instructions
        }
    }

    let left = allOperations.subtracting(Set(mapping.values))
    if left.isEmpty {
        return mapping
    }

    let subMapping = determineMapping(possibleInstructions: todo, allOperations: left)
    return mapping.merging(subMapping) { (current, _) in current }
}

func parseRegisters(input: String) -> [Int] {
    let scanner = Scanner(string: input)
    scanner.scanString("Before: [", into: nil)
    scanner.scanString("After:  [", into: nil)

    var registers = Array<Int>(repeating: Int.max, count: 4)
    scanner.scanInt(&registers[0])
    scanner.scanString(",", into: nil)
    scanner.scanInt(&registers[1])
    scanner.scanString(",", into: nil)
    scanner.scanInt(&registers[2])
    scanner.scanString(",", into: nil)
    scanner.scanInt(&registers[3])

    return registers
}

if let input: [String] = readInput(day: 16) {
    // Search for the last 'After'
    var lastAfter = -1
    for idx in 0..<input.count {
        let line: String = input[idx]
        if line.contains("After") {
            lastAfter = idx
        }
    }

    var atLeastThreeCount = 0
    var possibleInstructions: [Int: [Set<Operation>]] = [:]
    for sampleIdx in stride(from: 0, through: lastAfter, by: 3) {
        let sampleBefore = parseRegisters(input: input[sampleIdx])
        let sampleAfter = parseRegisters(input: input[sampleIdx + 2])
        let instructionData = input[sampleIdx + 1].split(separator: " ").compactMap({ Int($0) })

        var matchingOperations = 0
        var instructions = possibleInstructions[instructionData[0]] ?? [Set<Operation>]()
        var theseInstructions: Set<Operation> = []
        for operation in Operation.allCases {
            let instruction = Instruction(operation: operation, a: instructionData[1], b: instructionData[2], c: instructionData[3])
            if instruction.producesOutput(registersIn: sampleBefore, registersOut: sampleAfter) {
                theseInstructions.insert(operation)
                matchingOperations += 1
            }
        }
        if matchingOperations >= 3 {
            atLeastThreeCount += 1
        }

        instructions.append(theseInstructions)
        possibleInstructions[instructionData[0]] = instructions
    }

    print(atLeastThreeCount)

    let allOperations = Set(Operation.allCases)

    let mapping = determineMapping(possibleInstructions: possibleInstructions, allOperations: allOperations)

    var registers = Array<Int>(repeating: 0, count: 4)
    for line in input[lastAfter+1..<input.count] {
        let instructionData = line.split(separator: " ").compactMap({ Int($0) })
        if let operation = mapping[instructionData[0]] {
            let instruction = Instruction(operation: operation, a: instructionData[1], b: instructionData[2], c: instructionData[3])
            registers = instruction.apply(registers: registers)
        } else {
            exit(1)
        }
    }

    print(registers[0])
}