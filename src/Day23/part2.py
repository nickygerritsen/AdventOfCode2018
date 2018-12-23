import re
import z3

bots = []
with open("../../input/day23.txt") as file:
    for line in file:
        x, y, z, r = map(int, re.findall(r'-?\d+', line))
        bots.append((r, x, y, z))

def distOneDimension(a, b):
    d = a - b
    return z3.If(d >= 0, d, -d)

def manhattan(ax, ay, az, bx, by, bz):
    return distOneDimension(ax, bx) + distOneDimension(ay, by) + distOneDimension(az, bz)

solver = z3.Optimize()

bestx = z3.Int('bestx')
besty = z3.Int('besty')
bestz = z3.Int('bestz')
distance = z3.Int('distance')

inside = []
for idx, bot in enumerate(bots):
    botr, *botxyz = bot
    bot = z3.Int('b{:4d}'.format(idx))
    ok = z3.If(manhattan(bestx, besty, bestz, *botxyz) <= botr, 1, 0)
    solver.add(bot == ok)
    inside.append(bot)

solver.add(distance == manhattan(bestx, besty, bestz, 0, 0, 0))

solver.maximize(z3.Sum(*inside))
solver.minimize(distance)
solver.check()

model = solver.model()
minDistance = model.eval(distance)

print(minDistance)
