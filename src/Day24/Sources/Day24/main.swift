import Shared
import Foundation


class Group {
    let index: String
    var units: Int
    let initialUnits: Int
    let hitpoints: Int
    let weaknesses: Set<String>
    let immune: Set<String>
    var damage: Int
    let initialDamage: Int
    let damageType: String
    let initiative: Int

    var effectivePower: Int {
        return units * damage
    }

    func damageTaken(group: Group) -> Int {
        if immune.contains(group.damageType) {
            return 0
        }

        if weaknesses.contains(group.damageType) {
            return 2 * group.effectivePower
        }

        return group.effectivePower
    }

    func attackedBy(group: Group) {
        let unitsLost: Int = damageTaken(group: group) / hitpoints
        units -= unitsLost
    }

    init(index: String, units: Int, hitpoints: Int, weaknesses: Set<String>, immune: Set<String>, damage: Int, damageType: String, initiative: Int) {
        self.index = index
        self.units = units
        self.initialUnits = units
        self.hitpoints = hitpoints
        self.weaknesses = weaknesses
        self.immune = immune
        self.damage = damage
        self.initialDamage = damage
        self.damageType = damageType
        self.initiative = initiative
    }

    func reset(boost: Int) {
        units = initialUnits
        damage = initialDamage + boost
    }
}

extension Group: Equatable {
    public static func ==(lhs: Group, rhs: Group) -> Bool {
        return lhs.index == rhs.index
    }
}

extension Group: Hashable {
    public func hash(into hasher: inout Hasher) {
        index.hash(into: &hasher)
    }
}

extension Group: CustomStringConvertible {
    public var description: String {
        return "\(index) (\(units))"
    }
}

extension Set where Element == Group {
    func reset(boost: Int) {
        for group in self {
            group.reset(boost: boost)
        }
    }
}

func parseWeaknessesImmune(input: String) -> (Bool, [String]) {
    let parts = input.trimmingCharacters(in: .whitespacesAndNewlines).split(separator: " ")

    let isWeakness = parts[0] == "weak"

    return (isWeakness, parts[2..<parts.count].map({ (item: Substring) in
        return item.trimmingCharacters(in: CharacterSet(charactersIn: ","))
    }))
}

func parseGroup(index: String, input: String) -> Group? {
    let pattern = "^(\\d+) units each with (\\d+) hit points( \\((.*)\\))? with an attack that does (\\d+) (\\w+) damage at initiative (\\d+)$"
    if let regex = try? NSRegularExpression(pattern: pattern) {
        let matches = regex.matches(in: input, range: NSMakeRange(0, input.utf16.count))
        if let match = matches.first {
            if let unitsMatch = Range(match.range(at: 1), in: input),
               let hitpointsMatch = Range(match.range(at: 2), in: input),
               let damageMatch = Range(match.range(at: 5), in: input),
               let damageTypeMatch = Range(match.range(at: 6), in: input),
               let initiativeMatch = Range(match.range(at: 7), in: input),
               let units = Int(input[unitsMatch]),
               let hitpoints = Int(input[hitpointsMatch]),
               let damage = Int(input[damageMatch]),
               let initiative = Int(input[initiativeMatch]) {
                let damageType = String(input[damageTypeMatch])

                var weaknesses: Set<String> = []
                var immune: Set<String> = []
                if let weaknessesImmuneMatch = Range(match.range(at: 4), in: input) {
                    let weaknessesImmuneSplit = input[weaknessesImmuneMatch].split(separator: ";")
                    let (isWeakness, specs) = parseWeaknessesImmune(input: String(weaknessesImmuneSplit[0]))
                    if isWeakness {
                        weaknesses = Set(specs)
                    } else {
                        immune = Set(specs)
                    }
                    if weaknessesImmuneSplit.count > 1 {
                        let (isWeakness, specs) = parseWeaknessesImmune(input: String(weaknessesImmuneSplit[1]))
                        if isWeakness {
                            weaknesses = Set(specs)
                        } else {
                            immune = Set(specs)
                        }
                    }
                }

                return Group(index: index, units: units, hitpoints: hitpoints, weaknesses: weaknesses, immune: immune, damage: damage, damageType: damageType, initiative: initiative)
            } else {
                exit(1)
            }
        } else {
            print(input)
            exit(2)
        }
    } else {
        exit(3)
    }
    return nil
}

