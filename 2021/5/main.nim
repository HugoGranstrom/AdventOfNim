import std/[strutils, strscans, sequtils, tables]

proc parseLines(s: seq[string]): seq[(int, int, int, int)] =
  for line in s:
    let (success, x1, y1, x2, y2) = scanTuple(line, "$i,$i -> $i,$i")
    doAssert success, "Failed to parse: " & line
    result.add (x1, y1, x2, y2)

proc part1(lines: seq[(int, int, int, int)]): int =
  var counts = initCountTable[(int, int)]()
  for (x1, y1, x2, y2) in lines:
    if x1 == x2 or y1 == y2:
      for i in min(x1, x2) .. max(x1, x2):
        for j in min(y1, y2) .. max(y1, y2):
          counts.inc (i, j)
  result = len(counts.values.toSeq.filterIt(it >= 2))

proc part2(lines: seq[(int, int, int, int)]): int =
  var counts = initCountTable[(int, int)]()
  for (x1, y1, x2, y2) in lines:
    if x1 == x2 or y1 == y2:
      for i in min(x1, x2) .. max(x1, x2):
        for j in min(y1, y2) .. max(y1, y2):
          counts.inc (i, j)
    elif x1 <= x2 and y1 <= y2:
      for (i, j) in zip(countup(x1, x2).toSeq, countup(y1, y2).toSeq):
        counts.inc (i, j)
    elif x1 > x2 and y1 <= y2:
      for (i, j) in zip(countdown(x1, x2).toSeq, countup(y1, y2).toSeq):
        counts.inc (i, j)
    elif x1 > x2 and y1 > y2:
      for (i, j) in zip(countdown(x1, x2).toSeq, countdown(y1, y2).toSeq):
        counts.inc (i, j)
    elif x1 <= x2 and y1 > y2:
      for (i, j) in zip(countup(x1, x2).toSeq, countdown(y1, y2).toSeq):
        counts.inc (i, j)
        
  result = len(counts.values.toSeq.filterIt(it >= 2))



let input = "input.txt".lines.toSeq.parseLines
let testInput = """0,9 -> 5,9
8,0 -> 0,8
9,4 -> 3,4
2,2 -> 2,1
7,0 -> 7,4
6,4 -> 2,0
0,9 -> 2,9
3,4 -> 1,4
0,0 -> 8,8
5,5 -> 8,2""".splitLines.parseLines

echo "Part 1 (test): ", part1(testInput)
echo "Part 1: ", part1(input)
echo "Part 2 (test): ", part2(testInput)
echo "Part 2: ", part2(input)





