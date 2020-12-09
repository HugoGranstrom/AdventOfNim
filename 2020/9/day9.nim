import deques, strutils, math, numericalnim

{.experimental: "views".}

proc findNonSum(numbers: openArray[int], preamble: int): int =
  var list = initDeque[int](preamble)
  for i in 0 .. preamble - 1:
    list.addLast numbers[i]
  
  for i in preamble .. numbers.high:
    block inner:
      for j in 0 .. list.len - 1:
        for k in 0 .. list.len - 1:
          if j != k and list[j] + list[k] == numbers[i]:
            break inner
      # never breaked
      return numbers[i]
    # break inner
    discard list.popFirst
    list.addLast numbers[i]

proc testPart1(): int =
  let data = """35
20
15
25
47
40
62
55
65
95
102
117
150
182
127
219
299
277
309
576"""
  var numbers: seq[int]
  for line in data.splitLines:
    if line != "":
      numbers.add parseInt(line)
  result = findNonSum(numbers, 5)

proc part1(numbers: seq[int]): int =
  result = findNonSum(numbers, 25)

proc findRange(numbers: seq[int], target: int): (int, int) =
  let lenNumbers = numbers.len
  for n in 2 .. lenNumbers:
    for start in 0 .. lenNumbers - 1 - n:
      let slice = numbers.toOpenArray(start, start + n - 1)
      if sum(slice) == target:
        return (min(slice), max(slice))

proc testPart2(): (int, int) =
  let data = """35
20
15
25
47
40
62
55
65
95
102
117
150
182
127
219
299
277
309
576"""
  var numbers: seq[int]
  for line in data.splitLines:
    if line != "":
      numbers.add parseInt(line)
  result = findRange(numbers, testPart1())
  
proc part2(numbers: seq[int], target: int): (int, int) =
  result = findRange(numbers, target)

when isMainModule:
  let data = readFile("day9.txt")
  var numbers: seq[int]
  for line in data.splitlines:
    numbers.add parseInt(line)
  
  assert testPart1() == 127
  echo "Test Part 1 passed!"
  let p1 = part1(numbers)
  echo "Part 1: ", p1
  assert testPart2() == (15, 47)
  let p2 = part2(numbers, p1)
  echo "Part 2: ", p2[0] + p2[1]