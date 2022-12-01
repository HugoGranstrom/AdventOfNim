import std / [strutils, algorithm, math]

proc getCalories(input: string): seq[int] =
  for elf in input.split("\n\n"):
    var calories: int
    for line in elf.splitLines:
      calories += parseInt(line)
    result.add calories

proc part1(input: string) =
  let cals = getCalories(input)
  echo "Part 1: ", max(cals)


proc part2(input: string) =
  var cals = getCalories(input)
  cals.sort(Descending)
  echo "Part 2: ", sum(cals[0..2])

when isMainModule:
  let input = readFile("input.txt")
  part1(input)
  part2(input)