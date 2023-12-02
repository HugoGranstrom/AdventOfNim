include std / prelude
import std / [strscans, algorithm, math]

type
  Triplet = tuple[red, green, blue: int]
  Record = tuple[id: int, cubes: seq[Triplet]]


proc parseInput(input: string): seq[Record] =
  for line in input.strip.splitLines:
    let splitLine = line.split(':')
    let (succ, id) = splitLine[0].scantuple("Game $i")
    assert succ
    var record = (id: id, cubes: newSeq[tuple[red, green, blue: int]]())
    for draw in splitLine[1].split(';'):
      var tup: Triplet
      for color in draw.split(','):
        let (succ, count, col) = scanTuple(color.strip, "$i $w")
        assert succ
        if col == "red":
          tup.red = count
        elif col == "blue":
          tup.blue = count
        elif col == "green":
          tup.green = count
      record.cubes.add tup
    result.add record

proc satisfyLimit(triplets: seq[Triplet], limit: Triplet): bool =
  result = true
  for triple in triplets:
    if triple.red > limit.red or triple.blue > limit.blue or triple.green > limit.green:
      return false

proc part1(input: string): int =
  let records = parseInput(input)
  let limit = (red: 12, green: 13, blue: 14)
  for (id, cubes) in records:
    if cubes.satisfyLimit(limit):
      result += id

proc calcPower(triplets: seq[Triplet]): int =
  var maxTriple: Triplet
  for triple in triplets:
    maxTriple.red = max(triple.red, maxTriple.red)
    maxTriple.blue = max(triple.blue, maxTriple.blue)
    maxTriple.green = max(triple.green, maxTriple.green)
  result = maxTriple.red * maxTriple.blue * maxTriple.green

proc part2(input: string): int =
  let records = parseInput(input)
  for (_, colors) in records:
    result += calcPower(colors)

let testInput = """
Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green
"""

when isMainModule:
  let realInput = readFile("input.txt")
  let input = realInput
  let answer1 = part1(input)
  echo "Part 1: ", answer1
  let answer2 = part2(input)
  echo "Part 2: ", answer2