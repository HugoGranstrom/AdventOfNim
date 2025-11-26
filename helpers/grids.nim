import std / [sequtils, tables, sugar, strutils]
import arraymancer

type
  GridCoordinate* = tuple[x: int, y: int]

  Grid*[T] = ref object
    data*: Tensor[T]
    origo*: GridCoordinate = (0, 0)

  SparseGrid*[T] = ref object
    data*: Table[GridCoordinate, T]

  NeighboursMode* = enum
    Cross
    Diag
    All

proc `$`*[T](grid: Grid[T]): string =
  $(grid[].data.transpose)

proc initGrid*[T](width, height: int, origo: GridCoordinate = (0, 0)): Grid[T] =
  Grid[T](data: newTensor[T](width, height), origo: origo)

func normalizeCoord*(grid: Grid, coord: GridCoordinate): GridCoordinate =
  (x: coord.x + grid.origo.x, y: coord.y + grid.origo.y)

func containsCoordinate*(grid: Grid, coord: GridCoordinate): bool =
  let coord = grid.normalizeCoord(coord)
  coord.x >= 0 and coord.y >= 0 and coord.x < grid.data.shape[0] and coord.y < grid.data.shape[1]

proc `[]`*[T](grid: Grid[T], coord: GridCoordinate): T =
  let coord = grid.normalizeCoord(coord)
  grid.data[coord.x, coord.y]

proc `[]=`*[T](grid: var Grid[T], coord: GridCoordinate, val: T) =
  let coord = grid.normalizeCoord(coord)
  grid.data[coord.x, coord.y] = val

proc parseCharGrid*[T](s: string, parseFunc: (c: char) -> T = (c: char) => c): Grid[T] =
  let lines = s.splitLines
  let height = lines.len
  let width = lines[0].len
  result = initGrid[T](width, height)
  for x in 0 ..< width:
    for y in 0 ..< height:
      result[(x, y)] = parseFunc(lines[y][x])

iterator neighbours*[T](grid: var Grid[T], coord: GridCoordinate, mode: NeighboursMode): tuple[coord: GridCoordinate, value: var T] =
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
  var grid = initGrid[bool](10, 11)

  grid[(9, 10)] = true

  for (c, v) in grid.neighbours((5, 6), All):
    echo (c, v)

  echo grid

  let gridStr = """
# # # #
#######
      #
""".strip

  grid = parseCharGrid[bool](gridStr, (c: char) => not c.isSpaceAscii)
  echo grid






    


