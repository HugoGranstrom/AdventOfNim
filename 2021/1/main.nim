import std/[strutils, sequtils, math]

proc parseInput(filename: string): seq[int] =
  for line in filename.lines:
    if line.len > 0:
      result.add parseInt(line)

proc diff(x: seq[int]): seq[int] =
  for i in 0 .. x.high - 1:
    result.add x[i+1] - x[i]

proc part1(depths: seq[int]): int =
  let diff = depths.diff
  let increases = diff.filterIt(it > 0)
  result = increases.len

proc part2(depths: seq[int]): int =
  var sumDepth: seq[int]
  for i in 0 .. depths.high - 2:
    sumDepth.add sum(depths[i .. i+2])
  result = part1(sumDepth)

let inputs = parseInput("input.txt")

echo "Part 1: ", part1(inputs)
echo "Part 2: ", part2(inputs)