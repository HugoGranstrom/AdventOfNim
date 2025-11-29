import std / [sequtils, tables, sugar, strutils, math]

type
  GridCoordinate* = tuple[x: int, y: int]

  Grid*[T] = ref object
    data*: seq[seq[T]]
    origo*: GridCoordinate = (0, 0)

  SparseGrid*[T] = ref object
    data*: Table[GridCoordinate, T]
    origo*: GridCoordinate = (0, 0)

  NeighboursMode* = enum
    Cross
    Diag
    All

# GridCoordinate
proc mag*(g: GridCoordinate): float =
  sqrt(float(g.x * g.x + g.y * g.y))

proc manhattan*(g: GridCoordinate): int =
  abs(g.x) + abs(g.y)

template defineGridCoordinateOp(op: untyped) =
  proc `op`*(g1, g2: GridCoordinate): GridCoordinate =
    (x: op(g1.x, g2.x), y: op(g1.y, g2.y))

  proc `op`*(g1: GridCoordinate, val: int): GridCoordinate =
    (x: op(g1.x, val), y: op(g1.y, val))

  proc `op`*(val: int, g1: GridCoordinate): GridCoordinate =
    op(g1, val)

defineGridCoordinateOp(`+`)
defineGridCoordinateOp(`-`)
defineGridCoordinateOp(`*`)

### Grid

proc `$`*[T](grid: Grid[T]): string =
  $(grid[].data)

proc initGrid*[T](width, height: int, origo: GridCoordinate = (0, 0)): Grid[T] =
  Grid[T](data: newSeqWith(height, newSeq[T](width)), origo: origo)

func normalizeCoord*(grid: Grid or SparseGrid, coord: GridCoordinate): GridCoordinate =
  coord + grid.origo

func denormalizeCoord*(grid: Grid or SparseGrid, coord: GridCoordinate): GridCoordinate =
  coord - grid.origo

func containsCoordinate*(grid: Grid, coord: GridCoordinate): bool =
  let coord = grid.normalizeCoord(coord)
  coord.x >= 0 and coord.y >= 0 and coord.x < grid.data[0].len and coord.y < grid.data.len

proc `[]`*[T](grid: Grid[T], coord: GridCoordinate): T =
  let coord = grid.normalizeCoord(coord)
  grid.data[coord.y][coord.x]

proc `[]=`*[T](grid: var Grid[T], coord: GridCoordinate, val: T) =
  let coord = grid.normalizeCoord(coord)
  grid.data[coord.y][coord.x] = val

proc defaultGridParseFunc*[T](c: char): T =
  T(c)

proc parseCharGrid*[T](s: string, parseFunc: proc(c: char): T {.nimcall.} = defaultGridParseFunc[T]): Grid[T] =
  let lines = s.splitLines
  let height = lines.len
  let width = lines[0].len
  result = initGrid[T](width, height)
  for x in 0 ..< width:
    for y in 0 ..< height:
      result[(x, y)] = parseFunc(lines[y][x])

iterator neighbours*[T](grid: Grid[T], coord: GridCoordinate, mode: NeighboursMode): tuple[coord: GridCoordinate, value: T] =
  if mode in [Diag, All]:
    for xOffset in [-1, 1]:
      for yOffset in [-1, 1]:
        let c = (x: coord.x + xOffset, y: coord.y + yOffset)
        if grid.containsCoordinate(c):
          yield (c, grid[c])
  
  if mode in [Cross, All]:
    for (xOffset, yOffset) in [(0, 1), (0, -1), (1, 0), (-1, 0)]:
      let c = (x: coord.x + xOffset, y: coord.y + yOffset)
      if grid.containsCoordinate(c):
        yield (c, grid[c])

iterator items*[T](grid: Grid[T]): GridCoordinate =
  for y in 0 .. grid.data.high:
    for x in 0 .. grid.data[0].high:
      yield grid.denormalizeCoord((x, y))

### SparseGrid

proc `$`*[T](grid: SparseGrid[T]): string =
  $(grid[].data)

proc initSparseGrid*[T](origo: GridCoordinate = (0, 0)): SparseGrid[T] =
  SparseGrid[T](origo: origo)

func containsCoordinate*(grid: SparseGrid, coord: GridCoordinate): bool =
  let coord = grid.normalizeCoord(coord)
  coord in grid.data

proc `[]`*[T](grid: SparseGrid[T], coord: GridCoordinate): T =
  let coord = grid.normalizeCoord(coord)
  grid.data[coord]

proc `[]=`*[T](grid: var SparseGrid[T], coord: GridCoordinate, val: T) =
  let coord = grid.normalizeCoord(coord)
  grid.data[coord] = val

proc parseCharSparseGrid*[T](s: string, parseFunc: proc(c: char): T {.nimcall.} = defaultGridParseFunc[T]): SparseGrid[T] =
  let lines = s.splitLines
  let height = lines.len
  let width = lines[0].len
  result = initSparseGrid[T]()
  for x in 0 ..< width:
    for y in 0 ..< height:
      result[(x, y)] = parseFunc(lines[y][x])

iterator neighbours*[T](grid: var SparseGrid[T], coord: GridCoordinate, mode: NeighboursMode): tuple[coord: GridCoordinate, value: var T] =
  if mode in [Diag, All]:
    for xOffset in [-1, 1]:
      for yOffset in [-1, 1]:
        let c = (x: coord.x + xOffset, y: coord.y + yOffset)
        if grid.containsCoordinate(c):
          yield (c, grid[c])
  
  if mode in [Cross, All]:
    for (xOffset, yOffset) in [(0, 1), (0, -1), (1, 0), (-1, 0)]:
      let c = (x: coord.x + xOffset, y: coord.y + yOffset)
      if grid.containsCoordinate(c):
        yield (c, grid[c])

if isMainModule:
  if true:
    var grid = initGrid[char](10, 11)

    grid[(9, 10)] = 'x'

    for (c, v) in grid.neighbours((5, 6), All):
      echo (c, v)

    echo grid

    let gridStr = """
  # # # #
  #######
        #
  """.strip

    grid = parseCharGrid[char](gridStr)
    echo grid

  if false:
    var sparseGrid = initSparseGrid[bool]((1,1))

    sparseGrid[(5, 5)] = true

    for (c, v) in sparseGrid.neighbours((6, 6), All):
      echo (c, v)

    echo sparseGrid

    let gridStr = """
  # # # #
  #######
        #
  """.strip

    sparseGrid = parseCharSparseGrid[bool](gridStr, (c: char) => not c.isSpaceAscii)

    echo sparseGrid






    


