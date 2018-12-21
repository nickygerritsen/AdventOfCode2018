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

    func apply(registers: [Int]) -> Int {
        var registers = registers

        switch operation {
        case .addr:
            return registers[a] + registers[b]
        case .addi:
            return registers[a] + b
        case .mulr:
            return registers[a] * registers[b]
        case .muli:
            return registers[a] * b
        case .banr:
            return registers[a] & registers[b]
        case .bani:
            return registers[a] & b
        case .borr:
            return registers[a] | registers[b]
        case .bori:
            return registers[a] | b
        case .setr:
            return registers[a]
        case .seti:
            return a
        case .gtir:
            return a > registers[b] ? 1 : 0
        case .gtri:
            return registers[a] > b ? 1 : 0
        case .gtrr:
            return registers[a] > registers[b] ? 1 : 0
        case .eqir:
            return a == registers[b] ? 1 : 0
        case .eqri:
            return registers[a] == b ? 1 : 0
        case .eqrr:
            return registers[a] == registers[b] ? 1 : 0
        }
    }
}

func partA(IPregister: Int, instructions: [Instruction]) {
    // Find the first time the eqrr with b = 0 is done and print the value of r[a]
    var registers = [0, 0, 0, 0, 0, 0]
    var IP = 0
    repeat {
        registers[IPregister] = IP
        let instruction = instructions[registers[IPregister]]
        if instruction.operation == .eqrr && instruction.b == 0 {
            print(registers[instruction.a])
            break
        }
        registers[instruction.c] = instruction.apply(registers: registers)

        IP = registers[IPregister] + 1
    } while true
}

func partB(IPregister: Int, instructions: [Instruction]) {
    // Find the first time the register value repeats
    var registerValues: Set<Int> = []
    var registers = [0, 0, 0, 0, 0, 0]
    var IP = 0
    var last = -1
    repeat {
        registers[IPregister] = IP
        let instruction = instructions[registers[IPregister]]
        if instruction.operation == .eqrr && instruction.b == 0 {
            if registerValues.contains(registers[instruction.a]) {
                print(last)
                break
            }
            registerValues.insert(registers[instruction.a])
            last = registers[instruction.a]
        }
        registers[instruction.c] = instruction.apply(registers: registers)

        IP = registers[IPregister] + 1
    } while true
}

if let input: [String] = readInput(day: 21) {
    if let optionalIP = input.first?.split(separator: " ").last.map({ String($0) }),
       let IPregister = Int(optionalIP) {

        var instructions: [Instruction] = []
        for line in input[1..<input.count] {
            let parts = line.split(separator: " ")

            if let operation = Operation(rawValue: String(parts[0])),
               let a = Int(String(parts[1])),
               let b = Int(String(parts[2])),
               let c = Int(String(parts[3])) {
                instructions.append(Instruction(operation: operation, a: a, b: b, c: c))
            }
        }

        partA(IPregister: IPregister, instructions: instructions)
        partB(IPregister: IPregister, instructions: instructions)
    }
}