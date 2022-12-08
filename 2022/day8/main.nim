include prelude
import std / [math]

proc readGrid(input: string): seq[seq[int]] =
  for line in input.splitLines:
    result.add @[]
    for c in line:
      result[^1].add parseInt($c)

proc printGrid[T](grid: seq[seq[T]]) =
  for row in 0 .. grid.high:
    echo grid[row]

proc part1And2(input: string) =
  let grid = readGrid(input)
  let nRows = grid.len
  let nCols = grid[0].len
  var isVisible = newSeqWith(nRows, newSeq[bool](nCols))
  let rowOrders = [toSeq(0 ..< nRows), toSeq(countdown(nRows - 1, 0))]
  let colOrders = [toSeq(0 ..< nCols), toSeq(countdown(nCols - 1, 0))]
  for row in 0 ..< nRows:
    for cols in colOrders:
      var largest = -1
      for col in cols:
        let current = grid[row][col]
        if current > largest:
          largest = current
          isVisible[row][col] = true

  for col in 0 ..< nCols:
    for rows in rowOrders:
      var largest = -1
      for row in rows:
        let current = grid[row][col]
        if current > largest:
          largest = current
          isVisible[row][col] = true
  
  var result1 = sum(isVisible.mapIt(sum(it.mapIt(int(it)))))

  echo "Part 1: ", result1

  var result2 = 0
  var scoreGrid = newSeqWith(nRows, newSeq[int](nCols))
  for row in 1 ..< nRows - 1:
    for col in 1 ..< nCols - 1:
      let rowOrders = [toSeq(row + 1 ..< nRows), toSeq(countdown(row - 1, 0))]
      let colOrders = [toSeq(col + 1 ..< nCols), toSeq(countdown(col - 1, 0))]
      var score = 1
      for rows in rowOrders:
        var dirScore = 0
        for i in rows:
          dirScore += 1
          if grid[i][col] >= grid[row][col]:
            break
        score *= dirScore
      
      for cols in colOrders:
        var dirScore = 0
        for i in cols:
          dirScore += 1
          if grid[row][i] >= grid[row][col]:
            break
        score *= dirScore
      result2 = max(result2, score)
      scoreGrid[row][col] = score
      if score == 291840: echo row, " ", col
  #printGrid scoreGrid
  echo "Part 2: ", result2


let testInput = """
30373
25512
65332
33549
35390"""

when isMainModule:
  let input = readFile "input.txt"
  part1And2(input)