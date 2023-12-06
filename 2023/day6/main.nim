include std / prelude
import std / [strscans, algorithm, math]



proc parseInput(input: string): (seq[int], seq[int]) =
  let lines = input.strip.splitLines()
  result[0] = lines[0].split(':')[1].strip.splitWhitespace.map(parseInt)
  result[1] = lines[1].split(':')[1].strip.splitWhitespace.map(parseInt)

proc calcWaysToWin(t, d: int): int =
  result = 0
  for i in 1 .. t:
    if i * (t - i) > d:
      result += 1

proc part1(input: string): int =
  let (times, dists) = parseInput(input)
  result = 1
  for (t, d) in zip(times, dists):
    let counter = calcWaysToWin(t, d)
    result *= counter

proc parseInput2(input: string): (int, int) =
  let lines = input.strip.splitLines()
  result[0] = lines[0].split(':')[1].strip.replace(" ", "").parseInt
  result[1] = lines[1].split(':')[1].strip.replace(" ", "").parseInt

proc part2(input: string): int =
  let (t, d) = parseInput2(input)
  result = calcWaysToWin(t, d)

let testInput = """
Time:      7  15   30
Distance:  9  40  200
"""

when isMainModule:
  let realInput = readFile("input.txt")
  let input = realInput
  let answer1 = part1(input)
  echo "Part 1: ", answer1
  let answer2 = part2(input)
  echo "Part 2: ", answer2