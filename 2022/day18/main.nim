import batteries, std / [macros]

type
  Coord = tuple[x, y, z: int]
  Cube = ref object
    pos: Coord
    neighs: HashSet[Cube]
  Visited = ref HashSet[Coord]

proc `$`(cube: Cube): string =
  &"Cube(pos: {cube.pos}, neighs: {cube.neighs.len})"

proc hash(cube: Cube): Hash =
  hash(cube.pos)

proc `==`(c1, c2: Cube): bool =
  c1.pos == c2.pos

proc dist(c1, c2: Coord): int =
  abs(c1.x - c2.x) + abs(c1.y - c2.y) + abs(c1.z - c2.z)

proc mag(c: Coord): int =
  dist(c, (x: 0, y: 0, z: 0))

proc parseInput(input: string): seq[Cube] =
  for line in input.splitLines:
    let (success, x, y, z) = scanTuple(line, "$i,$i,$i")
    assert success
    let pos = (x: x, y: y, z: z)
    let newCube = Cube(pos: pos)
    for cube in result:
      if dist(cube.pos, pos) == 1:
        cube.neighs.incl newCube
        newCube.neighs.incl cube
    result.add newCube

iterator neighbours(c: Coord): Coord =
  for dim in 0 .. 2:
    for i in [-1, 1]:
      if dim == 0:
        yield (x: c.x + i, y: c.y, z: c.z)
      elif dim == 1:
        yield (x: c.x, y: c.y + i, z: c.z)
      else:
        yield (x: c.x, y: c.y, z: c.z + i)

macro toItr*(x: ForLoopStmt): untyped =
  ## Convert factory proc call for inline-iterator-like usage.
  ## E.g.: ``for a,b in toItr(myFactory(parm)): echo a,b``.
  let
    forVars = x[0..^3]
    call    = x[^2][1] # Get foo out of toItr(foo)
    body    = x[^1]
    itrSym  = ident"itr"
    #itrSym  = genSym(ident="itr")
  var forTree = nnkForStmt.newTree()  # for
  for v in forVars: forTree.add v     # for v1,...
  forTree.add(nnkCall.newTree(itrSym), body) # for v1,... in itr(): body
  result = quote do:
    block:
      let `itrSym` {.inject.} = `call`
      `forTree`

proc search(coord: Coord, visited: Visited): iterator(): Coord =
  result = iterator(): Coord =
    visited[].incl coord
    for neigh in coord.neighbours:
      if neigh notin visited[]:
        visited[].incl neigh
        yield neigh
        for x in toItr(search(neigh, visited)):
          visited[].incl x
          yield x

template findAirGapsImpl(cubes: seq[Cube], airGaps: HashSet[Cube], counter: int) =
  for i, c in cubes:
    #if i mod 100 == 0: echo i / cubes.high
    for n in c.pos.neighbours:
      var visited = new(Visited)
      visited[] = cubes.mapIt(it.pos).toHashSet
      if n in visited[]: continue
      block innerLoop:
        for x in toItr(search(n, visited)):
          if x.x < 0 or x.y < 0 or x.z < 0 or x.mag > maxDist:
            break innerLoop
        let newCube = Cube(pos: n)
        if newCube notin airGaps:
          airGaps.incl newCube
          counter += 1

proc findAirGaps(cubes: seq[Cube]): seq[Cube] =
  let maxDist = max(cubes.mapIt(it.pos.mag))
  echo maxDist
  var airGaps: HashSet[Cube]
  var counter = 0
  findAirGapsImpl(cubes, airGaps, counter)
  
  echo airGaps, counter

  var added = 1
  while added > 0:
    added = 0
    let list = cubes & toSeq(airGaps)
    findAirGapsImpl(list, airGaps, added)
  
  result = toSeq(airGaps)
      


proc part1(input: string) =
  let cubes = parseInput(input)
  var answer = 0
  for cube in cubes:
    answer += 6 - cube.neighs.len

  echo "Part 1: ", answer

proc part2(input: string) =
  var cubes = parseInput(input)
  let airGaps = cubes.findAirGaps()
  cubes = cubes & airGaps

  for cube in cubes:
    for c2 in cubes:
      if dist(cube.pos, c2.pos) == 1:
        cube.neighs.incl c2
        c2.neighs.incl cube

  var answer = 0
  for cube in cubes:
    answer += 6 - cube.neighs.len
  
  echo "Part 2: ", answer


when isMainModule:
  let input = readFile"input.txt"
  part1(input)
  part2(input)