import batteries
import std / [strscans, algorithm, math]



proc parseInput(input: string): tuple[freshRanges: seq[Slice[int]], ingredients: seq[int]] =
  let splits = input.strip.split("\n\n")
  let freshnessBlock = splits[0].strip
  let ingredients = splits[1].strip
  for line in freshnessBlock.splitLines:
    let (success, start, stop) = scanTuple(line, "$i-$i")
    assert success
    result.freshRanges.add start .. stop
  for line in ingredients.splitlines:
    result.ingredients.add parseInt(line)

proc countInclusions(ranges: seq[Slice[int]], element: int): int =
  for slice in ranges:
    if element in slice: result += 1

proc part1(input: string): int =
  let (freshRanges, ingredients) = parseInput(input)
  ingredients.mapIt(countInclusions(freshRanges, it)).countIt(it > 0)

proc simplifyOverlappingRanges(ranges: seq[Slice[int]]): tuple[mergedSlices: seq[Slice[int]], nMerges: int] =
  for i, slice in ranges:
    var merged = false
    for mergeSlice in result.mergedSlices.mitems:
      if slice.a in mergeSlice or slice.b in mergeSlice or mergeSlice.a in slice or mergeSlice.b in slice:
        mergeSlice.a = min(slice.a, mergeSlice.a)
        mergeSlice.b = max(slice.b, mergeSlice.b)
        merged = true
        result.nMerges += 1
    if not merged:
      result.mergedSlices.add slice

proc part2(input: string): int =
  let (freshRanges, ingredients) = parseInput(input)
  var mergedRanges = freshRanges
  var nMerges: int
  while true:
    (mergedRanges, nMerges) = simplifyOverlappingRanges(mergedRanges)
    if nMerges == 0: break
  for slice in mergedRanges:
    let width = slice.b + 1 - slice.a
    result += width


let testInput = """
3-5
10-14
16-20
12-18

1
5
8
11
17
32
"""

when isMainModule:
  let realInput = readFile("input.txt")
  let input = realInput
  let answer1 = part1(input)
  echo "Part 1: ", answer1
  let answer2 = part2(input)
  echo "Part 2: ", answer2