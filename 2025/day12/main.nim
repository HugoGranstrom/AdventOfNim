import batteries
import std / [strscans, algorithm, math]

proc parseInput(input: string): seq[tuple[size: int, content: int]] =
  var shapeSize: Table[int, int]
  for blk in input.strip.split("\n\n")[^1].splitlines:
    var width, height: int
    var content: string
    if blk.scanf("$ix$i: $+", width, height, content):
      echo content
      result.add (width * height, content.split.mapIt(it.parseInt).sum * 9)

proc part1(input: string): int =
  let stuff = parseInput(input)
  stuff.filterIt(it.content <= it.size).len
  

proc part2(input: string): int =
  discard

let testInput = """
0:
###
##.
##.

1:
###
##.
.##

2:
.##
###
##.

3:
##.
###
##.

4:
###
#..
###

5:
###
.#.
###

4x4: 0 0 0 0 2 0
12x5: 1 0 1 0 2 2
12x5: 1 0 1 0 3 2
"""

when isMainModule:
  let realInput = readFile("input.txt")
  let input = realInput
  let answer1 = part1(input)
  echo "Part 1: ", answer1
  let answer2 = part2(input)
  echo "Part 2: ", answer2