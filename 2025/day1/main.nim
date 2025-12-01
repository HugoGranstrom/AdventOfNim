import batteries
import std / [strscans, algorithm, math]

proc parseInput(input: string): seq[int] =
  for line in input.strip.splitLines:
    let (succ, dir, amount) = scantuple(line, "$c$i")
    result.add amount * (if dir == 'R': 1 else: -1)

proc turnDial(current: int, max: int, amount: int): int =
  (current + amount).euclMod(max)

proc part1(input: string): int =
  let input = parseInput(input)
  var nZeros = 0
  var dial = 50
  for turnAmount in input:
    dial = dial.turnDial(100, turnAmount)
    nZeros += int(dial == 0)
  nZeros

proc part2(input: string): int =
  let input = parseInput(input)
  var nZeros = 0
  var dial = 50
  for turnAmount in input:
    let step = sgn(turnAmount)
    for i in 1 .. abs(turnAmount):
      dial = dial.turnDial(100, step)
      nZeros += int(dial == 0)
  nZeros

let testInput = """
L68
L30
R48
L5
R60
L55
L1
L99
R14
L82
"""

when isMainModule:
  let realInput = readFile("input.txt")
  let input = realInput
  let answer1 = part1(input)
  echo "Part 1: ", answer1
  let answer2 = part2(input)
  echo "Part 2: ", answer2