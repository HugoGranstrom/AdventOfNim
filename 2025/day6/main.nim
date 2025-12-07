import batteries
import std / [strscans, algorithm, math]

type
  Op = enum
    Add = "+"
    Mul = "*"

  OpNumbers = tuple[op: Op, numbers: seq[int]]

proc parseInputPart1(input: string): seq[OpNumbers] =
  let lines = input.strip.splitlines.mapIt(it.splitWhitespace)
  let nCols = lines[0].len
  result = newSeq[OpNumbers](nCols)
  for line in lines[0..^2]:
    for i, x in line:
      result[i].numbers.add parseInt(x)
  for i, op in lines[^1]:
    result[i].op = parseEnum[Op](op)

proc splitAtIndexes(s: string, indexes: seq[int]): seq[string] =
  for i in 0 .. indexes.high - 1:
    result.add s[indexes[i] ..< indexes[i+1]-1]
  if indexes[^1] != s.high:
    result.add s[indexes[^1]..s.high]

proc parseInputPart2(input: string): seq[OpNumbers] =
  let lines = input.strip.splitlines
  let opsLine = lines[^1]
  let opsLineSplit = opsLine.splitWhitespace
  let nCols = opsLineSplit.len
  let nRows = lines.len
  result = newSeq[OpNumbers](nCols)
  for i, op in opsLineSplit:
    result[i].op = parseEnum[Op](op)
  let splitIndexes = collect(newSeq):
    for i, x in opsLine:
      if x != ' ':
        i
  let numLines = lines[0..^2].mapIt(it.splitAtIndexes(splitIndexes))
  for group in 0 ..< nCols:
    let groupLines = collect:
      for j in 0 ..< nRows - 1:
        numLines[j][group]
    let maxLen = max(groupLines.mapIt(it.len))
    for i in 0 ..< maxLen:
      var numString = ""
      for j in 0 .. groupLines.high:
        numString &= groupLines[j][i]
      result[group].numbers.add numString.strip.parseInt



proc convertToCephalopodMath(opNum: OpNumbers): OpNumbers =
  var numStrings = opNum.numbers.mapIt($it)
  let maxLen = max(numStrings.mapIt(it.len))
  numStrings = numStrings.mapIt(it.alignLeft(maxLen, ' '))
  for i in 0 ..< maxLen:
    var numString = ""
    for j in 0 .. numStrings.high:
      numString &= numStrings[j][i]
    result.numbers.add numString.strip.parseInt

proc calcOpNumber(opNum: OpNumbers): int =
  case opNum.op
  of Add:
    sum(opNum.numbers)
  of Mul:
    var prod = 1
    for x in opNum.numbers:
      prod *= x 
    prod

proc part1(input: string): int =
  let input = parseInputPart1(input)
  for opNum in input:
    result += calcOpNumber(opNum)

proc part2(input: string): int =
  let input = parseInputPart2(input)
  for opNum in input:
    result += calcOpNumber(opNum)

let testInput = """
123 328  51 64 
 45 64  387 23 
  6 98  215 314
*   +   *   +  
"""

when isMainModule:
  let realInput = readFile("input.txt")
  let input = realInput
  let answer1 = part1(input)
  echo "Part 1: ", answer1
  let answer2 = part2(input)
  echo "Part 2: ", answer2