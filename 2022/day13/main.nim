import batteries, std / [json, enumerate]

proc parseInput(input: string): seq[seq[JsonNode]] =
  for pair in input.split("\n\n"):
    result.add @[]
    for i, line in enumerate(pair.splitLines):
      let js = parseJson(line)
      result[^1].add js

proc compare(left: JsonNode, right: JsonNode): int =
  if left.kind == right.kind and left.kind == JInt:
    if left.num < right.num:
      return 1
    elif left.num > right.num:
      return -1
    else:
      return 0
  elif left.kind == right.kind and left.kind == JArray:
    let leftLen = left.len
    let rightLen = right.len
    for i in 0 ..< min(leftLen, rightLen):
      let c = compare(left[i], right[i])
      if c in [-1, 1]:
        return c
    if leftLen < rightLen:
      return 1
    elif leftLen > rightLen:
      return -1
    else:
      return 0
  elif left.kind == JInt and right.kind == JArray:
    return compare(%[left], right)
  elif left.kind == JArray and right.kind == JInt:
    return compare(left, %[right])
  else:
    assert false, &"Something went wrong: (left: {left}, right: {right})"

proc part1(input: string) =
  let pairs = parseInput(input)
  var answer = 0
  for i, pair in pairs:
    let left = pair[0]
    let right = pair[1]
    if compare(left, right) == 1:
      answer += i + 1

  echo "Part 1: ", answer
      
proc part2(input: string) =
  let pairs = parseInput(input)
  var flattened: seq[JsonNode]
  for p in pairs:
    flattened.add p[0]
    flattened.add p[1]
  flattened.add %[%[2]]
  flattened.add %[%[6]]
  flattened.sort(compare, Descending)
  var answer = 1
  for i, x in flattened:
    if x.len == 1 and x[0].kind == JArray and x[0].len == 1 and x[0][0].kind == JInt:
      if x[0][0].num in [2.BiggestInt, 6]:
        answer *= (i + 1)

  echo "Part 2: ", answer
      


when isMainModule:
  let input = readFile("input.txt")
  part1(input)
  part2(input)