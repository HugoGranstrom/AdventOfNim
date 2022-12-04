include prelude
import std / [strscans]

proc readInput(input: string): seq[(HSlice[int, int], HSlice[int, int])] =
  for line in input.splitLines:
    let (success, a1, b1, a2, b2) = scanTuple(line, "$i-$i,$i-$i")
    assert success
    result.add (a1 .. b1, a2 .. b2)
    
proc fullyContained(r1, r2: HSlice[int, int]): bool =
  (r1.a in r2 and r1.b in r2) or (r2.a in r1 and r2.b in r1) 

proc part1(input: string) =
  let ranges = readInput(input)
  var nFullyContained = 0
  for (r1, r2) in ranges:
    if fullyContained(r1, r2):
      nFullyContained += 1
  
  echo "Part 1: ", nFullyContained
  
proc partiallyContained(r1, r2: HSlice[int, int]): bool =
  (r1.a in r2 or r1.b in r2) or (r2.a in r1 or r2.b in r1) 

proc part2(input: string) =
  let ranges = readInput(input)
  var nPartiallyContained = 0
  for (r1, r2) in ranges:
    if partiallyContained(r1, r2):
      nPartiallyContained += 1

  echo "Part 2: ", nPartiallyContained

when isMainModule:
  let input = readFile("input.txt")
  part1(input)
  part2(input)