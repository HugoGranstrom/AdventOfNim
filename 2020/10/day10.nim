import strutils, algorithm, tables

# Solutions:

proc part1() =
  let data = readFile("day10.txt").strip
  var jolts: seq[int] = @[0]
  for line in data.splitLines:
    jolts.add parseInt(line)
  jolts.sort
  jolts.add jolts[^1] + 3
  var diffs: array[3, int]
  for i in 0 .. jolts.high - 1:
    diffs[jolts[i+1] - jolts[i] - 1] += 1
  echo "Part1: ", diffs[0] * diffs[2]


proc calcCombinations(jolts: seq[int]): int =
  let endJolts = jolts[^1]
  var cache: Table[int, seq[int]]
  for i in 0 .. jolts.high - 1:
    for j in 1 .. min(3, jolts.high - i):
      if jolts[i+j] - jolts[i] <= 3:
        if jolts[i] notin cache: cache[jolts[i]] = @[jolts[i+j]]
        else: cache[jolts[i]].add jolts[i+j]
  var nWays: Table[int, int]
  nWays[endJolts] = 1
  for i in countdown(jolts.high - 1, 0):
    var res: int
    for next in cache[jolts[i]]:
      res += nWays[next]
    nWays[jolts[i]] = res
  result = nWays[0]

proc part2() =
  let data = readFile("day10.txt").strip
  var jolts: seq[int] = @[0]
  for line in data.splitLines:
    jolts.add parseInt(line)
  jolts.sort
  echo "Part 2: ", calcCombinations(jolts)


# Tests


block tests:
  proc testPart1() =
    let data = """28
33
18
42
31
14
46
20
48
47
24
23
49
45
19
38
39
11
1
32
25
35
8
17
7
9
4
2
34
10
3""".strip
    var jolts: seq[int] = @[0]
    for line in data.splitLines:
      jolts.add parseInt(line)
    jolts.sort
    jolts.add jolts[^1] + 3
    var diffs: array[3, int]
    for i in 0 .. jolts.high - 1:
      diffs[jolts[i+1] - jolts[i] - 1] += 1
    assert diffs[0] * diffs[2] == 220

  proc testPart2() =
    let data = """28
33
18
42
31
14
46
20
48
47
24
23
49
45
19
38
39
11
1
32
25
35
8
17
7
9
4
2
34
10
3""".strip
    var jolts: seq[int] = @[0]
    for line in data.splitLines:
      jolts.add parseInt(line)
    jolts.sort
    assert calcCombinations(jolts) == 19208
  testPart2()
  testPart1()

when isMainModule:
  part1()
  part2()
