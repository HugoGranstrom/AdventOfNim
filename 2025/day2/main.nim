import batteries
import std / [strscans, algorithm, math]

proc parseInput(input: string): seq[(int, int)] =
  input.split(',').mapIt(scanTuple(it, "$i-$i")).mapIt((it[1], it[2]))

proc isInvalidPart1(x: int): bool =
  let xs = $x
  if xs.len mod 2 == 1: return false
  let x1 = xs[0 ..< xs.len div 2]
  let x2 = xs[xs.len div 2 .. ^1]
  if x2.startsWith("0"): return false
  x1 == x2

proc isInvalidPart2(x: int): bool =
  let xs = $x
  for nParts in 2 .. xs.len:
    if xs.len mod nParts == 0:
      let subLen = xs.len div nParts
      let base = xs[0 ..< subLen]
      var allMatch = true
      for i in 1 ..< nParts:
        let sub = xs[i*subLen ..< (i+1)*subLen]
        if sub != base:
          allMatch = false
      if allMatch: return true
  return false

proc getInvalidInRangePart1(a, b: int): seq[int] =
  for x in a .. b:
    if isInvalidPart1(x):
      result.add x

proc getInvalidInRangePart2(a, b: int): seq[int] =
  for x in a .. b:
    if isInvalidPart2(x):
      result.add x


proc part1(input: string): int =
  let nums = parseInput(input)
  var invalids: seq[int]
  for (a, b) in nums:
    invalids.add(getInvalidInRangePart1(a, b))
  sum(invalids)

proc part2(input: string): int =
  let nums = parseInput(input)
  var invalids: seq[int]
  for (a, b) in nums:
    invalids.add(getInvalidInRangePart2(a, b))
  sum(invalids)

let testInput = """
11-22,95-115,998-1012,1188511880-1188511890,222220-222224,
1698522-1698528,446443-446449,38593856-38593862,565653-565659,
824824821-824824827,2121212118-2121212124
""".replace("\n", "")

when isMainModule:
  let realInput = readFile("input.txt")
  let input = realInput
  let answer1 = part1(input)
  echo "Part 1: ", answer1
  let answer2 = part2(input)
  echo "Part 2: ", answer2