import std/[strutils, sequtils, math, strscans, tables, algorithm]


proc calcFuel(crabs: seq[int], pos: int): int =
  for crab in crabs:
    result += abs(crab - pos)

proc calcFuel2(crabs: seq[int], pos: int): int =
  for crab in crabs:
    for i in 1 .. abs(crab - pos):
      result += i

proc part1(input: seq[int]): int =
  var fuels: seq[int]
  for pos in min(input) .. max(input):
    let fuel = calcFuel(input, pos)
    fuels.add fuel
  let minI = minIndex(fuels)
  result = fuels[minI]

proc part2(input: seq[int]): int =
  var fuels: seq[int]
  for pos in min(input) .. max(input):
    let fuel = calcFuel2(input, pos)
    fuels.add fuel
  let minI = minIndex(fuels)
  result = fuels[minI]

let input = "input.txt".readFile.split(",").mapIt(it.parseInt)
let testInput = "16,1,2,0,4,2,7,1,2,14".split(",").mapIt(it.parseInt)
echo "Mean: ", sum(input) / len(input)

echo "Part 1 (test): ", part1(testInput)
echo "Part 1: ", part1(input)

echo "Part 2 (test): ", part2(testInput)
echo "Part 2: ", part2(input)
