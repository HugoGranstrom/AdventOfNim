import batteries
import std / [strscans, algorithm, math]
import itertools

type
  Button = object
    lights: seq[int]

  Machine = object
    lights: seq[bool]
    wantedLights: seq[bool]
    buttons: seq[Button]
    joltages: seq[int]
    wantedJoltages: seq[int]

proc reset(m: var Machine) =
  for x in m.lights.mitems:
    x = false
  for x in m.joltages.mitems:
    x = 0

proc toggle*(m: var Machine, button: Button) =
  for i in button.lights:
    m.lights[i] = not m.lights[i]

proc press(m: var Machine, button: Button) =
  for i in button.lights:
    m.joltages[i] += 1

proc verifySolution1(m: var Machine, solution: seq[int]): bool =
  m.reset()
  for i in solution:
    m.toggle(m.buttons[i])
  m.lights == m.wantedLights

proc verifySolution2(m: var Machine, solution: seq[int]): bool =
  m.reset()
  for i, n in solution:
    # press button_i n times
    for _ in 0 ..< n:
      m.press(m.buttons[i])
  m.joltages == m.wantedJoltages

proc solve1(m: var Machine): int =
  let nButtons = m.buttons.len
  for solutionLen in 1 .. nButtons:
    for candidate in combinations(nButtons, solutionLen):
      if m.verifySolution1(candidate):
        return solutionLen
  assert false, "Didn't find a solution"

iterator optimizedProduct(cache: var seq[int], s: openarray[int], repeat: int): lent seq[int] =
  var counters = newSeq[int](repeat)
  cache = newSeq[int](repeat)
  block outer:
    while true:
      for x in cache.mitems:
        x = 0
      for i, cnt in counters:
        cache[i] = s[cnt]
      yield cache

      var i = repeat - 1
      while true:
        inc counters[i]
        if counters[i] == s.len:
          counters[i] = 0
          dec i
        else: break
        if i < 0:
          break outer

proc solve2(m: var Machine): int =
  var bestSolution: seq[int]
  var bestScore = int.high
  var solutionFound = false
  for maxValue in countup(1, 100):
    echo "Checking solutions of length: ", maxValue
    var options = (0 .. min(bestScore, maxValue)).toSeq
    var cache: seq[int]
    for candidate in cache.optimizedProduct(options, m.buttons.len):
      #for candidate in product(options, m.buttons.len):
      #echo candidate
      if sum(candidate) < bestScore and m.verifySolution2(candidate):
        let score = sum(candidate)
        if score < bestScore:
          bestScore = score
          bestSolution = candidate
          solutionFound = true
          echo "Found solution: ", bestScore
      if solutionFound and maxValue > bestScore:
        return bestScore
  #return bestScore
  assert false, "No solution was found"

proc parseInput(input: string): seq[Machine] =
  for line in input.strip.splitLines:
    var m: Machine
    for blk in line.split:
      var content: string
      if blk.scanf("[$+]", content):
        for c in content:
          m.wantedLights.add c == '#'
      elif blk.scanf("($+)", content):
        m.buttons.add Button(lights: content.split(',').mapIt(it.parseInt))
      elif blk.scanf("{$+}", content):
        m.wantedJoltages = content.split(',').mapIt(it.parseInt)
    m.lights = newSeqWith(m.wantedLights.len, false)
    m.joltages = newSeqWith(m.wantedJoltages.len, 0)
    result.add m

proc part1(input: string): int =
  var machines = parseInput(input)
  for machine in machines.mitems:
    result += solve1(machine)

proc part2(input: string): int =
  var machines = parseInput(input)
  for i, machine in machines.mpairs:
    #if i == 0: continue
    echo i
    result += solve2(machine)

let testInput = """
[.##.] (3) (1,3) (2) (2,3) (0,2) (0,1) {3,5,4,7}
[...#.] (0,2,3,4) (2,3) (0,4) (0,1,2) (1,2,3,4) {7,5,12,7,2}
[.###.#] (0,1,2,3,4) (0,3,4) (0,1,2,4,5) (1,2) {10,11,11,5,10,5}
"""

when isMainModule:
  let realInput = readFile("input.txt")
  let input = realInput
  let answer1 = part1(input)
  echo "Part 1: ", answer1
  let answer2 = part2(input)
  echo "Part 2: ", answer2