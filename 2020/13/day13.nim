import strutils, std/enumerate, itertools

proc loadDataPart1(): (int, seq[int]) =
  let lines = readFile("day13.txt").strip.splitLines
  result[0] = lines[0].parseInt
  for i in lines[1].split(','):
    if i != "x":
      result[1].add i.parseInt

proc part1() =
  let (earliest, ids) = loadDataPart1()
  var waitingTime: seq[int]
  var minIndex, minValue: int = 10000
  for i in 0 .. ids.high:
    let wait = ids[i] - (earliest mod ids[i])
    if wait < minValue:
      minValue = wait
      minIndex = i
    waitingTime.add wait
  echo "Part 1: ", minValue * ids[minIndex]

proc loadDataPart2(data: string): seq[tuple[index: int, id: int]] =
  for (i, c) in enumerate(data.split(',')):
    if c != "x":
      result.add (index: i, id: parseInt(c))

# Code for chinese remainder is taken from Rosetta code: https://rosettacode.org/wiki/Chinese_remainder_theorem#Nim
proc mulInv(a0, b0: int): int =
  var (a, b, x0) = (a0, b0, 0)
  result = 1
  if b == 1: return
  while a > 1:
    let q = a div b
    a = a mod b
    swap a, b
    result = result - q * x0
    swap x0, result
  if result < 0: result += b0
 
proc chineseRemainder[T](n, a: T): int =
  var prod = 1
  var sum = 0
  for x in n: prod *= x
 
  for i in 0..<n.len:
    let p = prod div n[i]
    sum += a[i] * mulInv(p, n[i]) * p
 
  sum mod prod


proc part2() =
  let lines = readFile("day13.txt").strip.splitLines[1]
  let data = loadDataPart2(lines)
  var n, a: seq[int]
  for i in data:
    n.add i.id
    a.add i.id - (i.index mod i.id)
  echo "Part 2: ", chineseRemainder(n, a)

when isMainModule:
  part1()
  part2()

