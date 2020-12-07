import sets, tables, strutils

type
  Answer = 'a' .. 'z'

proc part1(): int =
  let data = readFile("day6.txt")
  for group in data.split("\n\n"):
    var answers: set[Answer]
    for line in group.splitLines:
      for c in line:
        answers.incl c
    result += answers.len

proc part2(): int =
  let data = readFile("day6.txt")
  for group in data.split("\n\n"):
    var answers: CountTable[Answer]
    for line in group.splitLines:
      for c in line:
        answers.inc c
    for (keys, count) in answers.pairs:
      if count == group.countLines:
        result += 1

when isMainModule:
  echo "Part1: ", part1()
  echo "Part2: ", part2()