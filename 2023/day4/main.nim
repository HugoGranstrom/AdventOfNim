include std / prelude
import std / [strscans, algorithm, math]

proc parseInput(input: string): seq[tuple[winning: seq[int], yours: seq[int]]] =
  for line in input.strip.splitLines:
    let splitted = line.split(':')[1].split('|')
    var tup: (seq[int], seq[int])
    tup[0] = splitted[0].strip.splitWhitespace.mapIt(parseInt(it))
    tup[1] = splitted[1].strip.splitWhitespace.mapIt(parseInt(it))
    result.add tup

proc part1(input: string): int =
  let numbers = parseInput(input)
  for (winning, yours) in numbers:
    var value = 0
    for x in yours:
      if x in winning:
        value =
          if value == 0:
            1
          else:
            value * 2
    result += value

proc part2(input: string): int =
  let numbers = parseInput(input)
  var tally: Table[int, tuple[winning, count: int]] # id, (winning, count)
  for i, (winning, yours) in numbers:
    var num = 0
    for x in yours:
      if x in winning:
        num += 1
    tally[i+1] = (num, 1)
  
  echo tally

  for id in 1 .. numbers.len:
    let (winning, count) = tally[id]
    for nextId in id + 1 ..< id + 1 + winning:
      tally[nextId].count += count
  
  echo tally

  for (winning, count) in tally.values:
    result += count
    

let testInput = """
Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11
"""

when isMainModule:
  let realInput = readFile("input.txt")
  let input = realInput
  let answer1 = part1(input)
  echo "Part 1: ", answer1
  let answer2 = part2(input)
  echo "Part 2: ", answer2