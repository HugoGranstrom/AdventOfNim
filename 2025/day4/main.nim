import batteries
import std / [strscans, algorithm, math]
import grids

proc numMovable(grid: var Grid[char], remove=false): int =
  for coord in grid:
    if grid[coord] != '@': continue
    var nNeighbours = 0
    for (neighCoord, val) in grid.neighbours(coord, ALL):
      if val == '@': nNeighbours += 1
    if nNeighbours < 4:
      result += 1
      if remove:
        grid[coord] = '.'

proc part1(input: string): int =
  var grid = parseCharGrid[char](input.strip)
  numMovable(grid)

proc part2(input: string): int =
  var grid = parseCharGrid[char](input.strip)
  while true:
    let nRemoved = numMovable(grid, remove=true)
    result += nRemoved
    if nRemoved == 0:
      break


let testInput = """
..@@.@@@@.
@@@.@.@.@@
@@@@@.@.@@
@.@@@@..@.
@@.@@@@.@@
.@@@@@@@.@
.@.@.@.@@@
@.@@@.@@@@
.@@@@@@@@.
@.@.@@@.@.
"""

when isMainModule:
  let realInput = readFile("input.txt")
  let input = realInput
  let answer1 = part1(input)
  echo "Part 1: ", answer1
  let answer2 = part2(input)
  echo "Part 2: ", answer2