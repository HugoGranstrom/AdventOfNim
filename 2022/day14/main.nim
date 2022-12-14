import batteries, std / [complex]

type
  Coord = tuple[x, y: int]
  Map = HashSet[Coord]

proc plotMap(map: Map, xLim: (int, int), yLim: (int, int)) =
  for y in yLim[0] .. yLim[1]:
    var row = ""
    for x in xLim[0] .. xLim[1]:
      if (x, y) in map:
        row &= '#'
      else:
        row &= '.'
    echo row

proc parseInput(input: string): (Map, int) =
  for line in input.splitLines:
    let coords = line.split(" -> ").mapIt(scanTuple(it, "$i,$i")).mapIt((x: it[1], y: it[2]))
    result[0].incl coords[0]
    for i in 1 .. coords.high:
      let x1 = coords[i-1].x
      let x2 = coords[i].x
      for x in  min(x1, x2) .. max(x1, x2):
        result[0].incl (x, coords[i].y)
      
      let y1 = coords[i-1].y
      let y2 = coords[i].y
      for y in min(y1, y2) .. max(y1, y2):
        result[0].incl (coords[i].x, y)
  result[1] = max(toSeq(result[0]).mapIt(it.y))

proc drop(sand: Coord, dir: int): Coord =
  ## dir = 0: down
  ## dir = 1: diagonal left
  ## dir = 2: diagonal right
  assert dir in 0 .. 2
  if dir == 0:
    result = (sand.x, sand.y + 1)
  elif dir == 1:
    result = (sand.x - 1, sand.y + 1)
  else:
    result = (sand.x + 1, sand.y + 1)


proc dropSandPart1(map: var Map, source: Coord, maxDepth: int): bool =
  var sand = source
  while sand.y <= maxDepth:
    block innerLoop:
      for dir in 0 .. 2:
        let newCoord = sand.drop(dir)
        if newCoord notin map:
          sand = newCoord
          break innerLoop
      # if we don't find a new direction, we have finished
      map.incl sand
      return true
  return false

proc dropSandPart2(map: var Map, source: Coord, maxDepth: int): bool =
  var sand = source
  while true:
    block innerLoop:
      if sand.y < maxDepth + 1:
        for dir in 0 .. 2:
          let newCoord = sand.drop(dir)
          if newCoord notin map:
            sand = newCoord
            break innerLoop
      # if we don't find a new direction, we have finished
      map.incl sand
      if sand == source:
        return false
      else:
        return true

proc part1(input: string) =
  var (map, maxDepth) = parseInput(input)
  #map.plotMap((493, 504), (0, maxDepth + 1))
  var answer = 0
  while map.dropSandPart1((x: 500, y: 0), maxDepth):
    answer += 1
  #map.plotMap((493, 504), (0, maxDepth + 1))
  echo "Part 1: ", answer

proc part2(input: string) =
  var (map, maxDepth) = parseInput(input)
  #map.plotMap((485, 510), (0, maxDepth + 3))
  var answer = 0
  while map.dropSandPart2((x: 500, y: 0), maxDepth):
    answer += 1
  echo ""
  #map.plotMap((485, 510), (0, maxDepth + 3))
  echo "Part 2: ", answer + 1

let testInput = """
498,4 -> 498,6 -> 496,6
503,4 -> 502,4 -> 502,9 -> 494,9""" 

when isMainModule:
  let input = readFile("input.txt")
  part1(input)
  part2(input)