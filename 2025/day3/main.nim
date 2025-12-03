import batteries, print
import std / [strscans, algorithm, math, sugar]

proc parseInput(input: string): seq[seq[int]] =
  for line in input.strip.splitlines:
    result.add @[]
    for c in line:
      result[^1].add parseInt($c)

proc internalTurnOnBatteries(bank: seq[tuple[value, index: int]], bankLen: int, atIndex: int, currentN, maxN: int): int =
  var currentValue = -1
  var currentIndex = -1
  var deleteIndex = -1
  for i, (value, index) in bank:
    if index > atIndex and index <= bankLen - maxN + currentN:
      currentValue = value
      currentIndex = index
      deleteIndex = i
      break
  var bankCopy = bank
  bankCopy.delete(deleteIndex)
  if currentN == maxN - 1:
    return currentValue
  return currentValue * 10 ^ (maxN - currentN - 1) + internalTurnOnBatteries(bankCopy, bankLen, currentIndex, currentN + 1, maxN)

proc turnOnNBatteries(bank: seq[int], n: int): int =
  var indexedBank = collect(newSeq):
    for index, value in bank:
      (value, index)
  indexedBank.sort((x, y: (int, int)) => cmp((x[0], -x[1]), (y[0], -y[1])), Descending)
  # first find largest that is at least n from the end
  # then find the largest that is at least n-1 from the end. Then n-2 etc...
  return internalTurnOnBatteries(indexedBank, indexedBank.len, -1, 0, n)

proc part1(input: string): int =
  let banks = parseInput(input)
  for bank in banks:
    let bankRes = turnOnNBatteries(bank, 2)
    print(bankRes)
    result += bankRes  

proc part2(input: string): int =
  let banks = parseInput(input)
  for bank in banks:
    let bankRes = turnOnNBatteries(bank, 12)
    print(bankRes)
    result += bankRes

let testInput = """
987654321111111
811111111111119
234234234234278
818181911112111
"""

when isMainModule:
  let realInput = readFile("input.txt")
  let input = realInput
  let answer1 = part1(input)
  echo "Part 1: ", answer1
  let answer2 = part2(input)
  echo "Part 2: ", answer2