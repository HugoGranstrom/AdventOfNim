include std / prelude
import std / [strscans, algorithm, math]

type
  GridKind = enum
    gridSymbol,
    gridNum
  GridObject = object
    case kind: GridKind
    of gridSymbol:
      sym: char
    of gridNum:
      num: int
      id: int
  Grid = object
    width, height: int
    data: seq[GridObject]

proc initGrid(width, height: int): Grid =
  Grid(width: width, height: height, data: newSeq[GridObject](width*height))

proc `[]`(g: Grid, i, j: int): GridObject =
  g.data[i * g.width + j]

proc `[]=`(g: var Grid, i, j: int, val: char) =
  g.data[i * g.width + j] = GridObject(kind: gridSymbol, sym: val)

proc `[]=`(g: var Grid, i, j: int, val: tuple[num, id: int]) =
  g.data[i * g.width + j] = GridObject(kind: gridNum, num: val.num, id: val.id)


proc `$`(g: GridObject): string =
  case g.kind
  of gridSymbol:
    $g.sym
  of gridNum:
    $g.num & "(" & $g.id & ")"

proc `$`(g: Grid): string =
  for i in 0 ..< g.height:
    for j in 0 ..< g.width:
      result.add $g[i, j] & " "
    result.add "\n"

var currentId = 0

proc parseInput(input: string): Grid =
  let lines = input.strip.splitLines()
  result = initGrid(lines[0].len, lines.len)
  for i, line in lines:
    var j = 0
    while j < line.len:
      let c = line[j] 
      if c.isDigit:
        var token: string
        let numParsed = line.parseWhile(token, validChars={'0' .. '9'}, start=j)
        assert numParsed > 0
        let num = parseInt(token)
        for jj in 0 ..< numParsed:
          result[i, j+jj] = (num: num, id: currentId)
        currentId += 1
        j += numParsed - 1
      else:
        result[i, j] = c
      j += 1

iterator neighbours(grid: Grid, i, j: int): GridObject =
  var ii: Slice[int]
  if i == 0:
    ii = 0 .. 1
  elif i == grid.height - 1:
    ii = i - 1 .. i
  else:
    ii = i - 1 .. i + 1

  var jj: Slice[int]
  if j == 0:
    jj = 0 .. 1
  elif i == grid.width - 1:
    jj = j - 1 .. j
  else:
    jj = j - 1 .. j + 1

  for x in ii:
    for y in jj:
      yield grid[x, y]


proc part1(input: string): int =
  var grid = parseInput(input)
  var includedNums: HashSet[tuple[num, id: int]]
  for i in 0 ..< grid.height:
    for j in 0 ..< grid.width:
      let g = grid[i, j]
      if g.kind == gridSymbol and g.sym != '.':
        for neigh in neighbours(grid, i, j):
          if neigh.kind == gridNum:
            includedNums.incl((num: neigh.num, id: neigh.id))
  for (num, id) in includedNums:
    result += num

    

proc part2(input: string): int =
  var grid = parseInput(input)
  var tally: Table[(int, int), HashSet[(int, int)]]
  for i in 0 ..< grid.height:
    for j in 0 ..< grid.width:
      let g = grid[i, j]
      if g.kind == gridSymbol and g.sym == '*':
        for neigh in neighbours(grid, i, j):
          if neigh.kind == gridNum:
            tally.mgetOrPut((i, j), initHashSet[(int, int)]()).incl((num: neigh.num, id: neigh.id))
  
  for s in tally.values:
    if s.len == 2:
      var prod = 1
      for (x, id) in s:
        prod *= x
      result += prod

let testInput = """
467..114..
...*......
..35..633.
......#...
617*......
.....+.58.
..592.....
......755.
...$.*....
.664.598..
"""

when isMainModule:
  let realInput = readFile("input.txt")
  let input = realInput
  let answer1 = part1(input)
  echo "Part 1: ", answer1
  let answer2 = part2(input)
  echo "Part 2: ", answer2