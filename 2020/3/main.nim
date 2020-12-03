import
  std/[
    strutils,
    enumerate,
    math
  ]

proc loadMap(): seq[seq[char]] =
  let mapString = readFile("day3.txt")
  let nRows = mapString.countLines
  result = newSeq[seq[char]](nRows)
  for i, line in enumerate(mapString.splitLines):
    for j, c in line:
      result[i].add(c)
  result.delete(nRows - 1) # last line is empty

proc part1(stepCol, stepRow: int): int =
  let map = loadMap()
  let maxCol = map[0].high
  let maxRow = map.high
  var row = 0
  var col = 0
  while row <= maxRow:
    if col > maxCol:
      # wrap around if stepping outside map
      col = col - maxCol - 1
    if map[row][col] == '#':
      result += 1
    row += stepRow
    col += stepCol

when isMainModule:
  block part1:
    echo "Part 1:"
    echo part1(3, 1) ," trees found"
  block part1:
    echo "\nPart 2:"
    var trees: seq[int]
    let steps = [(1, 1), (3, 1), (5, 1), (7, 1), (1, 2)]
    for step in steps:
      trees.add part1(step[0], step[1])
    echo "Product is: ", prod(trees)
    