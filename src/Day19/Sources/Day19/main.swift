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

func calc(registers: [Int], IPregister: Int, instructions: [Instruction]) {
    var IP = 0
    // Just do it a bit until we get the answer in register 3
    var steps = 20
    var registers = registers

    repeat {
        registers[IPregister] = IP
        let instruction = instructions[registers[IPregister]]
        registers[instruction.c] = instruction.apply(registers: registers)
        IP = registers[IPregister] + 1
        steps -= 1
    } while steps > 0

    var divisors: [Int] = [registers[3]]
    for d in 1...registers[3] / 2 {
        if registers[3] % d == 0 {
            divisors.append(d)
        }
    }

    print(divisors.reduce(0, +))
}

if let input: [String] = readInput(day: 19) {
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

        calc(registers: Array<Int>(repeating: 0, count: 6), IPregister: IPregister, instructions: instructions)
        calc(registers: [1, 0, 0, 0, 0, 0], IPregister: IPregister, instructions: instructions)
    }
}