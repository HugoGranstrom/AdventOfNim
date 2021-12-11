import std/[strutils, sequtils, math, strscans, tables, algorithm, sets, strformat]
import arraymancer

proc parseGrid(s: string): Tensor[int] =
  let lines = s.splitLines
  result = newTensor[int](lines.len, lines[0].len)
  for i in 0 .. lines.high:
    for j in 0 .. lines[0].high:
      result[i, j] = parseInt($(lines[i][j]))

proc part1(grid: Tensor[int]): int =
  var grid = grid.clone
  for iter in 0 ..< 100: # after step n
    var flashed = newTensor[bool](grid.shape)
    grid +.= 1
    var overflowed = grid >. 9
    var nFlashed = 1
    while nFlashed > 0:
      nFlashed = 0
      for i in 0 .. overflowed.shape[0]-1:
        for j in 0 .. overflowed.shape[1]-1:
          if overflowed[i, j] and not flashed[i, j]:
            flashed[i, j] = true
            nFlashed += 1
            let minI = max(i-1, 0)
            let maxI = min(i+1, overflowed.shape[0] - 1)
            let minJ = max(j-1, 0)
            let maxJ = min(j+1, overflowed.shape[1] - 1)
            for x in minI .. maxI:
              for y in minJ .. maxJ:
                if (x, y) != (i, j):
                  grid[x, y] += 1
                  if grid[x, y] > 9 and not flashed[x, y]:
                    overflowed[x, y] = true
      result += nFlashed
    grid[flashed] = 0

proc part2(grid: Tensor[int]): int =
  var grid = grid.clone
  var iter = 0
  while true: # after step n
    var flashed = newTensor[bool](grid.shape)
    grid +.= 1
    var overflowed = grid >. 9
    var nFlashed = 1
    while nFlashed > 0:
      nFlashed = 0
      for i in 0 .. overflowed.shape[0]-1:
        for j in 0 .. overflowed.shape[1]-1:
          if overflowed[i, j] and not flashed[i, j]:
            flashed[i, j] = true
            nFlashed += 1
            let minI = max(i-1, 0)
            let maxI = min(i+1, overflowed.shape[0] - 1)
            let minJ = max(j-1, 0)
            let maxJ = min(j+1, overflowed.shape[1] - 1)
            for x in minI .. maxI:
              for y in minJ .. maxJ:
                if (x, y) != (i, j):
                  grid[x, y] += 1
                  if grid[x, y] > 9 and not flashed[x, y]:
                    overflowed[x, y] = true
    if grid[flashed].size == 100:
      return iter + 1
    grid[flashed] = 0
    iter += 1
      

      
            


let testInput = """5483143223
2745854711
5264556173
6141336146
6357385478
4167524645
2176841721
6882881134
4846848554
5283751526"""

let testGrid = testInput.parseGrid
let grid = "input.txt".readFile.parseGrid

echo "Part 1 (test): ", part1(testGrid)
echo "Part 1: ", part1(grid)

echo "Part 2 (test): ", part2(testGrid)
echo "Part 2: ", part2(grid)