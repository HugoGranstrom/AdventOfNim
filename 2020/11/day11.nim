import std/strutils, std/enumerate, std/sugar

type
  Nextstatus = enum occupied, empty, unchanged
  Map = seq[seq[char]]

proc loadMap(filename: string): seq[seq[char]] =
  let mapString = readFile(filename).strip
  let nRows = mapString.countLines
  result = newSeq[seq[char]](nRows)
  for i, line in enumerate(mapString.splitLines):
    for j, c in line:
      result[i].add(c)

proc getSeatStatusPart1(map: seq[seq[char]], row, col: int): Nextstatus =
  let rowHigh = map.high
  let colHigh = map[0].high
  var rows: seq[int]
  var cols: seq[int]
  if row == 0: rows.add @[0, 1]
  elif row == rowHigh: rows.add @[rowHigh - 1, rowHigh]
  else: rows.add @[row - 1, row, row + 1]
  if col == 0: cols.add @[0, 1]
  elif col == colHigh: cols.add @[colHigh - 1, colHigh]
  else: cols.add @[col - 1, col, col + 1]
  var nNeigh: int
  for sRow in rows:
    for sCol in cols:
      if sRow == row and sCol == col: continue
      if map[sRow][sCol] == '#': nNeigh += 1
  if nNeigh >= 4 and map[row][col] == '#': result = empty
  elif nNeigh == 0 and map[row][col] == 'L': result = occupied
  else: result = unchanged

proc getSeatStatusPart2(map: seq[seq[char]], row, col: int): Nextstatus =
  let rowHigh = map.high
  let colHigh = map[0].high
  var nNeigh: int
  let directions = [(0, 1), (-1, 1), (-1, 0), (-1, -1), (0, -1), (1, -1), (1, 0), (1, 1)]
  for (stepRow, stepCol) in directions:
    var currentRow = row
    var currentCol = col
    while currentRow in 0 .. rowHigh and currentCol in 0 .. colHigh:
      currentRow += stepRow
      currentCol += stepCol
      if not (currentRow in 0 .. rowHigh and currentCol in 0 .. colHigh): break
      if map[currentRow][currentCol] == '#':
        nNeigh += 1
        break
      elif map[currentRow][currentCol] == 'L':
        break
  if nNeigh >= 5 and map[row][col] == '#': result = empty
  elif nNeigh == 0 and map[row][col] == 'L': result = occupied
  else: result = unchanged

proc findEquilibrium(mapInit: Map, seatStatus: (map: Map, row: int, col: int) -> Nextstatus): Map =
  result = mapInit
  while true:
    var changeCordinates: seq[(int, int, char)] # stores coordinates of positions that should change
    for row in 0 .. result.high:
      for col in 0 .. result[0].high:
        let nextStatus = seatStatus(result, row, col)
        case nextStatus
        of empty: changeCordinates.add (row, col, 'L')
        of occupied: changeCordinates.add (row, col, '#')
        of unchanged: discard
    if changeCordinates.len == 0: break # if no changes -> finished!
    for (row, col, newChar) in changeCordinates:
      result[row][col] = newChar

proc countChar(map: seq[seq[char]], c: char): int =
  for i in 0 .. map.high:
    for j in 0 .. map[0].high:
      if map[i][j] == c: result += 1

proc testPart1() =
  var map = loadMap("testPart1.txt")
  map = findEquilibrium(map, getSeatStatusPart1)
  assert map == loadMap("testPart1Solution.txt")


proc part1() =
  var map = loadMap("day11.txt")
  map = findEquilibrium(map, getSeatStatusPart1)
  echo "Part 1: ", map.countChar('#'), " occupied seats"


proc testPart2() =
  var map = loadMap("testPart1.txt")
  map = findEquilibrium(map, getSeatStatusPart2)

proc part2() =
  var map = loadMap("day11.txt")
  map = findEquilibrium(map, getSeatStatusPart2)
  echo "Part 2: ", map.countChar('#'), " occupied seats"

when isMainModule:
  testPart1()
  part1()
  testPart2()
  part2()
