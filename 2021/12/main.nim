import std/[strutils, sequtils, math, strscans, tables, algorithm, sets, strformat]

proc parseInput(input: seq[string]): Table[string, seq[string]] =
  for line in input:
    let (success, startCave, endCave) = scanTuple(line, "$w-$w")
    doAssert success
    if endCave != "start": # don't add "start" as destination of any other
      if startCave notin result:
        result[startCave] = @[endCave]
      else:
        result[startCave].add endCave
    if startCave != "start": # don't add "start" as destination of any other
      if endCave notin result:
        result[endCave] = @[startCave]
      else:
        result[endCave].add startCave

proc isLower(s: string): bool =
  result = true
  for c in s:
    if not c.isLowerAscii: return false

proc recursiveSearch(currentCave: string, caves: Table[string, seq[string]], visited: CountTable[string], maxVisits: int): seq[seq[string]] =
  # Returns empty list if no return is found
  if currentCave == "end":
    return @[@["end"]]
  var visited = visited
  if currentCave.isLower and currentCave != "start":
    visited.inc currentCave
  for neighbour in caves[currentCave]:
    if neighbour notin visited or visited.largest[1] < maxVisits: # don't visit twice
      var path = recursiveSearch(neighbour, caves, visited, maxVisits)
      if path.len > 0:
        # add currentCave in front of all sub-seqs
        for i in 0 .. path.high:
          result.add concat(@[currentCave], path[i])


proc part1(caves: Table[string, seq[string]]): int =
  let paths = recursiveSearch("start", caves, @["start"].toCountTable(), 1)
  result = len(paths)

proc part2(caves: Table[string, seq[string]]): int =
  let paths = recursiveSearch("start", caves, @["start"].toCountTable(), 2)
  result = len(paths)

let testInput1 = """start-A
start-b
A-c
A-b
b-d
A-end
b-end""".splitLines

let testInput2 = """dc-end
HN-start
start-kj
dc-start
dc-HN
LN-dc
HN-end
kj-sa
kj-HN
kj-dc""".splitLines

let testParsed1 = parseInput(testInput1)
let testParsed2 = parseInput(testInput2)
let parsed = parseInput(readFile("input.txt").splitLines)

echo "Part 1 (test1): ", part1(testParsed1)
echo "Part 2 (test2): ", part1(testParsed2)
echo "Part 1: ", part1(parsed)

echo "Part 2: ", part2(parsed)