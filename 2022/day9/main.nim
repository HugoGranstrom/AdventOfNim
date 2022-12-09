include prelude, std / [strscans, tables]

type
  Vec = object
    x, y: int

proc `+`(v1, v2: Vec): Vec =
  Vec(x: v1.x + v2.x, y: v1.y + v2.y)

proc `-`(v1, v2: Vec): Vec =
  Vec(x: v1.x - v2.x, y: v1.y - v2.y)

proc dist2(v1, v2: Vec): int =
  (v1.x - v2.x) ^ 2 + (v1.y - v2.y) ^ 2

proc closestNeighbour(center, other: Vec): Vec =
  var closestDist = 100
  for dir in [Vec(x: 1, y: 0), Vec(x: 0, y: 1), Vec(x: -1, y: 0), Vec(x: 0, y: -1)]:
    let d = dist2(center, other + dir)
    if d < closestDist:
      closestDist = d
      result = center + dir

proc parseInput(input: string): seq[tuple[dir: Vec, steps: int]] =
  for line in input.splitLines:
    let (success, c, steps) = scanTuple(line, "$c $i")
    assert success
    if c == 'R':
      result.add (dir: Vec(x: 1, y: 0), steps: steps)
    elif c == 'U':
      result.add (dir: Vec(x: 0, y: 1), steps: steps)
    elif c == 'L':
      result.add (dir: Vec(x: -1, y: 0), steps: steps)
    elif c == 'D':
      result.add (dir: Vec(x: 0, y: -1), steps: steps)
    else:
      assert false


proc moveRope(rope: var seq[Vec], instr: tuple[dir: Vec, steps: int], history: var seq[Vec]) =
  var temp = rope # temp keep track of the old positions
  for am in 0 ..< instr.steps:
    rope[0] = rope[0] + instr.dir
    for i in 1 .. rope.high:
      let head = rope[i-1]
      let prevHead = temp[i-1]
      let tail = temp[i]
      let d2 = dist2(head, tail)
      if d2 > 2:
        if head.x == tail.x:
          rope[i] = tail + Vec(x: 0, y: sgn(head.y - tail.y))
        elif head.y == tail.y:
          rope[i] = tail + Vec(y: 0, x: sgn(head.x - tail.x))
        else:
          # Loop over all diagonals
          var closestDist = 100
          for x in [-1, 1]:
            for y in [-1, 1]:
              let neigh = tail + Vec(x: x, y: y)
              let d = dist2(neigh, head)
              if d < closestDist:
                rope[i] = neigh
                closestDist = d
    
    temp = rope # copy
    history.add rope[^1]


proc part1(input: string) =
  var tailHistory: seq[Vec] = @[Vec(x: 0, y: 0)]
  var rope = @[Vec(x: 0, y: 0), Vec(x: 0, y: 0)]
  let steps = parseInput(input)
  for step in steps:
    rope.moveRope(step, tailHistory)

  let countTab = tailHistory.toCountTable

  echo "Part 1: ", countTab.len

proc part2(input: string) =
  var tailHistory: seq[Vec] = @[Vec(x: 0, y: 0)]
  var rope = Vec(x: 0, y: 0).repeat(10)
  let steps = parseInput(input)
  for step in steps:
    rope.moveRope(step, tailHistory)

  let countTab = tailHistory.toCountTable

  echo "Part 2: ", countTab.len

let testInput1 = """
R 4
U 4
L 3
D 1
R 4
D 1
L 5
R 2"""

let testInput2 = """
R 5
U 8
L 8
D 3
R 17
D 10
L 25
U 20"""

when isMainModule:
  let input = readFile "input.txt"
  part1(input)
  part2(input)
