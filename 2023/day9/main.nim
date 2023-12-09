include std / prelude
import std / [strscans, algorithm, math]

proc parseInput(input: string): seq[seq[int]] =
  for line in input.strip.splitLines:
    result.add line.splitWhitespace.map(parseInt)

proc diff(list: seq[int]): seq[seq[int]] =
  if list.allIt(it == 0):
    return @[list]
  var res: seq[int]
  for i in 0 .. list.high - 1:
    res.add list[i+1] - list[i]

  return @[list] & diff(res)

proc predict(diffs: seq[seq[int]]): int =
  result = 0
  for i in countdown(diffs.high - 1, 0):
    result = result + diffs[i][^1]

proc part1(input: string): int =
  let histories = parseInput(input)
  for hist in histories:
    let diffs = diff(hist)
    result += predict(diffs)

proc predictBackwards(diffs: seq[seq[int]]): int =
  result = 0
  for i in countdown(diffs.high - 1, 0):
    result = diffs[i][0] - result

proc part2(input: string): int =
  let histories = parseInput(input)
  for hist in histories:
    let diffs = diff(hist)
    result += predictBackwards(diffs)

let testInput = """
0 3 6 9 12 15
1 3 6 10 15 21
10 13 16 21 30 45
"""

when isMainModule:
  let realInput = readFile("input.txt")
  let input = realInput
  let answer1 = part1(input)
  echo "Part 1: ", answer1
  let answer2 = part2(input)
  echo "Part 2: ", answer2