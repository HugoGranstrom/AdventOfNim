import std/[strutils, sequtils, math, strscans, tables, algorithm]

proc part1(fishesInitial: seq[int]): int =
  var fishes = fishesInitial
  for day in 0 ..< 80:
    for i in countdown(fishes.high, 0):
      if fishes[i] == 0:
        fishes[i] = 6
        fishes.add 8
      else:
        fishes[i] -= 1
  result = fishes.len 

proc part2(fishesInitial: seq[int]): int =
  var fishDays: array[9, int]
  for i in 0 .. fishDays.high:
    fishDays[i] = fishesInitial.count i
  for day in 0 ..< 256:
    var newFishDays: array[9, int]
    for i in countdown(fishDays.high, 0):
      if i == 0:
        newFishDays[8] = fishDays[0]
        newFishDays[6] += fishDays[0]
      else:
        newFishDays[i-1] = fishDays[i]
    fishDays = newFishDays
  result = fishDays.sum


let input = "input.txt".readFile.split(",").mapIt(it.parseInt)
echo "Part 1: ", part1(input)
echo "Part 2: ", part2(input)