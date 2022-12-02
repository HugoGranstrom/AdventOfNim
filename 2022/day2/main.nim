include prelude
import std / strscans

type
  Hand = enum
    Rock, Paper, Scissor

let loseTable = {Rock: Paper, Scissor: Rock, Paper: Scissor}.toTable
let winTable = {Rock: Scissor, Scissor: Paper, Paper: Rock}.toTable

proc readInputPart1(input: string, leftMap, rightMap: Table[char, Hand]): tuple[left: seq[Hand], right: seq[Hand]] =
  for line in input.splitLines:
    let (success, l, r) = scanTuple(line, "$c $c")
    assert success
    result.left.add leftMap[l]
    result.right.add rightMap[r]


proc gameScore(opponent, me: Hand): int =
  let shapeScore = {Rock: 1, Paper: 2, Scissor: 3}.toTable
  result = shapeScore[me]
  if me == opponent:
    result += 3
  elif winTable[me] == opponent:
    result += 6

proc part1(input: string) =
  let leftTab = {'A': Rock, 'B': Paper, 'C': Scissor}.toTable
  let rightTab = {'X': Rock, 'Y': Paper, 'Z': Scissor}.toTable
  let (opponent, me) = readInputPart1(input, leftTab, rightTab)
  var score = 0
  for i in 0 .. me.high:
    score += gameScore(opponent[i], me[i])

  echo "Part 1: ", score


proc readInputPart2(input: string, leftMap: Table[char, Hand]): tuple[left: seq[Hand], right: seq[Hand]] =
  for line in input.splitLines:
    let (success, l, r) = scanTuple(line, "$c $c")
    assert success
    let opponent = leftMap[l]
    result.left.add opponent
    if r == 'X':
      result.right.add winTable[opponent]
    elif r == 'Y':
      result.right.add opponent
    elif r == 'Z':
      result.right.add loseTable[opponent]
    else:
      assert false
    
proc part2(input: string) =
  let leftTab = {'A': Rock, 'B': Paper, 'C': Scissor}.toTable
  let (opponent, me) = readInputPart2(input, leftTab)
  var score = 0
  for i in 0 .. me.high:
    score += gameScore(opponent[i], me[i])

  echo "Part 2: ", score

let testInput1 = """
A Y
B X
C Z"""

when isMainModule:
  let input = readFile("input.txt")
  part1(input)
  part2(input)