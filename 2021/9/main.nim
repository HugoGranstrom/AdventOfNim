import std/[strutils, sequtils, math, strscans, tables, algorithm, sets]

proc getLowPoints(grid: seq[seq[int]]): seq[(int, int)] =
  for i in 0 .. grid.high: # rows
    for j in 0 .. grid[0].high: # columns
      # vertical check
      var isMinVert: bool
      if i == 0:
        if grid[0][j] < grid[1][j]:
          isMinVert = true
        else:
          isMinVert = false
      elif i == grid.high:
        if grid[i][j] < grid[i-1][j]:
          isMinVert = true
        else:
          isMinVert = false
      else:
        if grid[i][j] < grid[i-1][j] and grid[i][j] < grid[i+1][j]:
          isMInVert = true
        else:
          isMinVert = false

      var isMinHoriz: bool
      if j == 0:
        if grid[i][0] < grid[i][1]:
          isMinHoriz = true
        else:
          isMinHoriz = false
      elif j == grid[0].high:
        if grid[i][j] < grid[i][j-1]:
          isMinHoriz = true
        else:
          isMinHoriz = false
      else:
        if grid[i][j] < grid[i][j-1] and grid[i][j] < grid[i][j+1]:
          isMInHoriz = true
        else:
          isMinHoriz = false
      
      if isMinVert and isMinHoriz:
        result.add (i, j)

proc part1(grid: seq[seq[int]]): int =
  for lowpoint in grid.getLowPoints:
    result += grid[lowpoint[0]][lowpoint[1]] + 1

proc neighbours(grid: seq[seq[int]], points: HashSet[(int, int)], point: (int, int)): seq[(int, int)] =
  let (i, j) = point
  let minI = max(i-1, 0)
  let maxI = min(i+1, grid.high)
  let minJ = max(j-1, 0)
  let maxJ = min(j+1, grid[0].high)
  
  for x in minI .. maxI:
    if (x, j) notin points:
      result.add (x, j)
  for y in minJ .. maxJ:
    if (i, y) notin points:
      result.add (i, y)

proc recursiveSearch(grid: seq[seq[int]], points: var HashSet[(int, int)], currentPos: (int, int)) =
  # look at all sides and check if point is in points, if not: recurse there
  let neighPoints = neighbours(grid, points, currentPos)
  if neighPoints.len == 0: return # base case
  for neigh in neighPoints:
    # grid[currentPos[0]][currentPos[1]] < grid[neigh[0]][neigh[1]] and
    if grid[neigh[0]][neigh[1]] != 9:
      points.incl neigh
      recursiveSearch(grid, points, neigh)


proc part2(grid: seq[seq[int]]): int =
  var basins: seq[int]
  for lowpoint in grid.getLowPoints:
    # search for all other points in same basin as lowpoint
    var points = @[lowpoint].toHashSet
    recursiveSearch(grid, points, lowpoint)
    basins.add points.len
  result = prod(sorted(basins, Descending)[0..2]) # sum 3 largest


var grid: seq[seq[int]]
for line in "input.txt".lines:
  grid.add @[]
  for c in line:
    grid[^1].add parseInt($c)

let testInput = """2199943210
3987894921
9856789892
8767896789
9899965678"""
var testGrid: seq[seq[int]]
for line in testInput.splitLines:
  testGrid.add @[]
  for c in line:
    testGrid[^1].add parseInt($c)

echo "Part 1: ", part1(grid)
echo "Part 2 (test): ", part2(testGrid)
echo "Part 2: ", part2(grid)
