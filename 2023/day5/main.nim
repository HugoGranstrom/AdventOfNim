include std / prelude
import std / [strscans, algorithm, math]

type
  Map = object
    sourceName, destName: string
    rangePairs: seq[tuple[source, dest: Slice[int]]]
    #mapping: Table[int, int]
    #reverseMapping: Table[int, int]

proc `[]`(map: Map, source: int): int =
  for (sRange, dRange) in map.rangePairs:
    if source in sRange:
      let offset = source - sRange.a
      return dRange.a + offset
  return source

proc `<`(x, y: Slice[int]): bool =
  x.a < y.a

proc `<`(x, y: tuple[source, dest: Slice[int]]): bool =
  x.dest < y.dest

proc reverseSearch(map: Map, dest: int): int =
  for (sRange, dRange) in map.rangePairs:
    if dest in dRange:
      let offset = dest - dRange.a
      return sRange.a + offset
  return dest

proc parseInput[T: seq[int] | seq[Slice[int]]](input: string): tuple[seeds: T, maps: seq[Map]] =
  for map in input.strip.split("\n\n"):
    if map.startsWith("seeds:"):
      when T is seq[int]:
        result.seeds = map.split(":")[1].strip.splitWhitespace.map(parseInt)
      else:
        let rangeBounds = map.split(":")[1].strip.splitWhitespace.map(parseInt)
        for i in countup(0, rangeBounds.high, 2):
          result.seeds.add rangeBounds[i] ..< rangeBounds[i] + rangeBounds[i+1]
        result.seeds.sort()
    else:
      var newMap: Map
      let splitted = map.split("map:\n")
      let (succ, sourceName, destName) = scanTuple(splitted[0].strip(), "$w-to-$w")
      newMap.sourceName = sourceName
      newMap.destName = destName
      assert succ

      for line in splitted[1].strip.splitLines():
        let (succ, destStart, sourceStart, rangeLen) = scanTuple(line, "$i $i $i")
        assert succ
        newMap.rangePairs.add (source: sourceStart ..< sourceStart + rangeLen, dest: destStart ..< destStart + rangeLen)
        #[ let rDest = toSeq(destStart ..< destStart + rangeLen)
        let rSource = toSeq(sourceStart ..< sourceStart + rangeLen)
        for (d, s) in zip(rDest, rSource):
          newMap.mapping[s] = d
          newMap.reverseMapping[d] = s ]#
      
      newMap.rangePairs.sort()

      result.maps.add newMap
      

proc part1(input: string): int =
  let (seeds, maps) = parseInput[seq[int]](input)
  var source = seeds
  for map in maps:
    for s in source.mitems:
      s = map[s]
  
  #echo source
  result = min(source)

proc part2(input: string): int =
  let (seeds, maps) = parseInput[seq[Slice[int]]](input)
  echo seeds
  #[ for locRange in maps[^1].rangePairs.mapIt(it.dest):
    echo locRange
    for i in locRange:
      var dest = i
      for map in maps.reversed:
        dest = map.reverseSearch(dest)
      for seedRange in seeds:
        if dest in seedRange:
          return i
      echo "Tried ", i, " got ", dest ]#

  var i = 0
  while true:
    var dest = i
    for map in maps.reversed:
      dest = map.reverseSearch(dest)
    for seedRange in seeds:
      if dest in seedRange:
        return i
    
    if i mod 100000 == 0:
      echo "Tried ", i, " got ", dest
    i += 1

let testInput = """
seeds: 79 14 55 13

seed-to-soil map:
50 98 2
52 50 48

soil-to-fertilizer map:
0 15 37
37 52 2
39 0 15

fertilizer-to-water map:
49 53 8
0 11 42
42 0 7
57 7 4

water-to-light map:
88 18 7
18 25 70

light-to-temperature map:
45 77 23
81 45 19
68 64 13

temperature-to-humidity map:
0 69 1
1 0 69

humidity-to-location map:
60 56 37
56 93 4
"""

when isMainModule:
  let realInput = readFile("input.txt")
  let input = realInput
  let answer1 = part1(input)
  echo "Part 1: ", answer1
  let answer2 = part2(input)
  echo "Part 2: ", answer2