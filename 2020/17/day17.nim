import std/[strutils, sets, hashes, enumerate, sequtils]

type
  Vec3 = object
    x, y, z: int
  Vec4 = object
    x, y, z, w: int
  States[T: Vec3 or Vec4] = HashSet[T]

proc hash(v: Vec3): Hash =
  result = v.x.hash !& v.y.hash !& v.z.hash
  result = !$result

proc hash(v: Vec4): Hash =
  result = v.x.hash !& v.y.hash !& v.z.hash !& v.w.hash
  result = !$result

iterator neighbourVec(v: Vec3): Vec3 =
  for dx in -1 .. 1:
    for dy in -1 .. 1:
      for dz in -1 .. 1:
        if dx == 0 and dy == 0 and dz == 0:
          continue
        yield Vec3(x: v.x + dx, y: v.y + dy, z: v.z + dz)

iterator neighbourVec(v: Vec4): Vec4 =
  for dx in -1 .. 1:
    for dy in -1 .. 1:
      for dz in -1 .. 1:
        for dw in -1 .. 1:
          if dx == 0 and dy == 0 and dz == 0 and dw == 0:
            continue
          yield Vec4(x: v.x + dx, y: v.y + dy, z: v.z + dz, w: v.w + dw)

proc neighbours[T](v: T, currentState: bool, state: States[T], neighbourStates: var States[T], switchNext: var States[T]) =
  var counter: int
  for k, neigh in enumerate(v.neighbourVec):
    if neigh in state:
      inc counter
    else:
      neighbourStates.incl neigh
  if currentState and counter notin 2..3:
    # if there are not exactly 2 or 3 neighbours, switch it off in the next round
    switchNext.incl v
  elif not(currentState) and counter == 3:
    switchNext.incl v
    
    


proc loadStatePart1(s: string): States[Vec3] =
  for i, line in enumerate(s.strip.splitLines):
    for j in 0 .. line.high:
      let v = Vec3(x: j, y: -i, z: 0)
      if line[j] == '#':
        result.incl v

proc loadStatePart2(s: string): States[Vec4] =
  for i, line in enumerate(s.strip.splitLines):
    for j in 0 .. line.high:
      let v = Vec4(x: j, y: -i, z: 0, w: 0)
      if line[j] == '#':
        result.incl v

proc testPart1() =
  let input = """.#.
..#
###"""
  var state = loadStatePart1(input)
  for round in 1 .. 6:
    var switchNext: States[Vec3]
    var neighbourStates: States[Vec3]
    for v in state:
      v.neighbours(true, state, neighbourStates, switchNext)
    var dummyState: States[Vec3] # we don't want to know the neighbours of the neighbours because they will stay inactive.
    for v in neighbourStates:
      v.neighbours(false, state, dummyState, switchNext)
    for v in switchNext:
      if v in state:
        state.excl v
      else:
        state.incl v
  assert state.len == 112

proc part1(): int =
  var state = loadStatePart1(readFile("day17.txt"))
  for round in 1 .. 6:
    var switchNext: States[Vec3]
    var neighbourStates: States[Vec3]
    for v in state:
      v.neighbours(true, state, neighbourStates, switchNext)
    var dummyState: States[Vec3] # we don't want to know the neighbours of the neighbours because they will stay inactive.
    for v in neighbourStates:
      v.neighbours(false, state, dummyState, switchNext)
    for v in switchNext:
      if v in state:
        state.excl v
      else:
        state.incl v
  result = state.len

proc part2(): int =
  var state = loadStatePart2(readFile("day17.txt"))
  for round in 1 .. 6:
    var switchNext: States[Vec4]
    var neighbourStates: States[Vec4]
    for v in state:
      v.neighbours(true, state, neighbourStates, switchNext)
    var dummyState: States[Vec4] # we don't want to know the neighbours of the neighbours because they will stay inactive.
    for v in neighbourStates:
      v.neighbours(false, state, dummyState, switchNext)
    for v in switchNext:
      if v in state:
        state.excl v
      else:
        state.incl v
  result = state.len
  

when isMainModule:
  testPart1()
  let p1 = part1()
  echo "Part 1: ", p1
  let p2 = part2()
  echo "Part 2: ", p2
