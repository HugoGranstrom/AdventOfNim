import std/[strutils, enumerate, sequtils]
import arraymancer

proc parseBoard(boardString: string): Tensor[int] =
  result = zeros[int](5, 5)
  for i, line in enumerate(boardString.strip.splitLines):
    for j, num in enumerate(line.splitWhitespace):
      result[i, j] = parseInt(num)

proc checkWin(marked: Tensor[bool]): bool =
  for i in 0 .. 4:
    var correct: int
    for x in marked[i, _].squeeze:
      if x:
        correct += 1
    if correct == 5:
      return true
  for j in 0 .. 4:
    var correct: int
    for x in marked[_, j].squeeze:
      if x:
        correct += 1
    if correct == 5:
      return true
    
proc markBoard(board: Tensor[int], marked: var Tensor[bool], num: int) =
  for i in 0 .. 4:
    for j in 0 .. 4:
      if board[i, j] == num:
        marked[i, j] = true

proc calcScore(board: Tensor[int], marked: Tensor[bool], num: int): int =
  for i in 0 .. 4:
    for j in 0 .. 4:
      if not marked[i, j]:
        result += board[i, j]
  result *= num

proc parseBoards(boardsString: seq[string]): (seq[Tensor[int]], seq[Tensor[bool]]) =
  var boards: seq[Tensor[int]]
  var marked: seq[Tensor[bool]]
  for board in boardsString:
    boards.add parseBoard(board)
    marked.add newTensor[bool](5, 5)
  result = (boards, marked)

proc part1(numbers: seq[int], boardsString: seq[string]): int =
  var (boards, marked) = parseBoards(boardsString)
  for num in numbers:
    for i in 0 .. boards.high:
      boards[i].markBoard(marked[i], num)
      if checkWin(marked[i]):
        echo "Win!"
        return calcScore(boards[i], marked[i], num)

proc part2(numbers: seq[int], boardsString: seq[string]): int =
  var (boards, marked) = parseBoards(boardsString)
  for num in numbers:
    for i in countdown(boards.high, 0):
      boards[i].markBoard(marked[i], num)
      let win = checkWin(marked[i])
      if win and boards.len == 1:
        return calcScore(boards[i], marked[i], num)
      elif win:
        boards.delete(i)
        marked.delete(i)

let input = "input.txt".readFile.split("\n\n")
let numbers = input[0].split(",").mapIt(($it).parseInt)
let boards = input[1..^1]

echo "Part 1: ", part1(numbers, boards)
echo "Part 2: ", part2(numbers, boards)