import batteries
import bumpy, vmath
import std / [strscans, algorithm, math]
import grids

proc parseInput(input: string): seq[GridCoordinate] =
  for line in input.strip.splitLines:
    let (success, x, y) = line.scanTuple("$i,$i")
    assert success
    result.add (x, y)

proc spannedArea(p1, p2: GridCoordinate): int =
  let width = abs(p1.x - p2.x) + 1
  let height = abs(p1.y - p2.y) + 1
  width * height

proc sortedAreas(points: seq[GridCoordinate]): seq[tuple[area: int, p1, p2: GridCoordinate]] =
  for i, p1 in points:
    for p2 in points[i+1..^1]:
      result.add (spannedArea(p1, p2), p1, p2)  
  result.sort
  result.reverse

proc part1(input: string): int =
  parseInput(input).sortedAreas[0].area

proc contains(rect: (GridCoordinate, GridCoordinate), point: GridCoordinate): bool =
  if point == rect[0] or point == rect[1]: return false
  let xRange = min(rect[0].x, rect[1].x) .. max(rect[0].x, rect[1].x)
  let yRange = min(rect[0].y, rect[1].y) .. max(rect[0].y, rect[1].y)
  point.x in xRange and point.y in yRange

proc containsAnyPoint(rectangle: (GridCoordinate, GridCoordinate), points: seq[GridCoordinate]): bool =
  for p in points:
    if rectangle.contains p:
      return true
  return false

proc toVec(c: GridCoordinate): Vec2 =
  vec2(c.x.float, c.y.float)

proc toRect(p1, p2: GridCoordinate): Rect =
  let width = abs(p1.x - p2.x).float
  let height = abs(p1.y - p2.y).float
  rect(x=min(p1.x, p2.x).float, y=min(p1.y, p2.y).float, w=width, h=height)

proc contract(rect: Rect, amount=0.01): Rect =
  # move the corners closer to each other by this amount
  # This is needed to avoid intersecting with the corners of the polygon that spans this rectangle
  rect(x=rect.x+amount, rect.y+amount, w=rect.w-2*amount, h=rect.h-2*amount)

iterator segments(rect: Rect): Segment =
  var current = rect.xy
  for step in [vec2(0, rect.h), vec2(rect.w, 0), vec2(0, -rect.h), vec2(-rect.w, 0)]:
    let next = current + step
    yield segment(current, next)
    current = next

proc intersects(polygon: Polygon, rect: Rect): bool =
  var at: Vec2
  for polySeg in polygon.segments():
    for rectSeg in rect.segments():
      if intersects(polySeg, rectSeg, at):
        return true
  return false

proc part2(input: string): int =
  let redPoints = parseInput(input)
  let areas = sortedAreas(redPoints)
  let polygon = redPoints.mapIt(it.toVec)
  for (area, p1, p2) in areas:
    let rect = toRect(p1, p2).contract
    if not intersects(polygon, rect):
      return area

let testInput = """
7,1
11,1
11,7
9,7
9,5
2,5
2,3
7,3
"""

when isMainModule:
  let realInput = readFile("input.txt")
  let input = realInput
  let answer1 = part1(input)
  echo "Part 1: ", answer1
  let answer2 = part2(input)
  echo "Part 2: ", answer2