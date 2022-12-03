include prelude
import sugar

proc readInput(input: string): seq[tuple[left, right: string]] =
  for line in input.splitLines:
    let splitIndex= line.len div 2
    result.add (left: line[0 ..< splitIndex], right: line[splitIndex .. ^1])

var charValue: Table[char, int]
for x in 'a' .. 'z':
  charValue[x] = ord(x) - ord('a') + 1
for x in 'A' .. 'Z':
  charValue[x] = ord(x) - ord('A') + 27

proc part1(input: string) =
  let splitInput = readInput(input)
  var duplicated = collect:
    for (left, right) in splitInput:
      left.toHashSet * right.toHashSet

  var result = 0
  for d in duplicated.mitems:
    assert d.len == 1
    result += charValue[d.pop()]

  echo "Part 1: ", result

proc part2(input: string) = 
  let splitInput = readInput(input)
  var duplicated = collect:
    for i in countup(0, splitInput.high, 3):
      var temp: HashSet[char] = splitInput[i].left.toHashSet + splitInput[i].right.toHashSet
      for j in 1 .. 2:
        temp = temp * (splitInput[i+j].left.toHashSet + splitInput[i+j].right.toHashSet)
      temp

  echo duplicated

  var result = 0
  for d in duplicated.mitems:
    assert d.len == 1, $d
    result += charValue[d.pop()]

  echo "Part 2: ", result


when isMainModule:
  let input = readFile("input.txt")
  part1(input)
  part2(input)