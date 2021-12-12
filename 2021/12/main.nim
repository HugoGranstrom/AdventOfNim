import std/[strutils, sequtils, math, strscans, tables, algorithm, sets, strformat]

proc parseInput(input: seq[string]): Table[string, seq[string]] =
  for line in input:
    let (success, startCave, endCave) = scanTuple(line, "$w-$w")
    doAssert success
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

proc recursiveSearch(currentCave: string, caves: Table[string, seq[string]], visited: HashSet[string]): seq[seq[string]] =
  # Returns empty list if no return is found
  if currentCave == "end":
    return @[@["end"]]
  var visited = visited
  if currentCave.isLower:
    visited = visited + @[currentCave].toHashSet
  for neighbour in caves[currentCave]:
    if neighbour notin visited: # don't visit twice
      var path = recursiveSearch(neighbour, caves, visited)
      if path.len > 0:
        # add currentCave in front of all sub-seqs
        for i in 0 .. path.high:
          result.add concat(@[currentCave], path[i])
  if result.len == 0:
    # This is a dead end!
    discard


proc part1(caves: Table[string, seq[string]]): int =
  let paths = recursiveSearch("start", caves, @["start"].toHashSet())
  #echo paths
  result = len(paths)

let testInput1 = """start-A
start-b
A-c
A-b
b-d
A-end
b-end""".splitLines

let testParsed1 = parseInput(testInput1)
let parsed = parseInput(readFile("input.txt").splitLines)

echo "Part 1 (test1): ", part1(testParsed1)
echo "Part 1: ", part1(parsed)