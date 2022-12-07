include prelude, strscans, std / [enumerate, algorithm, tables]

proc readInput(input: string): (string, seq[(string, char)]) =
  for i, line in enumerate input.splitLines:
    if i == 0:
      result[0] = line
    elif i > 1:
      let (success, lhs, rhs) = scanTuple(line, "$w -> $c")
      assert success
      result[1].add (lhs, rhs)

proc polymerIteration(input: string, rules: seq[(string, char)]): string =
  var insertions: seq[tuple[index: int, c: char]]
  for i in 0 .. input.high - 1:
    let s = input[i .. i + 1]
    for rule in rules:
      if rule[0] == s:
        insertions.add (index: i + 1, c: rule[1])
        break

  insertions.sort()
  result = newString(input.len + insertions.len)
  var offset = 0
  for i in 0 .. result.high:
    if offset < insertions.len and i == insertions[offset].index + offset:
      result[i] = insertions[offset].c
      result[i+1] = input[insertions[offset].index]
      offset += 1
    else:
      result[i] = input[i - offset]



proc part1(input: string) =
  let (startStr, rules) = readInput(input)
  var result = startStr
  for i in 0 ..< 10:
    echo "Iterations ", i, ", len = ", result.len
    result = polymerIteration(result, rules)
  
  #echo result
  let t = result.toCountTable()
  let counts = t.values.toSeq
  echo "Part 1: ", counts.max - counts.min


proc readInput2(input: string): (string, seq[((char, char), char)]) =
  for i, line in enumerate input.splitLines:
    if i == 0:
      result[0] = line
    elif i > 1:
      let (success, lhs1, lhs2, rhs) = scanTuple(line, "$c$c -> $c")
      assert success
      result[1].add ((lhs1, lhs2), rhs)

proc polymerIteration2(pairCount: var Table[(char, char), int], charCount: var CountTable[char], rules: seq[((char, char), char)]) =
  var modifications: seq[tuple[key: (char, char), count: int, c: char]]
  for (key, c) in rules:
    let count = pairCount.getOrDefault(key, 0)
    if count > 0:
      modifications.add (key: key, count: count, c: c)

  for (key, count, c) in modifications:
    pairCount[key] -= count
    pairCount.mgetOrPut((key[0], c), 0) += count
    pairCount.mgetOrPut((c, key[1]), 0) += count
    charCount.inc(c, count)


proc part2(input: string) =
  let (startStr, rules) = readInput2(input)
  var pairCount: Table[(char, char), int]
  var charCount: CountTable[char] = startStr.toCountTable
  for i in 0 .. startStr.high - 1:
    pairCount.mgetOrPut((startStr[i], startStr[i+1]), 0) += 1

  for i in 0 ..< 40:
    polymerIteration2(pairCount, charCount, rules)

  let counts = charCount.values.toSeq
  echo "Part 1: ", counts.max - counts.min
  

  
  

let testInput = """
NNCB

CH -> B
HH -> N
CB -> H
NH -> C
HB -> C
HC -> B
HN -> C
NN -> C
BH -> H
NC -> B
NB -> B
BN -> B
BB -> N
BC -> B
CC -> N
CN -> C"""

when isMainModule:
  let input = readFile("input.txt")
  part1(testInput)
  part2(input)