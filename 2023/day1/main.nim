include std / prelude
import std / [strscans, algorithm, math]

proc parseInput(input: string): seq[int] =
  for line in input.strip.splitLines:
    var num: int
    for c in line:
      if c.isDigit:
        num += 10 * parseInt($c)
        break
    for c in line.reversed:
      if c.isDigit:
        num += parseInt($c)
        break
    result.add num

let word2num = {
  "one": 1,
  "two": 2,
  "three": 3,
  "four": 4,
  "five": 5,
  "six": 6,
  "seven": 7,
  "eight": 8,
  "nine": 9
}.toTable

proc parseInput2(input: string): seq[int] =
  for line in input.strip.splitLines:
    var num: int
    block firstNum:
      for i, c in line:
        if c.isDigit:
          num += 10 * parseInt($c)
          break
        for word, value in word2num.pairs:
          if line.len > i + word.len and line[i ..< i + word.len] == word:
            num += 10 * value
            break firstNum
    block lastNum:
      for i in countdown(line.high, 0):
        let c = line[i]
        if c.isDigit:
          num += parseInt($c)
          break
        for word, value in word2num.pairs:
          if line.len >= i + word.len and line[i ..< i + word.len] == word:
            num += value
            break lastNum
    result.add num

proc part1(input: string): int =
  let numbers = parseInput(input)
  return sum(numbers)

proc part2(input: string): int =
  let numbers = parseInput2(input)
  echo numbers
  return sum(numbers)

let testInput = """
1abc2
pqr3stu8vwx
a1b2c3d4e5f
treb7uchet
"""

let testInput2 = """
two1nine
eightwothree
abcone2threexyz
xtwone3four
4nineeightseven2
zoneight234
7pqrstsixteen
"""

when isMainModule:
  let realInput = readFile("input.txt")
  let input = realInput
  let answer1 = part1(input)
  echo "Part 1: ", answer1
  let answer2 = part2(input)
  echo "Part 2: ", answer2