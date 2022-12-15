import batteries, regex

type
  Coord = tuple[x: int, y: int]
  Sensor = object
    pos: Coord
    maxDist: int

proc manhattan(c1, c2: Coord): int =
  abs(c1.x - c2.x) + abs(c1.y - c2.y)

proc parseInput(input: string): tuple[sensors: HashSet[Sensor], beacons: HashSet[Coord]] =
  #var beacons: HashSet[Coord]
  for line in input.splitLines:
    let nums = line.findAll(re"-?\d+").mapIt(line[it.boundaries].parseInt)
    let sensor = (x: nums[0], y: nums[1])
    let beacon = (x: nums[2], y: nums[3])
    let dist = manhattan(sensor, beacon)
    result.sensors.incl Sensor(pos: sensor, maxDist: dist)
    result.beacons.incl beacon
  #result.beacons = beacons.toSeq

proc limits(sensors: HashSet[Sensor], beacons: HashSet[Coord]): tuple[xLim: (int, int), yLim: (int, int)] =
  result.xLim = (100000000, -100000000)
  result.yLim = (100000000, -100000000)
  for s in sensors:
    let c = s.pos
    result.xLim[0] = min(result.xLim[0], c.x - s.maxDist)
    result.xLim[1] = max(result.xLim[1], c.x + s.maxDist)
    result.yLim[0] = min(result.yLim[0], c.y - s.maxDist)
    result.yLim[1] = max(result.yLim[1], c.y + s.maxDist)
  for b in beacons:
    result.xLim[0] = min(result.xLim[0], b.x)
    result.yLim[0] = min(result.yLim[0], b.y)
    result.xLim[1] = max(result.xLim[1], b.x)
    result.yLim[1] = max(result.yLim[1], b.y)

proc part1(input: string) =
  let (sensors, beacons) = parseInput(input)
  let limits = limits(sensors, beacons)
  let y = 2000000
  var answer = 0
  for x in limits.xLim[0] .. limits.xLim[1]:
    let c = (x, y)
    if c in beacons:
      continue
    block innerLoop:
      for s in sensors:
        let dist = manhattan(c, s.pos)
        if dist <= s.maxDist:
          answer += 1
          break innerLoop
  echo "Part 1: ", answer

iterator almosts(sensor: Sensor, maxCoord: int): Coord =
  let r = sensor.maxDist + 1
  for x in sensor.pos[0] - r .. sensor.pos[0] + r:
    if x notin 0 .. maxCoord: continue
    for s in [-1, 1]:
      let y = sensor.pos[1] + s * (r - abs(x - sensor.pos[0]))
      if y notin 0 .. maxCoord: continue
      yield (x, y)

proc part2(input: string) =
  let (sensors, beacons) = parseInput(input)
  let limits = (0, 4000000) # 4000000
  for sensor in sensors:
    for c in sensor.almosts(limits[1]):
      if c in beacons:
        continue
      block innerBlock:
        for s in sensors:
          let dist = manhattan(c, s.pos)
          if dist <= s.maxDist:
            break innerBlock
        let freq = c[0] * 4000000 + c[1]
        echo "Part 2: ", freq
        return

when isMainModule:
  let testInput = readFile"testinput.txt"
  let input = readFile"input.txt"
  part1(input)
  part2(input)