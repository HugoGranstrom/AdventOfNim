import std/[strutils, sequtils, math, strscans, tables, algorithm, sets, enumerate, strformat]

proc isClosing(c: char): bool =
  result = c in [')', ']', '}', '>']

proc isOpening(c: char): bool =
  result = c in ['(', '[', '{', '<']

proc getClosing(c: char): char =
  if c == '(': result = ')'
  elif c == '[': result = ']'
  elif c == '{': result = '}'
  elif c == '<': result = '>'
  else:
    doAssert false, $c

proc getScore(c: char): int =
  if c == ')': result = 3
  elif c == ']': result = 57
  elif c == '}': result = 1197
  elif c == '>': result = 25137
  else:
    doAssert false, $c

proc scoreLine(s: string): int =
  result = 0
  for c in s:
    result *= 5
    if c == ')': result += 1
    elif c == ']': result += 2
    elif c == '}': result += 3
    elif c == '>': result += 4
    else: doAssert false

proc verifyLine(s: string): int =
  ## Returns the index of the fail. If success returns -1
  result = -1
  var memory: seq[char] = @[s[0]]
  for i, c in s[1..^1]:
    if c.isClosing:
      if c == memory[^1].getClosing:
        discard memory.pop
      else:
        return i + 1 # add one because we start at index 1!
    elif c.isOpening:
      memory.add c

proc completeLine(s: string): string =
  var memory: seq[char] = @[s[0]]
  for i, c in s[1..^1]:
    if c.isClosing:
      doAssert c == memory[^1].getClosing
      discard memory.pop
    elif c.isOpening:
      memory.add c
  for c in reversed(memory):
    result.add c.getClosing

proc part1(input: seq[string]): int =
  for line in input:
    let errorI = verifyLine(line)
    if errorI != -1:
      result += getScore(line[errorI])

proc part2(input: seq[string]): int =
  var incomplete: seq[string]
  for line in input:
    if line.verifyLine == -1:
      incomplete.add line
  var scores: seq[int]
  for line in incomplete:
    let completition = line.completeLine
    scores.add completition.scoreLine
  scores.sort()
  result = scores[scores.high div 2]

let input = "input.txt".readFile.splitLines

let testInput = """[({(<(())[]>[[{[]{<()<>>
[(()[<>])]({[<{<<[]>>(
{([(<{}[<>[]}>{[]{[(<()>
(((({<>}<{<{<>}{[]{[]{}
[[<[([]))<([[{}[[()]]]
[{[{({}]{}}([{[{{{}}([]
{<[[]]>}<{[{[{[]{()[[[]
[<(<(<(<{}))><([]([]()
<{([([[(<>()){}]>(<<{{
<{([{{}}[<[[[<>{}]]]>[]]""".splitLines

echo "Part 1 (test): ", part1(testInput)
echo "Part 1: ", part1(input)
echo "Part 2 (test): ", part2(testInput)
echo "Part 2: ", part2(input)