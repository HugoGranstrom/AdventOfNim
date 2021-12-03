import std/[strutils, math, sequtils, algorithm]

proc getColumn(s: seq[string], col: int): seq[int] =
  for line in s:
    result.add parseInt($line[col])

proc parseBinNumber(bin: seq[int]): int =
  let bin = bin.reversed
  for i in 0 .. bin.high:
    result += 2 ^ i * bin[i]

proc part1(lines: seq[string]): int =
  var gammaBin: seq[int]
  var epsilonBin: seq[int]
  for col in 0 .. lines[0].high:
    let nums = lines.getColumn(col)
    let gamma = round(sum(nums) / lines.len).toInt
    gammaBin.add gamma
    epsilonBin.add 1 - gamma
  let gamma = parseBinNumber(gammaBin)
  let epsilon = parseBinNumber(epsilonBin)
  result = gamma * epsilon

proc part2(lines: seq[string]): int =
  var oxygenCandidates = lines
  var co2Candidates = lines
  for col in 0 .. lines[0].high:
    let nums = oxygenCandidates.getColumn(col)
    let mostCommon = round(sum(nums) / oxygenCandidates.len).toInt
    oxygenCandidates = oxygenCandidates.filterIt($it[col] == $mostCommon)
    if oxygenCandidates.len == 1:
      break
  for col in 0 .. lines[0].high:
    let nums = co2Candidates.getColumn(col)
    let leastCommon = 1 - round(sum(nums) / co2Candidates.len).toInt
    co2Candidates = co2Candidates.filterIt($it[col] == $leastCommon)
    if co2Candidates.len == 1:
      break
  doAssert co2Candidates.len == 1 and oxygenCandidates.len == 1
  let oxygen = parseBinNumber(oxygenCandidates[0].mapIt(($it).parseInt))
  let co2 = parseBinNumber(co2Candidates[0].mapIt(($it).parseInt))
  result = oxygen * co2

let input = "input.txt".lines.toSeq
let testInput = """00100
11110
10110
10111
10101
01111
00111
11100
10000
11001
00010
01010""".splitLines

echo "Part 1 test: ", part1(testInput)
echo "Part 1: ", part1(input)

echo "Part 2 test: ", part2(testInput)
echo "Part 2: ", part2(input)