func calculateLeft(immuneSystem: Set<Group>, infection: Set<Group>) -> (Bool, Int) {
    var immuneSystem = immuneSystem
    var infection = infection

    while !immuneSystem.isEmpty && !infection.isEmpty {
//        print("-- New round --")
        let allGroups = immuneSystem.union(infection)
        let allGroupCount = allGroups.count
        let allGroupUnits = allGroups.map({ $0.units }).reduce(0, +)

        // Targetting phase

        // First, sort by effective power
        let sortedGroups = allGroups.sorted(by: { (a: Group, b: Group) in
            if a.effectivePower != b.effectivePower {
                return a.effectivePower > b.effectivePower
            }
            return a.initiative > b.initiative
        })

        // Now determine which group to attack
        var attacks: [Group: Group] = [:]
        var attackedGroups: Set<Group> = []
        for group in sortedGroups {
            let groupsToAttack = (immuneSystem.contains(group) ? infection : immuneSystem).subtracting(attackedGroups)
            if let groupToAttack = groupsToAttack.max(by: { (a: Group, b: Group) in
                if a.damageTaken(group: group) != b.damageTaken(group: group) {
                    return a.damageTaken(group: group) < b.damageTaken(group: group)
                }

                if a.effectivePower != b.effectivePower {
                    return a.effectivePower < b.effectivePower
                }

                return a.initiative < b.initiative
            }) {
                if groupToAttack.damageTaken(group: group) > 0 {
//                    print("\(group) will attack \(groupToAttack)")
                    attacks[group] = groupToAttack
                    attackedGroups.insert(groupToAttack)
                }
            }
        }


        // Attacking phase
        let sortedGroupsForAttack = allGroups.sorted(by: { $0.initiative > $1.initiative })
        for group in sortedGroupsForAttack {
            if group.units <= 0 {
//                print("\(group) lost all its units already, can not attack")
            } else if let attackedGroup = attacks[group] {
//                print("\(group) attacks \(attackedGroup)")
                attackedGroup.attackedBy(group: group)
                if attackedGroup.units <= 0 {
                    immuneSystem.remove(attackedGroup)
                    infection.remove(attackedGroup)
//                    print("\(attackedGroup) died")
                } else {
//                    print("\(attackedGroup) is still alive")
                }
            }
        }

        // Detect if we are stuck
        let newAllGroups = immuneSystem.union(infection)
        let newAllGroupCount = newAllGroups.count
        let newAllGroupUnits = newAllGroups.map({ $0.units }).reduce(0, +)

        if allGroupCount == newAllGroupCount && allGroupUnits == newAllGroupUnits {
            return (false, -1)
        }
    }

    let allUnits = infection.union(immuneSystem)
    let totalUnitCount = allUnits.map({ $0.units }).reduce(0, +)

    return (infection.isEmpty, totalUnitCount)
}

if let input: [String] = readInput(day: 24) {
    var immuneSystem: Set<Group> = []
    var infection: Set<Group> = []

    var idx = 1
    var cnt = 1
    while input[idx] != "Infection:" {
        if let group = parseGroup(index: "immune-\(cnt)", input: input[idx]) {
            immuneSystem.insert(group)
        }
        cnt += 1
        idx += 1
    }

    cnt = 1
    for idx in idx + 1..<input.count {
        if let group = parseGroup(index: "infection-\(cnt)", input: input[idx]) {
            infection.insert(group)
        }
        cnt += 1
    }

    let (_, totalUnitCount) = calculateLeft(immuneSystem: immuneSystem, infection: infection)
    print(totalUnitCount)

    var immuneWins = false
    var boost = 0
    var totalUnitCountWithBoost = 0
    while !immuneWins {
        immuneSystem.reset(boost: boost)
        infection.reset(boost: 0)
        (immuneWins, totalUnitCountWithBoost) = calculateLeft(immuneSystem: immuneSystem, infection: infection)
        boost += 1
    }

    print(totalUnitCountWithBoost)
}
